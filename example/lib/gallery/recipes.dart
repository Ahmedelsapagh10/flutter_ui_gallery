import 'package:flutter/material.dart';
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';

typedef ExampleOperation =
    Future<void> Function(
      ValueChanged<double> progress,
      bool Function() cancelled,
    );

/// A bounded local demonstration; applications inject their repository operation.
Future<void> samplePreparation(
  ValueChanged<double> progress,
  bool Function() cancelled,
) async {
  for (var step = 0; step < 4; step++) {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    if (cancelled()) return;
    progress((step + 1) / 4);
  }
}

class RecipeGallery extends StatelessWidget {
  const RecipeGallery({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Real app examples')),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Interactive examples with local data. Each page owns its state and uses the public package APIs.',
        ),
        const SizedBox(height: 24),
        for (final recipe in [
          (
            'Productivity',
            'Search, commands, validated editing and bulk actions',
            Icons.checklist_rounded,
            const ProductivityExample(),
          ),
          (
            'Shopping',
            'Retained basket, validation, async work and cancellation',
            Icons.shopping_bag_outlined,
            const ShoppingExample(),
          ),
          (
            'Dashboard',
            'Loading, data, empty results, errors and retry',
            Icons.dashboard_outlined,
            const DashboardExample(),
          ),
        ])
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(20),
              leading: Icon(recipe.$3),
              title: Text(recipe.$1),
              subtitle: Text(recipe.$2),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute<void>(builder: (_) => recipe.$4)),
            ),
          ),
      ],
    ),
  );
}

enum _NoteCommand { create, select }

class ProductivityExample extends StatefulWidget {
  const ProductivityExample({super.key});
  @override
  State<ProductivityExample> createState() => _ProductivityExampleState();
}

class _ProductivityExampleState extends State<ProductivityExample> {
  final _notes = <int, String>{
    1: 'Prepare the product review',
    2: 'Collect ideas for the next release',
    3: 'Plan a quiet weekend',
  };
  final _selected = <int>{};
  final _search = TextEditingController();
  String _query = '';
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  int _nextId = 4;

  Future<void> _create() async {
    final title = await UiGallerySheet.show<String>(
      context: context,
      preset: UiGallerySheetPreset.orbit,
      header: const Text('New note'),
      child: const _TextEditor(label: 'Note title', submit: 'Create note'),
    );
    if (mounted && title != null) setState(() => _notes[_nextId++] = title);
  }

  Future<void> _commands() async {
    final command = await UiGalleryDialog.commands<_NoteCommand>(
      context: context,
      title: 'Quick actions',
      emptyLabel: 'No matching actions',
      commands: const [
        UiGalleryDialogAction(
          label: 'Create note',
          value: _NoteCommand.create,
          icon: Icon(Icons.add),
        ),
        UiGalleryDialogAction(
          label: 'Select all notes',
          value: _NoteCommand.select,
          icon: Icon(Icons.select_all),
        ),
      ],
    );
    if (!mounted) return;
    if (command == _NoteCommand.create) {
      await _create();
    }
    if (command == _NoteCommand.select) {
      setState(() => _selected.addAll(_notes.keys));
    }
  }

