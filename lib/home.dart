import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notas_diarias/anotacao_helper.dart';
import 'package:notas_diarias/model/note.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController _tituloController = TextEditingController();
  TextEditingController _descricaoController = TextEditingController();
  List<Note> _notes = List();
  var _db = AnotacaoHelper();

  _exibirTelaAlteracao({Note anotacao}) {

    if (anotacao != null) {
      _tituloController.text = anotacao.title;
      _descricaoController.text = anotacao.description;
    } else {
      _tituloController.clear();
      _descricaoController.clear();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(anotacao != null ? "Editar Anotação" : "Adicionar Anotação"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _tituloController,
                autofocus: true,
                decoration: InputDecoration(
                    labelText: "Título", hintText: "Digite o título"),
              ),
              TextField(
                  controller: _descricaoController,
                  decoration: InputDecoration(
                      labelText: "Descrição", hintText: "Digite a descrição"))
            ],
          ),
          actions: [
            FlatButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancelar")),
            FlatButton(
                onPressed: () {
                  if (anotacao != null) {
                    _editNote(anotacao);
                  } else {
                    _saveNote();
                  }
                  Navigator.pop(context);
                  _listNotes();
                },
                child: Text(anotacao != null ? "Atualizar" : "Salvar"))
          ],
        );
      },
    );
  }

  _formatarData(String data) {
    initializeDateFormatting("pt_BR");
    DateTime date = DateTime.parse(data);
    //return DateFormat("y/MM/dd HH:mm:ss").format(date);
    return DateFormat.yMd("pt_BR").format(date);
  }

  @override
  void initState() {
    super.initState();
    _listNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Minhas Anotações"),
        backgroundColor: Colors.lightGreen,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
                itemCount: _notes.length,
                itemBuilder: (context, index) {
                  final note = _notes[index];
                  return Card(
                    child: ListTile(
                        title: Text(note.title),
                        subtitle: Text("${_formatarData(note.date)} - ${note.description}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () {
                                _exibirTelaAlteracao(anotacao: note);
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(left: 16),
                                child: Icon(Icons.edit, color: Colors.green),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _deleteNote(note.id);
                                _listNotes();
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(left: 16),
                                child: Icon(Icons.remove_circle, color: Colors.red),
                              ),
                            )
                          ],
                        ),
                    ),
                  );
                }),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
        onPressed: () {
          _exibirTelaAlteracao();
        },
      ),
    );
  }

  void _saveNote() async {
    String title = _tituloController.text;
    String description = _descricaoController.text;

    Note note = Note(title, description, DateTime.now().toString());
    int resultado = await _db.salvarAnotacao(note);

    _tituloController.clear();
    _descricaoController.clear();
  }

  /*_listNotes() async {
    List notes = await _db.listarAnotacoes();
    List<Note> tempList = List();
    for(var n in notes) {
      Note note = Note.fromMap(n);
      tempList.add(note);
    }
    setState(() {
      _notes = tempList;
    });
    tempList = null;
  }*/

  _listNotes() async {
    List notes = await _db.listarAnotacoes();

    setState(() {
      _notes = notes.map((note) => Note.fromMap(note)).toList();
    });

  }

  void _deleteNote(int id) async {
    await _db.removerAnotacao(id);
  }

  void _editNote(Note anotacao) async {
    String title = _tituloController.text;
    String description = _descricaoController.text;

    anotacao.title = title;
    anotacao.description = description;
    anotacao.date = DateTime.now().toString();

    await _db.atualizarAnotacao(anotacao);
  }
}
