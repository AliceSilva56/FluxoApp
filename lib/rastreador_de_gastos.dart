// Created by [Alice Pinheiro Da Silva].
// Arquivo: rastreador_de_gastos.dart
// Descrição: Este arquivo contém a implementação da página de Rastreador de Gastos, que permite aos usuários registrar e visualizar seus gastos.
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'notificacoes.dart';

class RastreadorDeGastos extends StatefulWidget {
  @override
  _RastreadorDeGastosEstado createState() => _RastreadorDeGastosEstado();
}

class _RastreadorDeGastosEstado extends State<RastreadorDeGastos> {
  final List<Map<String, dynamic>> _gastos = [];
  final TextEditingController _controladorNome = TextEditingController();
  final TextEditingController _controladorValor = TextEditingController();
  final TextEditingController _controladorDescricao = TextEditingController();
  String? _classificacaoSelecionada;
  String? _formaPagamentoSelecionada; // novo campo
  String? _erroNome;
  String? _erroValor;
  String? _erroClassificacao;
  String? _erroFormaPagamento; // novo erro

  final Map<String, String> _diasPt = {
    'Mon': 'Seg', 'Tue': 'Ter', 'Wed': 'Qua', 'Thu': 'Qui',
    'Fri': 'Sex', 'Sat': 'Sáb', 'Sun': 'Dom',
  };

