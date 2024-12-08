import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Task {
  int id;
  String name;
  DateTime deadline;
  String priority;
  String responsible;
  String summary;
  String area;
  bool isCompleted;

  Task({
    required this.id,
    required this.name,
    required this.deadline,
    required this.priority,
    required this.responsible,
    required this.summary,
    required this.area,
    this.isCompleted = false,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['ID'],
      name: json['nome'],
      deadline: DateTime.parse(json['data_conclusao']),
      priority: json['prioridade'],
      responsible: json['responsavel'],
      summary: json['resumo'] ?? 'Resumo não disponível',
      area: json['area'],
      isCompleted: json['concluido'] ?? false,
    );
  }
}

class TaskManager extends StatefulWidget {
  @override
  _TaskManagerState createState() => _TaskManagerState();
}

class _TaskManagerState extends State<TaskManager> {
  final List<Task> tasks = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String taskName = '';
  String taskDeadline = '';
  String taskPriority = '';
  String taskResponsible = '';
  String taskSummary = '';
  String taskArea = '';

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    var url = Uri.parse('http://localhost:8000/home/tarefas');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      try {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          tasks.clear();
          tasks.addAll(data.map((json) => Task.fromJson(json)).toList());
        });
      } catch (e) {
        showSnackbar('Erro ao processar os dados: $e');
      }
    } else {
      showSnackbar(
          'Erro ao buscar as tarefas. Status: ${response.statusCode}, Body: ${response.body}');
    }
  }

  Future<void> addTask() async {
    if (taskName.isNotEmpty &&
        taskDeadline.isNotEmpty &&
        taskPriority.isNotEmpty &&
        taskResponsible.isNotEmpty &&
        taskSummary.isNotEmpty &&
        taskArea.isNotEmpty) {
      String normalizedPriority = taskPriority.toLowerCase();
      if (['baixa', 'média', 'alta'].contains(normalizedPriority)) {
        try {
          DateTime parsedDate = DateFormat('dd/MM').parse(taskDeadline);

          var taskData = {
            'nome': taskName,
            'data_conclusao': DateFormat('yyyy-MM-dd').format(parsedDate),
            'responsavel': taskResponsible,
            'resumo': taskSummary,
            'prioridade': normalizedPriority[0].toUpperCase() +
                normalizedPriority.substring(1),
            'area': taskArea,
          };

          var url = Uri.parse('http://localhost:8000/home/tarefas');

          var response = await http.post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(taskData),
          );

          if (response.statusCode == 200) {
            await fetchTasks();
            clearInputs();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Tarefa adicionada com sucesso!')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      'Erro ao adicionar tarefa no backend! Código: ${response.statusCode}')),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Data inválida! Use o formato DD/MM.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('A prioridade deve ser "Baixa", "Média" ou "Alta".')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Preencha todos os campos corretamente!')),
      );
    }
  }

  Future<void> editTask(Task task) async {
    if (taskName.isNotEmpty &&
        taskDeadline.isNotEmpty &&
        taskPriority.isNotEmpty &&
        taskResponsible.isNotEmpty &&
        taskSummary.isNotEmpty &&
        taskArea.isNotEmpty) {
      String normalizedPriority = taskPriority.toLowerCase();
      if (!['baixa', 'média', 'alta'].contains(normalizedPriority)) {
        showSnackbar('A prioridade deve ser "Baixa", "Média" ou "Alta".');
        return;
      }

      try {
        DateTime parsedDate = DateFormat('dd/MM').parseStrict(taskDeadline);
        var taskData = {
          'nome': taskName,
          'data_conclusao': DateFormat('yyyy-MM-dd').format(parsedDate),
          'responsavel': taskResponsible,
          'resumo': taskSummary,
          'prioridade': normalizedPriority[0].toUpperCase() +
              normalizedPriority.substring(1),
          'area': taskArea,
        };

        var url = Uri.parse('http://localhost:8000/home/tarefas/${task.id}');

        var response = await http.put(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(taskData),
        );

        if (response.statusCode == 200) {
          fetchTasks();
          showSnackbar('Tarefa editada com sucesso!');
        } else {
          showSnackbar(
              'Erro ao editar a tarefa no backend! Código: ${response.statusCode}');
        }
      } catch (e) {
        showSnackbar('Data inválida! Use o formato DD/MM.');
      }
    } else {
      showSnackbar('Preencha todos os campos corretamente!');
    }
  }

  Future<void> deleteTask(Task task) async {
    var url = Uri.parse('http://localhost:8000/home/tarefas/${task.id}');
    var response = await http.delete(url);

    if (response.statusCode == 200) {
      setState(() {
        tasks.remove(task);
      });
      showSnackbar('Tarefa excluída com sucesso!');
    } else {
      showSnackbar('Erro ao excluir a tarefa!');
    }
  }

  void clearInputs() {
    taskName = '';
    taskDeadline = '';
    taskPriority = '';
    taskResponsible = '';
    taskSummary = '';
    taskArea = '';
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void openTaskDetailsDialog(Task task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Detalhes da Tarefa'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nome: ${task.name}',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text(
                    'Data de Conclusão: ${DateFormat('dd/MM').format(task.deadline)}'),
                SizedBox(height: 10),
                Text('Prioridade: ${task.priority}'),
                SizedBox(height: 10),
                Text('Responsável: ${task.responsible}'),
                SizedBox(height: 10),
                Text('Área: ${task.area}'),
                SizedBox(height: 10),
                Text('Resumo:'),
                SizedBox(height: 5),
                Text(task.summary, textAlign: TextAlign.justify),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Fechar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void openTaskDialog({Task? task}) {
    if (task != null) {
      // Preenche os campos para edição.
      taskName = task.name;
      taskDeadline = DateFormat('dd/MM').format(task.deadline);
      taskPriority = task.priority;
      taskResponsible = task.responsible;
      taskSummary = task.summary;
      taskArea = task.area;
    } else {
      clearInputs();
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(task == null ? 'Adicionar Tarefa' : 'Editar Tarefa'),
          content: Container(
            width: 400,
            height: 500,
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextFormField(
                      initialValue: taskName,
                      decoration: InputDecoration(labelText: 'Nome da Tarefa'),
                      onChanged: (value) => taskName = value,
                    ),
                    TextFormField(
                      initialValue: taskDeadline,
                      decoration: InputDecoration(
                          labelText: 'Data de Conclusão (DD/MM)'),
                      onChanged: (value) => taskDeadline = value,
                    ),
                    TextFormField(
                      initialValue: taskPriority,
                      decoration: InputDecoration(
                          labelText: 'Prioridade (Baixa, Média, Alta)'),
                      onChanged: (value) => taskPriority = value,
                    ),
                    TextFormField(
                      initialValue: taskResponsible,
                      decoration: InputDecoration(labelText: 'Responsável'),
                      onChanged: (value) => taskResponsible = value,
                    ),
                    TextFormField(
                      initialValue: taskArea,
                      decoration: InputDecoration(labelText: 'Área'),
                      onChanged: (value) => taskArea = value,
                    ),
                    TextFormField(
                      initialValue: taskSummary,
                      maxLines: 5,
                      decoration: InputDecoration(labelText: 'Resumo'),
                      onChanged: (value) => taskSummary = value,
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('Salvar'),
              onPressed: () {
                if (task == null) {
                  addTask();
                } else {
                  editTask(task);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gerenciador de Tarefas'),
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return ListTile(
            title: Text(task.name),
            subtitle: Text(
                '${DateFormat('dd/MM').format(task.deadline)} | ${task.priority}'),
            onTap: () => openTaskDetailsDialog(task),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => openTaskDialog(task: task),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => deleteTask(task),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => openTaskDialog(),
      ),
    );
  }

  void main() {
    runApp(MaterialApp(
      home: TaskManager(),
    ));
  }
}