  Future<void> _archive() async {
    final accepted = await UiGalleryDialog.confirm(
      context: context,
      title: 'Archive selected notes?',
      message: '${_selected.length} notes will leave this workspace.',
      confirmLabel: 'Archive',
    );
    if (!mounted || accepted != true) return;
    final removed = {for (final id in _selected) id: _notes[id]!};
    setState(() {
      _notes.removeWhere((id, _) => _selected.contains(id));
      _selected.clear();
    });
    UiGalleryToast.show(
      context,
      preset: UiGalleryToastPreset.action,
      message: '${removed.length} notes archived',
      actionLabel: 'Undo',
      duplicates: UiGalleryToastDuplicates.allow,
      onAction: () {
        if (mounted) setState(() => _notes.addAll(removed));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final notes = _notes.entries
        .where(
          (entry) => entry.value.toLowerCase().contains(_query.toLowerCase()),
        )
        .toList();
    return PopScope<void>(
      canPop: _selected.isEmpty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(_selected.clear);
      },
      child: Scaffold(
        appBar: UiGalleryAppBar(
          preset: _selected.isEmpty
              ? UiGalleryAppBarPreset.searchSwitch
              : UiGalleryAppBarPreset.selectionBar,
          title: const Text('Workspace'),
          selectionCount: _selected.length,
          onSelectionCleared: () => setState(_selected.clear),
          searchField: TextField(
            controller: _search,
            decoration: const InputDecoration(hintText: 'Search notes'),
            onChanged: (value) => setState(() => _query = value),
          ),
          actions: [
            if (_selected.isNotEmpty)
              IconButton(
                tooltip: 'Archive selected notes',
                onPressed: _archive,
                icon: const Icon(Icons.archive_outlined),
              )
            else
              IconButton(
                tooltip: 'Workspace commands',
                onPressed: _commands,
                icon: const Icon(Icons.keyboard_command_key),
              ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          tooltip: 'New note',
          onPressed: _create,
          child: const Icon(Icons.add),
        ),
        body: notes.isEmpty
            ? Center(
                child: Text(
                  _notes.isEmpty
                      ? 'Your workspace is empty. Create a note to begin.'
                      : 'No matching notes',
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  for (final note in notes)
                    CheckboxListTile(
                      key: ValueKey('recipe-note-${note.key}'),
                      title: Text(note.value),
                      value: _selected.contains(note.key),
                      onChanged: (value) => setState(() {
                        if (value == true) {
                          _selected.add(note.key);
                        } else {
                          _selected.remove(note.key);
                        }
                      }),
                    ),
                ],
              ),
      ),
    );
  }
}

class _TextEditor extends StatefulWidget {
  const _TextEditor({required this.label, required this.submit});
  final String label, submit;
  @override
  State<_TextEditor> createState() => _TextEditorState();
}

class _TextEditorState extends State<_TextEditor> {
  final _form = GlobalKey<FormState>();
  final _text = TextEditingController();
  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _submit() {
    if (_form.currentState!.validate()) {
      Navigator.of(context).pop(_text.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) => Form(
    key: _form,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _text,
          autofocus: true,
          maxLength: 80,
          decoration: InputDecoration(labelText: widget.label),
          onFieldSubmitted: (_) => _submit(),
          validator: (value) => value == null || value.trim().isEmpty
              ? 'Enter ${widget.label.toLowerCase()}'
              : null,
        ),
        const SizedBox(height: 16),
        FilledButton(onPressed: _submit, child: Text(widget.submit)),
      ],
    ),
  );
}

class ShoppingExample extends StatefulWidget {
  const ShoppingExample({super.key, this.prepare = samplePreparation});
  final ExampleOperation prepare;
  @override
  State<ShoppingExample> createState() => _ShoppingExampleState();
}

class _ShoppingExampleState extends State<ShoppingExample> {
  static const _products = [
    ('Everyday notebook', 1200),
    ('Pocket planner', 1800),
    ('Desk journal', 2400),
  ];
  final _basket = <int, int>{};
  final _progress = ValueNotifier<double>(0);
  int _page = 0, _generation = 0;
  bool _busy = false, _cancelled = false;
  String? _error, _confirmation, _recipient;
  UiGalleryToastHandle? _handle;
  int get _count => _basket.values.fold(0, (a, b) => a + b);
  int get _total => _basket.entries.fold(
    0,
    (sum, entry) => sum + _products[entry.key].$2 * entry.value,
  );

  @override
  void dispose() {
    _cancelled = true;
    _generation++;
    _handle?.dismiss();
    _progress.dispose();
    super.dispose();
  }

  Future<void> _prepare() async {
    if (_busy || _basket.isEmpty) return;
    final recipient =
        _recipient ??
        await UiGallerySheet.show<String>(
          context: context,
          header: const Text('Prepare your basket'),
          child: const _TextEditor(
            label: 'Recipient name',
            submit: 'Prepare order',
          ),
        );
    if (!mounted || recipient == null) return;
    _recipient = recipient;
    final generation = ++_generation;
    setState(() {
      _busy = true;
      _cancelled = false;
      _error = null;
      _confirmation = null;
    });
    _progress.value = 0;
    final handle = UiGalleryToast.progress(
      context,
      message: 'Preparing your basket',
      progress: _progress,
      actionLabel: 'Cancel preparation',
      onAction: () {
        _cancelled = true;
        if (mounted) {
          setState(
            () => _confirmation =
                'Preparation cancelled. Your basket is preserved.',
          );
        }
      },
    );
    _handle = handle;
    try {
      await widget.prepare((value) {
        if (mounted && generation == _generation && !_cancelled) {
          _progress.value = value;
        }
      }, () => !mounted || generation != _generation || _cancelled);
      if (mounted && generation == _generation) {
        setState(() {
          _confirmation = _cancelled
              ? 'Preparation cancelled. Your basket is preserved.'
              : 'Basket ready for $recipient';
        });
      }
    } catch (_) {
      if (mounted && generation == _generation && !_cancelled) {
        setState(
          () => _error = 'Could not prepare your basket. Please try again.',
        );
      }
    } finally {
      handle.dismiss();
      await handle.closed;
      if (mounted && generation == _generation) {
        setState(() {
          _busy = false;
          _handle = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => PopScope<void>(
    canPop: _page == 0,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) setState(() => _page = 0);
    },
    child: Scaffold(
      appBar: UiGalleryAppBar(
        preset: UiGalleryAppBarPreset.centeredTitle,
        title: const Text('Field Store'),
      ),
      body: IndexedStack(
        index: _page,
        children: [
          ListView(
            padding: const EdgeInsets.all(20),
            children: [
              for (var i = 0; i < _products.length; i++)
                Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(_products[i].$1),
                    subtitle: Text(
                      '\$${(_products[i].$2 / 100).toStringAsFixed(2)}',
                    ),
                    trailing: IconButton(
                      tooltip: 'Add ${_products[i].$1}',
                      onPressed: _busy
                          ? null
                          : () => setState(() {
                              _basket.update(
                                i,
                                (count) => count + 1,
                                ifAbsent: () => 1,
                              );
                              _confirmation = null;
                            }),
                      icon: const Icon(Icons.add_shopping_cart),
                    ),
                  ),
                ),
            ],
          ),
          ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (_basket.isEmpty)
                const Text('Your basket is empty')
              else ...[
                for (final entry in _basket.entries)
                  ListTile(
                    title: Text(_products[entry.key].$1),
                    subtitle: Text('Quantity: ${entry.value}'),
                    trailing: IconButton(
                      tooltip: 'Remove ${_products[entry.key].$1}',
                      onPressed: _busy
                          ? null
                          : () => setState(() {
                              if (entry.value == 1) {
                                _basket.remove(entry.key);
                              } else {
                                _basket[entry.key] = entry.value - 1;
                              }
                            }),
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  'Total: \$${(_total / 100).toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _busy ? null : _prepare,
                  child: Text(_busy ? 'Preparing…' : 'Prepare basket'),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(_error!),
                TextButton(
                  onPressed: _busy ? null : _prepare,
                  child: const Text('Retry preparation'),
                ),
              ],
              if (_confirmation != null) ...[
                const SizedBox(height: 16),
                Text(_confirmation!),
              ],
            ],
          ),
        ],
      ),
      bottomNavigationBar: UiGalleryBottomNav(
        preset: UiGalleryBottomNavPreset.adaptiveMinimal,
        selectedIndex: _page,
        onDestinationSelected: (value) => setState(() => _page = value),
        items: [
          const UiGalleryBottomNavItem(
            icon: Icon(Icons.storefront_outlined),
            label: 'Shop',
          ),
          UiGalleryBottomNavItem(
            icon: const Icon(Icons.shopping_bag_outlined),
            label: 'Basket',
            badge: _count == 0 ? null : Text('$_count'),
          ),
        ],
      ),
    ),
  );
}

@immutable
class ExampleMetric {
  const ExampleMetric(this.label, this.value);
  final String label, value;
}

Future<List<ExampleMetric>> sampleMetrics() async {
  await Future<void>.delayed(const Duration(milliseconds: 240));
  return const [
    ExampleMetric('Active projects', '12'),
    ExampleMetric('Completed tasks', '48'),
    ExampleMetric('Team members', '6'),
  ];
}

class DashboardExample extends StatefulWidget {
  const DashboardExample({super.key, this.load = sampleMetrics});
  final Future<List<ExampleMetric>> Function() load;
  @override
  State<DashboardExample> createState() => _DashboardExampleState();
}

class _DashboardExampleState extends State<DashboardExample> {
  List<ExampleMetric>? _metrics;
  bool _loading = true;
  String? _error;
  int _generation = 0;
  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  void dispose() {
    _generation++;
    super.dispose();
  }

  Future<void> _refresh() async {
    final generation = ++_generation;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final metrics = await widget.load();
      if (mounted && generation == _generation) {
        setState(() {
          _metrics = metrics;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted && generation == _generation) {
        setState(() {
          _loading = false;
          _error = 'Could not load the overview';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: UiGalleryAppBar(
      preset: UiGalleryAppBarPreset.editorialTopbar,
      title: const Text('Team overview'),
      subtitle: const Text('A clear view of the work'),
      actions: [
        IconButton(
          tooltip: 'Refresh overview',
          onPressed: _loading ? null : _refresh,
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
        ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_error!),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _refresh,
                  child: const Text('Retry overview'),
                ),
              ],
            ),
          )
        : _metrics!.isEmpty
        ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('No activity yet'),
                TextButton(
                  onPressed: _refresh,
                  child: const Text('Refresh overview'),
                ),
              ],
            ),
          )
        : RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(24),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                for (final metric in _metrics!)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          metric.value,
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        Text(
                          metric.label,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
  );
}