  final List<String> _imagens = [
    'assets/img1.png', 'assets/img2.png', 'assets/img3.png', 'assets/img4.png',
    'assets/img5.png', 'assets/img6.png', 'assets/img7.png', 'assets/img8.png',
    'assets/img9.png', 'assets/img10.png'
  ];

  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _carregarGastos();
    _pageController = PageController(initialPage: 0);
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      _currentPage = (_currentPage + 1) % _imagens.length;
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _carregarGastos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? dadosGastos = prefs.getString('gastos');
    if (dadosGastos != null) {
      setState(() {
        _gastos.addAll(List<Map<String, dynamic>>.from(jsonDecode(dadosGastos)));
      });
    }
    await NotificacaoService.agendarNotificacaoSemanal(
      'Resumo Semanal', 'Veja quanto você gastou com desejos essa semana!',
    );
  }

  Future<void> _salvarGastos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gastos', jsonEncode(_gastos));
  }

  void _adicionarGasto() {
    final nome = _controladorNome.text.trim();
    final textoValor = _controladorValor.text.replaceAll(',', '.').trim();
    final valor = double.tryParse(textoValor);
    final descricao = _controladorDescricao.text.trim();

    setState(() {
      _erroNome = nome.isEmpty ? 'Preencha o nome do gasto' : null;
      _erroValor = (valor == null || valor <= 0) ? 'Insira um valor maior que zero' : null;
      _erroClassificacao = _classificacaoSelecionada == null ? 'Selecione uma classificação' : null;
      _erroFormaPagamento = _formaPagamentoSelecionada == null ? 'Selecione forma de pagamento' : null;
    });
    if (_erroNome != null || _erroValor != null || _erroClassificacao != null || _erroFormaPagamento != null) return;

    setState(() {
      _gastos.add({
        'nome': nome[0].toUpperCase() + nome.substring(1),
        'valor': valor,
        'classificacao': _classificacaoSelecionada,
        'formaPagamento': _formaPagamentoSelecionada, // novo
        'descricao': descricao,
        'data': DateTime.now().toIso8601String(),
      });
      _controladorNome.clear();
      _controladorValor.clear();
      _controladorDescricao.clear();
      _classificacaoSelecionada = null;
      _formaPagamentoSelecionada = null;
      _salvarGastos();

      final totalDesejo = _gastos.where((g) => g['classificacao'] == 'Desejo')
        .fold(0.0, (soma, g) => soma + g['valor']);
      if (totalDesejo > 100) {
        NotificacaoService.mostrarNotificacao(
          'Atenção!', 'Você já gastou R\$ ${totalDesejo.toStringAsFixed(2)} em desejos.',
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gasto adicionado, mais informações em detalhes'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Map<String, Map<String, double>> _calcularGastosPorDia() {
    final Map<String, Map<String, double>> gastosPorDia = {};
    for (var gasto in _gastos) {
      final data = DateTime.parse(gasto['data']);
      final diaIngles = DateFormat.E().format(data);
      final dia = _diasPt[diaIngles] ?? diaIngles;
      final valor = gasto['valor'];
      final classificacao = gasto['classificacao'];

      gastosPorDia[dia] ??= {'Necessidade': 0.0, 'Desejo': 0.0};
      gastosPorDia[dia]![classificacao] = (gastosPorDia[dia]![classificacao] ?? 0) + valor;
    }
    return gastosPorDia;
  }

  @override
  Widget build(BuildContext context) {
    final gastosPorDia = _calcularGastosPorDia();
    final bool telaPequena = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(title: Text('Controle Financeiro')),
      body: Column(
        children: [
          // Campos de entrada fixos no topo
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controladorNome,
                        decoration: InputDecoration(
                          labelText: 'Nome do Gasto', errorText: _erroNome,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _classificacaoSelecionada,
                        items: const [
                          DropdownMenuItem(value: 'Necessidade', child: Text('Necessidade')),
                          DropdownMenuItem(value: 'Desejo', child: Text('Desejo')),
                        ],
                        onChanged: (valor) => setState(() => _classificacaoSelecionada = valor),
                        decoration: InputDecoration(
                          labelText: 'Classificação', errorText: _erroClassificacao,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controladorValor,
                        decoration: InputDecoration(
                          labelText: 'Valor do Gasto', errorText: _erroValor,
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 150,
                      child: DropdownButtonFormField<String>(
                        value: _formaPagamentoSelecionada,
                        items: const [
                          DropdownMenuItem(value: 'cartao', child: Text('💳 Cartão')),
                          DropdownMenuItem(value: 'dinheiro', child: Text('💵 Dinheiro')),
                          DropdownMenuItem(value: 'parcelado', child: Text('📅 Parcelado')),
                        ],
                        onChanged: (valor) => setState(() => _formaPagamentoSelecionada = valor),
                        decoration: InputDecoration(
                          labelText: 'Pagto.', errorText: _erroFormaPagamento,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _controladorDescricao,
                        decoration: const InputDecoration(labelText: 'Descrição (opcional)'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _adicionarGasto,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  ),
                  child: const Text('Adicionar Gasto', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

    // Parte rolável
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  // Carrossel e dica lado a lado ou empilhados
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: telaPequena
                        ? Column(
                            children: [
                              SizedBox(
                                height: 290,
                                child: PageView.builder(
                                  controller: _pageController,
                                  itemCount: _imagens.length,
                                  itemBuilder: (context, index) => Card(
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.asset(
                                        _imagens[index],
                                        fit: BoxFit.contain,
                                        width: double.infinity,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: Card(
                                  color: Theme.of(context).brightness == Brightness.dark ? const Color.fromARGB(255, 33, 150, 243) : const Color.fromARGB(255, 33, 150, 243),
                                  child: const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("🧠 Dica bônus: Regra dos 50-30-20", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                                        SizedBox(height: 8),
                                        Text("50% para necessidades (aluguel, contas, comida)", style: TextStyle(color: Colors.white)),
                                        Text("30% para desejos (lazer, roupas, delivery)", style: TextStyle(color: Colors.white)),
                                        Text("20% para economia/investimentos", style: TextStyle(color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 250,
                                  child: PageView.builder(
                                    controller: _pageController,
                                    itemCount: _imagens.length,
                                    itemBuilder: (context, index) => Card(
                                      elevation: 4,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.asset(
                                          _imagens[index],
                                          fit: BoxFit.contain,
                                          width: double.infinity,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Card(
                                  color: Theme.of(context).brightness == Brightness.dark ? const Color.fromARGB(255, 33, 150, 243) : const Color.fromARGB(255, 33, 150, 243),
                                  child: const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("🧠 Dica bônus: Regra dos 50-30-20", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                                        SizedBox(height: 8),
                                        Text("50% para necessidades (aluguel, contas, comida)", style: TextStyle(color: Colors.white)),
                                        Text("30% para desejos (lazer, roupas, delivery)", style: TextStyle(color: Colors.white)),
                                        Text("20% para economia/investimentos", style: TextStyle(color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),

                  const SizedBox(height: 10),

                  // Gráfico de barras
                  Container(
                    height: 300,
                    padding: const EdgeInsets.all(16),
                    child: BarChart(
                      BarChartData(
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final dias = _diasPt.values.toList();
                                return Text(dias[value.toInt() % dias.length]);
                              },
                            ),
                          ),
                        ),
                        barGroups: _diasPt.values.map((dia) {
                          final valores = gastosPorDia[dia] ?? {'Necessidade': 0, 'Desejo': 0};
                          final x = _diasPt.values.toList().indexOf(dia);
                          return BarChartGroupData(
                            x: x,
                            barRods: [
                              BarChartRodData(toY: valores['Necessidade']!, color: Colors.blue, width: 8),
                              BarChartRodData(toY: valores['Desejo']!, color: Colors.red, width: 8),
                            ],
                          );
                        }).toList(),
                        gridData: FlGridData(show: true),
                        borderData: FlBorderData(show: false),
                        barTouchData: BarTouchData(enabled: true),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
