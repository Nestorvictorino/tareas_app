import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mis tareas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF176B58)),
        scaffoldBackgroundColor: const Color(0xFFF5F7F6),
      ),
      home: const MyHomePage(title: 'Mis tareas'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _Task {
  _Task(this.title);

  String title;
  bool completed = false;
}

enum _TaskFilter { all, pending, completed }

class _MyHomePageState extends State<MyHomePage> {
  final List<_Task> _tasks = [];
  _TaskFilter _filter = _TaskFilter.all;

  Future<void> _editTask([_Task? task]) async {
    final title = await showDialog<String>(
      context: context,
      builder: (context) => _TaskEditor(initialTitle: task?.title),
    );
    if (!mounted || title == null) return;
    setState(() {
      if (task == null) {
        _tasks.add(_Task(title));
      } else {
        task.title = title;
      }
    });
  }

  void _deleteTask(_Task task) {
    final index = _tasks.indexOf(task);
    setState(() => _tasks.remove(task));
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        persist: false,
        content: const Text('Tarea eliminada'),
        action: SnackBarAction(
          label: 'Deshacer',
          onPressed: () {
            if (!mounted) return;
            setState(() {
              _tasks.insert(
                index > _tasks.length ? _tasks.length : index,
                task,
              );
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleTasks = _tasks.where((task) {
      return switch (_filter) {
        _TaskFilter.all => true,
        _TaskFilter.pending => !task.completed,
        _TaskFilter.completed => task.completed,
      };
    }).toList();
    final emptyMessage = switch (_filter) {
      _TaskFilter.all => 'Sin tareas por ahora',
      _TaskFilter.pending => 'No hay tareas pendientes',
      _TaskFilter.completed => 'No hay tareas completadas',
    };

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    _tasks.isEmpty
                        ? 'Tu lista está vacía'
                        : '${_tasks.where((task) => !task.completed).length} '
                              'pendientes de ${_tasks.length}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: SegmentedButton<_TaskFilter>(
                    showSelectedIcon: false,
                    expandedInsets: EdgeInsets.zero,
                    segments: const [
                      ButtonSegment(
                        value: _TaskFilter.all,
                        label: Text('Todas'),
                      ),
                      ButtonSegment(
                        value: _TaskFilter.pending,
                        label: Text('Pendientes'),
                      ),
                      ButtonSegment(
                        value: _TaskFilter.completed,
                        label: Text('Completadas'),
                      ),
                    ],
                    selected: {_filter},
                    onSelectionChanged: (selection) {
                      setState(() => _filter = selection.single);
                    },
                  ),
                ),
                Expanded(
                  child: visibleTasks.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.checklist_rounded,
                                size: 72,
                                color: Color(0xFF176B58),
                              ),
                              const SizedBox(height: 16),
                              Text(emptyMessage),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                          itemCount: visibleTasks.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final task = visibleTasks[index];
                            return Material(
                              key: ObjectKey(task),
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 8,
                                ),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: task.completed,
                                      semanticLabel: 'Completar ${task.title}',
                                      onChanged: (value) => setState(() {
                                        task.completed = value ?? false;
                                      }),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: Text(
                                          task.title,
                                          style: TextStyle(
                                            decoration: task.completed
                                                ? TextDecoration.lineThrough
                                                : null,
                                          ),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Editar tarea',
                                      onPressed: () => _editTask(task),
                                      icon: const Icon(Icons.edit_outlined),
                                    ),
                                    IconButton(
                                      tooltip: 'Eliminar tarea',
                                      onPressed: () => _deleteTask(task),
                                      icon: Icon(
                                        Icons.delete_outline,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.error,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _editTask(),
        icon: const Icon(Icons.add),
        label: const Text('Nueva tarea'),
      ),
    );
  }
}

class _TaskEditor extends StatefulWidget {
  const _TaskEditor({this.initialTitle});

  final String? initialTitle;

  @override
  State<_TaskEditor> createState() => _TaskEditorState();
}

class _TaskEditorState extends State<_TaskEditor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialTitle);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop(_controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialTitle == null ? 'Nueva tarea' : 'Editar tarea'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            labelText: 'Nombre de la tarea',
            border: OutlineInputBorder(),
          ),
          validator: (value) => value == null || value.trim().isEmpty
              ? 'Escribe una tarea'
              : null,
          onFieldSubmitted: (_) => _save(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _save, child: const Text('Guardar')),
      ],
    );
  }
}
