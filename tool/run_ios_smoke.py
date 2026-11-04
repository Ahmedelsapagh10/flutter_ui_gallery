#!/usr/bin/env python3
"""Run real iOS smoke tests repeatedly, with strict results and bounded diagnostics."""
import argparse
import datetime
import json
import os
from pathlib import Path
import shutil
import signal
import subprocess
import sys


EXPECTED = {
    'native playground launches and a sheet returns its action',
    'floatingCove preserves native destination state',
    'glassDock preserves native destination state',
}


def verify_results(log, returncode):
    if returncode != 0:
        raise RuntimeError(f'Flutter exited with {returncode}')
    started, passed, completed = {}, set(), False
    for line in log.splitlines():
        try:
            event = json.loads(line)
        except (ValueError, TypeError):
            continue  # Verbose Flutter/Xcode diagnostics share the output stream.
        if not isinstance(event, dict):
            continue
        kind = event.get('type')
        if kind == 'error':
            raise RuntimeError(f'Dart test error: {event.get("error")}')
        if kind == 'testStart' and event['test']['name'] in EXPECTED:
            test = event['test']
            if test['name'] in started.values():
                raise RuntimeError(f'Duplicate scenario: {test["name"]}')
            started[test['id']] = test['name']
        if kind == 'testDone' and event['testID'] in started:
            if event.get('result') != 'success' or event.get('skipped'):
                raise RuntimeError(f'Scenario did not pass: {started[event["testID"]]}')
            passed.add(started[event['testID']])
        if kind == 'done':
            completed = event.get('success') is True
    if passed != EXPECTED or not completed:
        raise RuntimeError(f'Incomplete smoke run: passed {sorted(passed)}, done={completed}')
    return sorted(passed)


def run_bounded(command, destination, timeout, cwd=None):
    with destination.open('w') as output:
        process = subprocess.Popen(command, cwd=cwd, stdout=output,
                                   stderr=subprocess.STDOUT, start_new_session=True)
        try:
            return process.wait(timeout=timeout)
        except subprocess.TimeoutExpired:
            os.killpg(process.pid, signal.SIGTERM)
            try:
                process.wait(timeout=10)
            except subprocess.TimeoutExpired:
                os.killpg(process.pid, signal.SIGKILL)
                process.wait(timeout=10)
            return 124


def diagnostics(device, directory, started):
    commands = {
        'devices.json': ['xcrun', 'simctl', 'list', 'devices', '--json'],
        'processes.txt': ['ps', '-axo', 'pid,ppid,state,etime,comm'],
        'simulator-processes.txt': ['xcrun', 'simctl', 'spawn', device, 'launchctl', 'list'],
        'native-log.json': ['xcrun', 'simctl', 'spawn', device, 'log', 'show',
                            '--last', '15m', '--style', 'json', '--debug',
                            '--predicate', 'process == "Runner" OR process == "ReportCrash"'],
    }
    outcomes = {}
    for name, command in commands.items():
        try:
            outcomes[name] = run_bounded(command, directory / name, 30)
        except OSError as error:
            outcomes[name] = str(error)
    crash_roots = [Path.home() / 'Library/Logs/DiagnosticReports',
                   Path.home() / f'Library/Developer/CoreSimulator/Devices/{device}/data/Library/Logs/CrashReporter']
    crashes = []
    for index, root in enumerate(crash_roots):
        for pattern in ['Runner*.ips', 'Runner*.crash']:
            for report in root.glob(pattern):
                if report.stat().st_mtime >= started.timestamp():
                    shutil.copy2(report, directory / f'crash-{index}-{report.name}')
                    crashes.append(report.name)
    (directory / 'diagnostics-status.json').write_text(json.dumps(outcomes, indent=2))
    return crashes


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--device', required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[1]
    args.output.mkdir(parents=True, exist_ok=True)
    for attempt in range(1, 4):  # Three required passes, never retry away a failure.
        directory = args.output / f'attempt-{attempt}'
        directory.mkdir()
        start = datetime.datetime.now(datetime.timezone.utc)
        print(f'iOS smoke {attempt}/3 started {start.isoformat()}', flush=True)
        log = directory / 'flutter.log'
        code = run_bounded(['flutter', '--verbose', 'test', '--no-pub', '--machine',
                            'integration_test/native_smoke_test.dart', '-d', args.device],
                           log, 600, cwd=root / 'example')
        # Collect native history/process/crash evidence even when attachment failed.
        crashes = diagnostics(args.device, directory, start)
        summary = {'attempt': attempt, 'started': start.isoformat(), 'exit_code': code,
                   'native_crash_reports': crashes}
        try:
            summary['passed'] = verify_results(log.read_text(errors='replace'), code)
            if crashes:
                raise RuntimeError(f'Runner crashed during smoke execution: {crashes}')
        except RuntimeError as error:
            summary['failure'] = str(error)
            print('\n'.join(log.read_text(errors='replace').splitlines()[-60:]), flush=True)
            print(f'iOS smoke failed: {error}', file=sys.stderr, flush=True)
            (directory / 'result.json').write_text(json.dumps(summary, indent=2))
            return 1
        (directory / 'result.json').write_text(json.dumps(summary, indent=2))
        for name in summary['passed']:
            print(f'PASS attempt {attempt}: {name}', flush=True)
    return 0


if __name__ == '__main__':
    sys.exit(main())
