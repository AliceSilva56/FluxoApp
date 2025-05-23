// Created by [Alice Pinheiro Da Silva].
// Arquivo: export_ultls.dart
// Descrição: Função para exportar dados de gastos para um arquivo PDF

import 'package:pdf/widgets.dart' as pw; // Importação do pacote pdf
import 'package:printing/printing.dart'; // Importação do pacote de impressão
import 'package:intl/intl.dart'; // Importação de intl para formatação de data

Future<void> exportarParaPdf(
  List<Map<String, dynamic>> gastos, {
  double? totalAtual,
  double? totalAnterior,
  double? diferenca,
  String? maisGasta,
  String? periodo,
}) async {
  final pdf = pw.Document();

  // Dados de gastos para o gráfico de pizza
  double gastosNecessidade = 0;
  double gastosDesejo = 0;

  for (var gasto in gastos) {
    if ((gasto['classificacao'] as String).toLowerCase() == 'necessidade') {
      gastosNecessidade += gasto['valor'];
    } else if ((gasto['classificacao'] as String).toLowerCase() == 'desejo') {
      gastosDesejo += gasto['valor'];
    }
  }

  // Função para formatar a data
  String formatarData(DateTime data) {
    return DateFormat('dd/MM/yyyy - HH:mm').format(data);
  }

  // Adicionar conteúdo ao PDF
  pdf.addPage(
    pw.MultiPage(
      build: (context) => [
        pw.Text('Relatório de Gastos', style: pw.TextStyle(fontSize: 24)),
        pw.SizedBox(height: 16),

        // RESUMO CARD
        if (totalAtual != null && totalAnterior != null && diferenca != null && maisGasta != null)
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (periodo != null)
                  pw.Text('Período: $periodo', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text('Total gasto: R\$ ${totalAtual.toStringAsFixed(2)}'),
                pw.Text('Categoria mais gasta: $maisGasta'),
                pw.Text(
                  'Diferença em relação ao período anterior: R\$ ${diferenca.abs().toStringAsFixed(2)}'
                  '${diferenca > 0 ? " a mais" : " a menos"}',
                ),
                pw.SizedBox(height: 8),
                pw.Text('Total Necessidades: R\$ ${gastosNecessidade.toStringAsFixed(2)}'),
                pw.Text('Total Desejos: R\$ ${gastosDesejo.toStringAsFixed(2)}'),
              ],
            ),
          ),
        if (totalAtual != null) pw.SizedBox(height: 16),

        // TABELA DE GASTOS
        pw.Table.fromTextArray(
          headers: ['Nome', 'Valor', 'Classificação', 'Descrição', 'Data'],
          data: gastos.map((g) {
            DateTime dataGasto = DateTime.parse(g['data']);
            String dataFormatada = formatarData(dataGasto);
            return [
              g['nome'] ?? '',
              g['valor'].toString(),
              g['classificacao'] ?? '',
              g['descricao'] ?? '',
              dataFormatada,
            ];
          }).toList(),
        ),
      ],
    ),
  );

  final bytes = await pdf.save();
  await Printing.sharePdf(bytes: bytes, filename: 'relatorio_gastos.pdf');
}