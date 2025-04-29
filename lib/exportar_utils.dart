// Arquivo: rastreador_de_gastos.dart
import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart'; // Importação correta de Color
import 'package:intl/intl.dart';


Future<void> exportarParaPdf(List<Map<String, dynamic>> gastos) async {
  final pdf = pw.Document();

  // Dados de gastos para o gráfico de pizza
  double gastosNecessidade = 0;
  double gastosDesejo = 0;
  
  for (var gasto in gastos) {
    if (gasto['classificacao'] == 'necessidade') {
      gastosNecessidade += gasto['valor'];
    } else if (gasto['classificacao'] == 'desejo') {
      gastosDesejo += gasto['valor'];
    }
  }

  // Gerar gráfico de pizza
  final chart = PieChart(
    PieChartData(
      sections: [
        PieChartSectionData(value: gastosNecessidade, color: Color(0xFF4CAF50), title: 'Necessidades'),
        PieChartSectionData(value: gastosDesejo, color: Color(0xFFFF5722), title: 'Desejos'),
      ],
    ),
  );

  // Criar imagem do gráfico
  final repaintBoundary = RepaintBoundary(
    child: SizedBox(
      width: 300,
      height: 300,
      child: chart,
    ),
  );

  final boundaryKey = GlobalKey();
  final boundaryWidget = RepaintBoundary(
    key: boundaryKey,
    child: repaintBoundary,
  );

  final boundaryContext = boundaryKey.currentContext;
  pw.MemoryImage? pdfImage;
  if (boundaryContext != null) {
    final boundary = boundaryContext.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    final imageBytes = byteData!.buffer.asUint8List();

    pdfImage = pw.MemoryImage(imageBytes);
  }

  // Função para formatar a data
  String formatarData(DateTime data) {
    return DateFormat('dd/MM/yyyy - HH:mm').format(data);
  }

  // Adicionar gráfico ao PDF
  pdf.addPage(
    pw.MultiPage(
      build: (context) => [
        pw.Text('Relatório de Gastos', style: pw.TextStyle(fontSize: 24)),
        pw.SizedBox(height: 16),
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
        pw.SizedBox(height: 16),
        pw.Text('', style: pw.TextStyle(fontSize: 18)),
        if (pdfImage != null) pw.Image(pdfImage),
      ],
    ),
  );

  final bytes = await pdf.save();
  await Printing.sharePdf(bytes: bytes, filename: 'relatorio_gastos.pdf');
}
