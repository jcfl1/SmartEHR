import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:anotai_fisio/models/prontuario.dart';
import 'dart:convert';

class CustomizeView extends StatefulWidget {
  @override
  _ModelosScreenState createState() => _ModelosScreenState();

  const CustomizeView({super.key});
}

class _ModelosScreenState extends State<CustomizeView> {
  List<Modelo> modelos = [];
  _ModelosScreenState();

  @override
  void initState() {
    super.initState();
    loadModelos();
  }

  Future<void> loadModelos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> modelosStringList = prefs.getStringList('modelos') ?? [];
    List<Modelo> modelosList = modelosStringList.map((modelString) {
      Map<String, dynamic> map = json.decode(modelString);
      return Modelo.fromMap(map);
    }).toList();
    setState(() {
      modelos = modelosList;
    });
  }

  void salvarModelo(Modelo novoModelo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    modelos.add(novoModelo);
    List<String> modelosStringList = modelos.map((model) {
      Map<String, dynamic> map = model.toMap();
      return json.encode(map);
    }).toList();
    await prefs.setStringList('modelos', modelosStringList);
    setState(() {});
  }

  void removerModelo(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String modeloRemovido = modelos[index].nome;
    modelos.removeAt(index);
    List<String> modelosStringList = modelos.map((model) {
      Map<String, dynamic> map = model.toMap();
      return json.encode(map);
    }).toList();
    await prefs.setStringList('modelos', modelosStringList);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Modelo "$modeloRemovido" removido com sucesso.'),
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modelos'),
        backgroundColor: const Color(0xff552a7f),
      ),
      body: ListView.builder(
        itemCount: modelos.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 2.0,
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditScreen(modelo: modelos[index]),
                  ),
                );
              },
              title: Text(modelos[index].nome),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  removerModelo(index);
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff552a7f),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NovoModeloScreen(),
            ),
          ).then((novoModelo) {
            if (novoModelo != null) {
              salvarModelo(novoModelo);
            }
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class EditScreen extends StatefulWidget {
  final Modelo modelo;

  const EditScreen({super.key, required this.modelo});

  @override
  _EditScreenState createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  List<String> campos = [];
  int campoCount = 0;

  _EditScreenState();

  @override
  void initState() {
    super.initState();
    campos = widget.modelo.campos;
  }

  void removerCampo(int index) {
    setState(() {
      campos.removeAt(index);
    });
  }

  void salvarCampos() async {
    widget.modelo.campos = campos;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> modelosStringList = prefs.getStringList('modelos') ?? [];
    List<String> novosModelosStringList = modelosStringList.map((modelString) {
      Map<String, dynamic> map = json.decode(modelString);
      if (map['nome'] == widget.modelo.nome) {
        map['campos'] = campos;
      }
      return json.encode(map);
    }).toList();
    await prefs.setStringList('modelos', novosModelosStringList);
  }

  @override
  Widget build(BuildContext context) {
    double fem = .9;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.modelo.nome),
        backgroundColor: const Color(0xff552a7f),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          const Padding(
              padding: EdgeInsets.all(12),
              child: Text("Campos",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ))),
          Expanded(
            child: ListView.builder(
              itemCount: campos.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: <Widget>[
                    Container(
                        width: double.infinity,
                        margin: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1),
                          borderRadius: BorderRadius.circular(5),
                          shape: BoxShape.rectangle,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(campos[index]),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                removerCampo(index);
                              },
                            ),
                          ],
                        )),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        color: Colors.white,
                        child: Text(
                          'Campo ${index + 1}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    width: 66 * fem,
                    height: 66 * fem,
                    decoration: const ShapeDecoration(
                        shape: CircleBorder(eccentricity: 1),
                        color: Color(0xff552a7f)),
                    child: IconButton.filled(
                      icon: const Icon(Icons.save),
                      color: Colors.white,
                      onPressed: () {
                        salvarCampos();
                        Navigator.of(context).pop();
                      },
                    )),
                Container(
                    width: 66 * fem,
                    height: 66 * fem,
                    decoration: const ShapeDecoration(
                        shape: CircleBorder(eccentricity: 1),
                        color: Color(0xff552a7f)),
                    child: IconButton.filled(
                      icon: const Icon(Icons.add),
                      color: Colors.white,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NovoCampoScreen(),
                          ),
                        ).then((novoCampo) {
                          if (novoCampo != null) {
                            setState(() {
                              campoCount++;
                              campos.add(novoCampo);
                            });
                          }
                        });
                        salvarCampos();
                      },
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NovoModeloScreen extends StatelessWidget {
  final TextEditingController _modeloController = TextEditingController();

  NovoModeloScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Modelo'),
        backgroundColor: const Color(0xff552a7f),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Novo Modelo',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _modeloController,
              decoration: const InputDecoration(
                labelText: 'Nome do Modelo',
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff552a7f),
              ),
              onPressed: () {
                String nomeModelo = _modeloController.text;
                if (nomeModelo.isNotEmpty) {
                  Modelo novoModelo = Modelo(nome: nomeModelo, campos: []);
                  Navigator.pop(context, novoModelo);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditScreen(modelo: novoModelo),
                    ),
                  );
                }
              },
              child: const Text('Adicionar Modelo'),
            ),
          ],
        ),
      ),
    );
  }
}

class NovoCampoScreen extends StatelessWidget {
  final TextEditingController _campoController = TextEditingController();

  NovoCampoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Campo'),
        backgroundColor: const Color(0xff552a7f),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Novo Campo',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _campoController,
              decoration: const InputDecoration(
                labelText: 'Nome do Campo',
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                String novoCampo = _campoController.text;
                Navigator.pop(context, novoCampo);
              },
              style:
                  ElevatedButton.styleFrom(backgroundColor: const Color(0xff552a7f)),
              child: const Text('Adicionar Campo'),
            ),
          ],
        ),
      ),
    );
  }
}
