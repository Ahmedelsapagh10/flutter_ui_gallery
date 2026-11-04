"""Guard the iOS release gate against false success and unbounded execution."""
import json
from pathlib import Path
import sys
import tempfile
import unittest

from run_ios_smoke import EXPECTED, run_bounded, verify_results


def report():
    events = []
    for index, name in enumerate(sorted(EXPECTED)):
        events.extend([{'type': 'testStart', 'test': {'id': index, 'name': name}},
                       {'type': 'testDone', 'testID': index, 'result': 'success', 'skipped': False}])
    return events + [{'type': 'done', 'success': True}]


class SmokeGateTest(unittest.TestCase):
    def check(self, events, code=0):
        return verify_results('\n'.join(json.dumps(e) for e in events), code)

    def test_requires_all_three_real_results(self):
        self.assertEqual(set(self.check(report())), EXPECTED)
        with self.assertRaises(RuntimeError):
            self.check([{'type': 'done', 'success': True}])
        with self.assertRaises(RuntimeError):
            self.check(report()[2:])

    def test_rejects_skipped_failed_and_unhandled_errors(self):
        for event in [{'type': 'testDone', 'testID': 0, 'result': 'failure'},
                      {'type': 'testDone', 'testID': 0, 'result': 'success', 'skipped': True},
                      {'type': 'error', 'error': 'unhandled exception'},
                      {'type': 'done', 'success': False}]:
            with self.subTest(event=event), self.assertRaises(RuntimeError):
                self.check(report() + [event])

    def test_rejects_crashed_process_even_after_success_events(self):
        with self.assertRaises(RuntimeError):
            self.check(report(), -11)

    def test_rejects_missing_completion_and_duplicate_scenarios(self):
        for events in [report()[:-1], report() + report()[:1]]:
            with self.assertRaises(RuntimeError):
                self.check(events)

    def test_actual_crash_and_timeout_fail_closed(self):
        with tempfile.TemporaryDirectory() as directory:
            log = Path(directory) / 'process.log'
            code = run_bounded([sys.executable, '-c',
                                'import os, signal; os.kill(os.getpid(), signal.SIGKILL)'], log, 2)
            self.assertNotEqual(code, 0)
            code = run_bounded([sys.executable, '-c', 'import time; time.sleep(60)'], log, .1)
            self.assertEqual(code, 124)


if __name__ == '__main__':
    unittest.main()
