import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Task {
  final String name;
  final DateTime deadline;
  final String priority;
  final String responsible;
  final String summary;
  final String area;
  bool isCompleted;

  Task({
    required this.name,
    required this.deadline,
    this.isCompleted = false,
    required this.priority,
    required this.responsible,
    required this.summary,
    required this.area,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      name: json['nome'],
      deadline: DateTime.parse(json['data_conclusao']),
      priority: json['prioridade'],
      responsible: json['responsavel'],
      summary: json['resumo'] ?? 'Resumo não disponível',
      area: json['area'],
      isCompleted: false,
    );
  }
}

class TaskManager extends StatefulWidget {
  @override
  _TaskManagerState createState() => _TaskManagerState();
}

class _TaskManagerState extends State<TaskManager> {
  final List<Task> tasks = [];
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

  // Função para buscar as tarefas do banco
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erro ao processar os dados: $e'),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'Erro ao buscar as tarefas. Status: ${response.statusCode}, Body: ${response.body}'),
      ));
    }
  }

  // Função para adicionar tarefas ao banco
  Future<void> addTask() async {
    if (taskName.isNotEmpty &&
        taskDeadline.isNotEmpty &&
        taskPriority.isNotEmpty &&
        taskResponsible.isNotEmpty &&
        taskSummary.isNotEmpty &&
        taskArea.isNotEmpty) {
      try {
        DateTime parsedDate = DateFormat('dd/MM').parse(taskDeadline);

        var taskData = {
          'nome': taskName,
          'data_conclusao': DateFormat('yyyy-MM-dd').format(parsedDate),
          'responsavel': taskResponsible,
          'resumo': taskSummary,
          'prioridade': taskPriority,
          'area': taskArea,
        };

        var url = Uri.parse('http://localhost:8000/home/tarefas');

        var response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(taskData),
        );

        if (response.statusCode == 200) {
          setState(() {
            tasks.add(Task(
              name: taskName,
              deadline: parsedDate,
              isCompleted: false,
              priority: taskPriority,
              responsible: taskResponsible,
              summary: taskSummary,
              area: taskArea,
            ));
          });

          taskName = '';
          taskDeadline = '';
          taskPriority = '';
          taskResponsible = '';
          taskSummary = '';
          taskArea = '';

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
        SnackBar(content: Text('Preencha todos os campos corretamente!')),
      );
    }
  }

  void openAddTaskDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Adicionar Nova Tarefa'),
          content: Container(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(labelText: 'Nome da Tarefa'),
                    onChanged: (value) => taskName = value,
                  ),
                  TextField(
                    decoration:
                        InputDecoration(labelText: 'Data de Conclusão (DD/MM)'),
                    onChanged: (value) => taskDeadline = value,
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: 'Responsável'),
                    onChanged: (value) => taskResponsible = value,
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: 'Área'),
                    onChanged: (value) => taskArea = value,
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: 'Resumo'),
                    maxLines: 4,
                    onChanged: (value) => taskSummary = value,
                  ),
                  SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                        labelText: 'Prioridade (Baixa, Média, Alta)'),
                    onChanged: (value) => taskPriority = value,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Adicionar Tarefa'),
              onPressed: () {
                addTask();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showTaskDetails(Task task) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TaskDetailScreen(task: task),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gerenciador de Tarefas'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchTasks,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Lista de Tarefas',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: openAddTaskDialog,
                  child: Text('Adicionar Tarefa'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                var task = tasks[index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(task.name),
                    subtitle: Text(
                      'Prazo: ${DateFormat('dd/MM').format(task.deadline)}\nPrioridade: ${task.priority}\nResponsável: ${task.responsible}\nÁrea: ${task.area}',
                    ),
                    onTap: () => showTaskDetails(task),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TaskDetailScreen extends StatelessWidget {
  final Task task;

  TaskDetailScreen({required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(task.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Prazo: ${DateFormat('dd/MM').format(task.deadline)}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text('Prioridade: ${task.priority}'),
            SizedBox(height: 8),
            Text('Responsável: ${task.responsible}'),
            SizedBox(height: 8),
            Text('Área: ${task.area}'),
            SizedBox(height: 8),
            Text('Resumo: ${task.summary}'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }
}
