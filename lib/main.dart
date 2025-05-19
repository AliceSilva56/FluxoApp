// Created by [Alice Pinheiro Da Silva]
// Arquivo: main.dart
// Descrição: Este arquivo contém a implementação do aplicativo de controle financeiro, que permite aos usuários rastrear seus gastos, visualizar gráficos e gerenciar metas financeiras.
import 'package:flutter/material.dart'; //⬅️ Importa o pacote Flutter
import 'package:shared_preferences/shared_preferences.dart'; //⬅️ Importa o pacote de preferências compartilhadas
import 'perfil_page.dart'; //⬅️ Importa o arquivo de perfil
import 'rastreador_de_gastos.dart'; //⬅️ Importa o arquivo de rastreador de gastos
import 'metas_financeiras.dart'; //⬅️ Importa o arquivo de metas financeiras
import 'grafico_de_gastos.dart'; //⬅️ Importa o arquivo de gráfico de gastos
import 'detalhes_gastos.dart'; //⬅️ Importa o arquivo de detalhes de gastos
import 'notificacoes.dart';  //⬅️ Importa o arquivo de notificações

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificacaoService.inicializarNotificacoes();
  runApp(const FluxoApp());
}

class FluxoApp extends StatefulWidget {
  const FluxoApp({Key? key}) : super(key: key);

  @override
  State<FluxoApp> createState() => _FluxoAppState();
}

class _FluxoAppState extends State<FluxoApp> {
  ThemeMode _tema = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _carregarTema();
  }

  Future<void> _carregarTema() async {
    final prefs = await SharedPreferences.getInstance();
    final temaSalvo = prefs.getString('tema') ?? 'system';
    setState(() {
      _tema = {
        'light': ThemeMode.light,
        'dark': ThemeMode.dark,
        'system': ThemeMode.system,
      }[temaSalvo]!;
    });
  }

  void _mudarTema(ThemeMode novoTema) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tema', novoTema.name);
    setState(() {
      _tema = novoTema;
    });
  }

  int _paginaSelecionada = 0;

  final List<Widget> _telas = [
    RastreadorDeGastos(),
    MetasFinanceirasPage(),
    const GraficoDeGastos(),
    const DetalhesGastos(),
    Container(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FluxoApp',
      debugShowCheckedModeBanner: false, // Remove o banner de debug
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
      ),
      themeMode: _tema,
      home: Scaffold(
        body: _paginaSelecionada == 4
            ? PerfilPage(onThemeChanged: _mudarTema)
            : _telas[_paginaSelecionada],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _paginaSelecionada,
          onTap: (index) {
            setState(() {
              _paginaSelecionada = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.black,
          backgroundColor: const Color(0xFF2196F3),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Início',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.flag),
              label: 'Metas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.pie_chart),
              label: 'Gráficos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: 'Detalhes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
// Descrição do projeto:
// Data de inicialização: [terça-feira, 8 de abril de 2025]
// Desenvolvedora: [Alice Pinheiro Da Silva]
// Este projeto é um aplicativo de controle financeiro desenvolvido em Flutter.
// Comecei esse projeto com o intuito de aprender mais sobre o Flutter e suas funcionalidades.
// O objetivo principal é ajudar os usuários a gerenciar suas finanças pessoais de forma eficaz.
// A ideia inicial era criar um aplicativo de controle financeiro, mas com o tempo, percebi que poderia expandir as funcionalidades e torná-lo mais completo.
// O aplicativo agora possui recursos como categorização de gastos, gráficos de despesas e a capacidade de exportar dados para PDF.
// Estou animada para continuar aprimorando este projeto e adicionar mais recursos no futuro.
// Espero que este aplicativo ajude as pessoas a gerenciar suas finanças de forma mais eficaz e a tomar decisões financeiras mais informadas.
// Se você tiver alguma dúvida ou sugestão, sinta-se à vontade para entrar em contato comigo.