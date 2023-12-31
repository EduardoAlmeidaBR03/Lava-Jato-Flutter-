import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:primeiro_app/crud/cadastro_ordem_servico_screen.dart';
import 'package:primeiro_app/screens/listascreens/listaordemservico_screens.dart';
import 'package:primeiro_app/screens/ordem_servico_screen.dart';
import 'screens/clientes_screen.dart';
import 'screens/funcionarios_screen.dart';
import 'screens/carros_screen.dart';
import 'screens/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:primeiro_app/firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';

FirebaseDatabase database = FirebaseDatabase.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: web,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lava Jato Flutter',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: LoginPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  final List<Widget> _widgetOptions = <Widget>[
    ClientesScreen(),
    FuncionariosScreen(),
    CarrosScreen(),
    OrdemServicoScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onPopupMenuSelected(String value) {
    switch (value) {
      case 'cadastro_Clientes':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ClientesScreen()),
        );
        break;
      case 'cadastro_funcionario':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FuncionariosScreen()),
        );
        break;
      case 'cadastro_carro':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CarrosScreen()),
        );
        break;
      case 'cadastro_ordem_servico':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => OrdemServicoScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lava Jato'),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: _onPopupMenuSelected,
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: 'cadastro_Clientes',
                  child: Text('Cadastro de Cliente'),
                ),
                PopupMenuItem(
                  value: 'cadastro_funcionario',
                  child: Text('Cadastro de Funcionário'),
                ),
                PopupMenuItem(
                  value: 'cadastro_carro',
                  child: Text('Cadastro de Carros'),
                ),
                PopupMenuItem(
                  value: 'cadastro_ordem_servico',
                  child: Text('Ordens de Serviço'),
                ),
              ];
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('ordens_servico').where('situacao', isEqualTo: 'Aberta').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar os dados'));
          }
          List<DocumentSnapshot> ordens = snapshot.data!.docs;
          return ListView.builder(
            itemCount: ordens.length,
            itemBuilder: (context, index) {
              var ordem = ordens[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: ListTile(
                    title: Text('Carro: ${ordem['carro']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Placa: ${ordem['placa']}'),
                        Text('Funcionário: ${ordem['funcionario']}'),
                        Text('Situação: ${ordem['situacao']}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            _finalizarOrdemServico(ordem.id);
                          },
                          child: Text('Finalizar Ordem'),
                        ),
                      ],
                    ),
                    leading: Text('Cliente: ${ordem['cliente']}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ListaOrdemServicoScreen()),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CadastroOrdemServicoScreen()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Color.fromARGB(255, 29, 43, 122),
      ),
    );
  }


  void _finalizarOrdemServico(String ordemId) {
    FirebaseFirestore.instance.collection('ordens_servico').doc(ordemId).update({
      'situacao': 'Finalizada', 
    }).then((value) {
      print('Ordem de serviço finalizada com sucesso');
    }).catchError((error) {
      print('Erro ao finalizar ordem de serviço: $error');
    });
  }
}