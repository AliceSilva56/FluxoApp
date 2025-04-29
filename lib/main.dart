// Arquivo: main.dart
import 'package:flutter/material.dart';
import 'rastreador_de_gastos.dart';
import 'grafico_de_gastos.dart';
import 'detalhes_gastos.dart';
import 'metas_financeiras.dart'; // ⬅️ Importa o arquivo de metas
import 'notificacoes.dart'; // ⬅️ Importa o arquivo de notificações

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificacaoService.inicializarNotificacoes(); // ⬅️ Ativa notificações
  runApp(const AplicativoPrincipal());
}

// Classe principal do aplicativo
class AplicativoPrincipal extends StatelessWidget {
  const AplicativoPrincipal({super.key});

  @override
   Widget build(BuildContext context) {
    return MaterialApp(
  title: 'Controle Financeiro',
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
  themeMode: ThemeMode.system, // Isso ativa o modo automático
  home: const TelaPrincipal(),
);

  }
}

// Tela principal com navegação entre as telas
class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  _TelaPrincipalEstado createState() => _TelaPrincipalEstado();
}

class _TelaPrincipalEstado extends State<TelaPrincipal> {
  int _indiceSelecionado = 0;

  // ⬇️ Incluímos a nova tela de Metas aqui
  final List<Widget> _telas = [
    RastreadorDeGastos(), // Tela do rastreador de gastos
    const GraficoDeGastos(), // Tela de gráficos
    const DetalhesGastos(), // Tela de detalhes dos gastos
    MetasFinanceirasPage(), // ✅ Tela de metas financeiras
  ];

  void _aoTocarNoItem(int indice) {
    setState(() {
      _indiceSelecionado = indice;
    });
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _telas[_indiceSelecionado],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceSelecionado,
        onTap: _aoTocarNoItem,
        backgroundColor: const Color(0xFF2196F3),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black,
        type: BottomNavigationBarType.fixed, // ⬅️ Permite mais de 3 itens
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Início',
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
            icon: Icon(Icons.flag), // ✅ Ícone para metas
            label: 'Metas',
          ),
          
        ],
      ),
    );
  }
}
