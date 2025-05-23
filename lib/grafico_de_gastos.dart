// Created by [Alice Pinheiro Da Silva]
// Arquivo: grafico_de_gasto.dart
// Descrição: Esta página exibe gráficos de gastos e permite exportar resumo e detalhes em PDF.
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'exportar_utils.dart';

class GraficoDeGastos extends StatefulWidget {
  const GraficoDeGastos({super.key});

  @override
  GraficoDeGastosEstado createState() => GraficoDeGastosEstado();
}

class GraficoDeGastosEstado extends State<GraficoDeGastos> {
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

  double _calcularTotalGasto(List<Map<String, dynamic>> gastos) {
    return gastos.fold(0.0, (soma, gasto) => soma + (gasto['valor'] ?? 0));
  }

  String _categoriaMaisGasta(List<Map<String, dynamic>> gastos) {
    final Map<String, double> totais = {};
    for (var gasto in gastos) {
      final classificacao = gasto['classificacao'];
      final valor = gasto['valor'] ?? 0.0;
      totais[classificacao] = (totais[classificacao] ?? 0.0) + valor;
    }

    String maisGasta = '';
    double maiorValor = 0.0;
    totais.forEach((categoria, valor) {
      if (valor > maiorValor) {
        maiorValor = valor;
        maisGasta = categoria;
      }
    });

    return maisGasta;
  }

  List<Map<String, dynamic>> _filtrarPorPeriodo(String periodo) {
    final agora = DateTime.now();
    final inicioPeriodo = periodo == 'Semanal'
        ? agora.subtract(const Duration(days: 7))
        : DateTime(agora.year, agora.month - 1, agora.day);

    return _gastos.where((gasto) {
      final data = DateTime.tryParse(gasto['data'] ?? '');
      return data != null && data.isAfter(inicioPeriodo);
    }).toList();
  }

  List<Map<String, dynamic>> _filtrarPeriodoAnterior(String periodo) {
    final agora = DateTime.now();
    DateTime inicioAnterior;
    DateTime fimAnterior;

    if (periodo == 'Semanal') {
      fimAnterior = agora.subtract(const Duration(days: 7));
      inicioAnterior = fimAnterior.subtract(const Duration(days: 7));
    } else {
      fimAnterior = DateTime(agora.year, agora.month, 0);
      inicioAnterior = DateTime(agora.year, agora.month - 1, 1);
    }

    return _gastos.where((gasto) {
      final data = DateTime.tryParse(gasto['data'] ?? '');
      return data != null && data.isAfter(inicioAnterior) && data.isBefore(fimAnterior);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final larguraTela = MediaQuery.of(context).size.width;
    final gastosPeriodo = _filtrarPorPeriodo(_periodoSelecionado);
    final gastosAnterior = _filtrarPeriodoAnterior(_periodoSelecionado);

    final totalAtual = _calcularTotalGasto(gastosPeriodo);
    final totalAnterior = _calcularTotalGasto(gastosAnterior);
    final diferenca = totalAtual - totalAnterior;
    final maisGasta = _categoriaMaisGasta(gastosPeriodo);

    final porcentagemNecessidade = _calcularPorcentagem('Necessidade');
    final porcentagemDesejo = _calcularPorcentagem('Desejo');
    final totalNecessidade = _contarGastos('Necessidade');
    final totalDesejo = _contarGastos('Desejo');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gráficos de Gastos'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
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
                            _buildGraficoPizza(porcentagemNecessidade, porcentagemDesejo),
                            const SizedBox(width: 20),
                            _buildLegenda(porcentagemNecessidade, totalNecessidade, porcentagemDesejo, totalDesejo),
                          ],
                        )
                      : Column(
                          children: [
                            _buildGraficoPizza(porcentagemNecessidade, porcentagemDesejo),
                            const SizedBox(height: 20),
                            _buildLegenda(porcentagemNecessidade, totalNecessidade, porcentagemDesejo, totalDesejo),
                          ],
                        ),
                  const SizedBox(height: 30),
                  _buildResumoCard(totalAtual, maisGasta, diferenca),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                                ElevatedButton.icon(                  
                  onPressed: () async {
                    await exportarParaPdf(
                      _gastos,
                      totalAtual: totalAtual,
                      totalAnterior: totalAnterior,
                      diferenca: diferenca,
                      maisGasta: maisGasta,
                      periodo: _periodoSelecionado,
                    );
                  },
                  icon: const Icon(Icons.picture_as_pdf, size: 18),
                  label: const Text('PDF', style: TextStyle(fontSize: 14)),
                  // ...restante do botão...
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGraficoPizza(double porcentagemNecessidade, double porcentagemDesejo) {
    return SizedBox(
      width: 150,
      height: 150,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(color: Colors.blue, value: porcentagemNecessidade, title: '', radius: 50),
            PieChartSectionData(color: Colors.red, value: porcentagemDesejo, title: '', radius: 50),
          ],
          sectionsSpace: 2,
          centerSpaceRadius: 30,
        ),
      ),
    );
  }

  Widget _buildLegenda(double porcentagemNecessidade, int totalNecessidade, double porcentagemDesejo, int totalDesejo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 16, height: 16, color: Colors.blue),
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
            Container(width: 16, height: 16, color: Colors.red),
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
    );
  }

  Widget _buildResumoCard(double totalAtual, String maisGasta, double diferenca) {
    final corComparacao = diferenca > 0 ? Colors.red : Colors.green;
    final icone = diferenca > 0 ? Icons.arrow_upward : Icons.arrow_downward;
    final textoComparacao = diferenca > 0 ? 'a mais que o período anterior' : 'a menos que o período anterior';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(top: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Resumo do Período',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.paid, color: Colors.green),
                const SizedBox(width: 8),
                Text('Total gasto: R\$ ${totalAtual.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.category, color: Colors.blue),
                const SizedBox(width: 8),
                Text('Categoria mais gasta: $maisGasta'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(icone, color: corComparacao),
                const SizedBox(width: 8),
                Text(
                  'R\$ ${diferenca.abs().toStringAsFixed(2)} $textoComparacao',
                  style: TextStyle(color: corComparacao),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
