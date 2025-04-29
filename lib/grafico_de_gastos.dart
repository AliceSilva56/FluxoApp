// Arquivo: grafico_de_gasto.dart
// Importações necessárias
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'exportar_utils.dart';

class GraficoDeGastos extends StatefulWidget {
  const GraficoDeGastos({super.key});

  @override
  _GraficoDeGastosEstado createState() => _GraficoDeGastosEstado();
}

class _GraficoDeGastosEstado extends State<GraficoDeGastos> {
  String _periodoSelecionado = 'Mensal';
  List<Map<String, dynamic>> _gastos = [];

  @override
  void initState() {
    super.initState();
    _carregarGastos();
  }

  Future<void> _carregarGastos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? dadosGastos = prefs.getString('gastos');
    if (dadosGastos != null) {
      setState(() {
        _gastos = List<Map<String, dynamic>>.from(jsonDecode(dadosGastos));
      });
    }
  }

  double _calcularPorcentagem(String classificacao) {
    final totalGeral = _gastos.fold(0.0, (soma, gasto) => soma + gasto['valor']);
    final totalClassificacao = _gastos
        .where((gasto) => gasto['classificacao'] == classificacao)
        .fold(0.0, (soma, gasto) => soma + gasto['valor']);
    return totalGeral > 0 ? (totalClassificacao / totalGeral) * 100 : 0.0;
  }

  int _contarGastos(String classificacao) {
    return _gastos
        .where((gasto) => gasto['classificacao'] == classificacao)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final larguraTela = MediaQuery.of(context).size.width;
    final double porcentagemNecessidade = _calcularPorcentagem('Necessidade');
    final double porcentagemDesejo = _calcularPorcentagem('Desejo');
    final int totalNecessidade = _contarGastos('Necessidade');
    final int totalDesejo = _contarGastos('Desejo');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gráficos de Gastos'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  DropdownButton<String>(
                    value: _periodoSelecionado,
                    items: const [
                      DropdownMenuItem(value: 'Semanal', child: Text('Semanal')),
                      DropdownMenuItem(value: 'Mensal', child: Text('Mensal')),
                    ],
                    onChanged: (valor) {
                      setState(() {
                        _periodoSelecionado = valor!;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  larguraTela > 400
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 150,
                              height: 150,
                              child: PieChart(
                                PieChartData(
                                  sections: [
                                    PieChartSectionData(
                                      color: Colors.blue,
                                      value: porcentagemNecessidade,
                                      title: '',
                                      radius: 50,
                                    ),
                                    PieChartSectionData(
                                      color: Colors.red,
                                      value: porcentagemDesejo,
                                      title: '',
                                      radius: 50,
                                    ),
                                  ],
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 30,
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      color: Colors.blue,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('Necessidade:'),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${porcentagemNecessidade.toStringAsFixed(1)}% - $totalNecessidade gastos',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      color: Colors.red,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('Desejo:'),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${porcentagemDesejo.toStringAsFixed(1)}% - $totalDesejo gastos',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            SizedBox(
                              width: 150,
                              height: 150,
                              child: PieChart(
                                PieChartData(
                                  sections: [
                                    PieChartSectionData(
                                      color: Colors.blue,
                                      value: porcentagemNecessidade,
                                      title: '',
                                      radius: 50,
                                    ),
                                    PieChartSectionData(
                                      color: Colors.red,
                                      value: porcentagemDesejo,
                                      title: '',
                                      radius: 50,
                                    ),
                                  ],
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 30,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      color: Colors.blue,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('Necessidade:'),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${porcentagemNecessidade.toStringAsFixed(1)}% - $totalNecessidade gastos',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      color: Colors.red,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('Desejo:'),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${porcentagemDesejo.toStringAsFixed(1)}% - $totalDesejo gastos',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ),

          // Botões de exportar no rodapé
          Container(
            color: const Color.fromARGB(255, 255, 255, 255),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => exportarParaPdf(_gastos),
                  icon: const Icon(Icons.picture_as_pdf, size: 18),
                  label: const Text('PDF', style: TextStyle(fontSize: 14)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
