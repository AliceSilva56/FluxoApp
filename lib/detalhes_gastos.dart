// Created by [Alice Pinheiro Da Silva].
//Arquivo: detalhes_gastos.dart
//Descrição: Este arquivo contém a implementação da página de Detalhes dos Gastos, que permite aos usuários visualizar e gerenciar seus gastos financeiros.
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DetalhesGastos extends StatefulWidget {
  const DetalhesGastos({super.key});

  @override
  _DetalhesGastosEstado createState() => _DetalhesGastosEstado();
}

class _DetalhesGastosEstado extends State<DetalhesGastos> {
  List<Map<String, dynamic>> _gastos = [];
  String? _filtroClassificacao;
  String _buscaTexto = '';
  DateTime? _filtroData;

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
        _gastos.sort((a, b) => DateTime.parse(b['data']).compareTo(DateTime.parse(a['data'])));
      });
    }
  }

  Future<void> _salvarGastos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gastos', jsonEncode(_gastos));
  }

  List<Map<String, dynamic>> _filtrarGastos() {
    return _gastos.where((gasto) {
      final correspondeClassificacao = _filtroClassificacao == null || gasto['classificacao'] == _filtroClassificacao;
      final texto = _buscaTexto.toLowerCase();
      // Busca por nome ou valor
      final correspondeTexto = texto.isEmpty ||
        gasto['nome'].toString().toLowerCase().contains(texto) ||
        gasto['valor'].toString().contains(texto);
      final correspondeData = _filtroData == null ||
        (DateTime.tryParse(gasto['data'])?.day == _filtroData?.day &&
         DateTime.tryParse(gasto['data'])?.month == _filtroData?.month &&
         DateTime.tryParse(gasto['data'])?.year == _filtroData?.year);
      return correspondeClassificacao && correspondeTexto && correspondeData;
    }).toList();
  }

  String _resumirDescricao(String? texto) {
    if (texto == null || texto.trim().isEmpty) return 'Sem descrição';
    return texto.length > 40 ? '${texto.substring(0, 40)}...' : texto;
  }

  String _iconeFormaPagamento(String? tipo) {
    switch (tipo) {
      case 'cartao': return '💳';
      case 'dinheiro': return '💵';
      case 'parcelado': return '📅';
      default: return '';
    }
  }

  void _editarGasto(int indice) {
    final gasto = _gastos[indice];
    final controladorNome = TextEditingController(text: gasto['nome']);
    final controladorValor = TextEditingController(text: gasto['valor'].toString());
    final controladorDescricao = TextEditingController(text: gasto['descricao']);
    String? classificacaoSelecionada = gasto['classificacao'];
    String? formaSelecionada = gasto['formaPagamento'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Gasto'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controladorNome,
                  decoration: const InputDecoration(labelText: 'Nome do Gasto'),
                ),
                TextField(
                  controller: controladorValor,
                  decoration: const InputDecoration(labelText: 'Valor do Gasto'),
                  keyboardType: TextInputType.number,
                ),
                DropdownButtonFormField<String>(
                  value: classificacaoSelecionada,
                  items: const [
                    DropdownMenuItem(value: 'Necessidade', child: Text('Necessidade')),
                    DropdownMenuItem(value: 'Desejo', child: Text('Desejo')),
                  ],
                  onChanged: (v) => classificacaoSelecionada = v,
                  decoration: const InputDecoration(labelText: 'Classificação'),
                ),
                // Dropdown para editar forma de pagamento
                DropdownButtonFormField<String>(
                  value: formaSelecionada,
                  items: const [
                    DropdownMenuItem(value: 'cartao', child: Text('💳 Cartão')),
                    DropdownMenuItem(value: 'dinheiro', child: Text('💵 Dinheiro')),
                    DropdownMenuItem(value: 'parcelado', child: Text('📅 Parcelado')),
                  ],
                  onChanged: (v) => formaSelecionada = v,
                  decoration: const InputDecoration(labelText: 'Forma de Pagamento'),
                ),
                TextField(
                  controller: controladorDescricao,
                  decoration: const InputDecoration(labelText: 'Descrição (opcional)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
            TextButton(
              onPressed: () {
                setState(() {
                  _gastos[indice] = {
                    'nome': controladorNome.text,
                    'valor': double.tryParse(controladorValor.text) ?? 0.0,
                    'classificacao': classificacaoSelecionada,
                    'descricao': controladorDescricao.text,
                    'data': gasto['data'],
                    'formaPagamento': formaSelecionada,
                  };
                  _salvarGastos();
                });
                Navigator.of(context).pop();
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  void _excluirGasto(int indice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Gasto'),
        content: const Text('Tem certeza que deseja excluir?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              setState(() {
                _gastos.removeAt(indice);
                _salvarGastos();
              });
              Navigator.pop(context);
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _selecionarDataFiltro() async {
    DateTime? data = await showDatePicker(
      context: context,
      initialDate: _filtroData ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (data != null) setState(() => _filtroData = data);
  }

  void _mostrarDetalhesGasto(Map<String, dynamic> gasto) {
    final data = DateTime.tryParse(gasto['data'] ?? '');
    final dataFormatada = data != null
        ? '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year} ${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}'
        : 'Data inválida';

    final isNecessidade = gasto['classificacao'] == 'Necessidade';
    final descricaoTipo = isNecessidade
        ? 'Gasto essencial para sua sobrevivência ou obrigações.'
        : 'Gasto não essencial, voltado para lazer ou conforto.';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isNecessidade ? Colors.lightBlue : Colors.red,
          title: Row(
            children: [
              const Expanded(child: Text("Descrição do Gasto")),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(TextSpan(
                children: [
                  const TextSpan(text: 'Nome: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: gasto['nome']),
                ],
              )),
              const SizedBox(height: 4),
              Text.rich(TextSpan(
                children: [
                  const TextSpan(text: 'Valor: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: 'R\$ ${gasto['valor'].toStringAsFixed(2)}'),
                  // novo: ícone ao lado do valor
                  TextSpan(text: '  ${_iconeFormaPagamento(gasto['formaPagamento'])}'),
                ],
              )),
              const SizedBox(height: 4),
              Text.rich(TextSpan(
                children: [
                  const TextSpan(text: 'Descrição: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: gasto['descricao'] ?? 'Sem descrição'),
                ],
              )),
              const SizedBox(height: 4),
              Text.rich(TextSpan(
                children: [
                  const TextSpan(text: 'Classificação: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '${gasto['classificacao']}'),
                ],
              )),
              Padding(
                padding: const EdgeInsets.only(top: 2.0, bottom: 6.0),
                child: Text(
                  descricaoTipo,
                  style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ),
              const SizedBox(height: 4),
              Text.rich(TextSpan(
                children: [
                  const TextSpan(text: 'Forma de Pagamento: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: _iconeFormaPagamento(gasto['formaPagamento'])),
                ],
              )),
              const SizedBox(height: 4),
              Text.rich(TextSpan(
                children: [
                  const TextSpan(text: 'Data: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: dataFormatada),
                ],
              )),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final gastosFiltrados = _filtrarGastos();
    final double total = gastosFiltrados.fold(0.0, (sum, g) => sum + (g['valor'] ?? 0.0));
    final bool isSmall = MediaQuery.of(context).size.width < 360;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes dos Gastos')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Buscar por nome ou valor', prefixIcon: Icon(Icons.search)),
                  onChanged: (v) => setState(() => _buscaTexto = v),
                ),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButton<String>(
                        value: _filtroClassificacao,
                        items: const [
                          DropdownMenuItem(value: null, child: Text('Todos')),
                          DropdownMenuItem(value: 'Necessidade', child: Text('Necessidade')),
                          DropdownMenuItem(value: 'Desejo', child: Text('Desejo')),
                        ],
                        onChanged: (v) => setState(() => _filtroClassificacao = v),
                        hint: const Text('Filtrar Classificação'),
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.calendar_today), onPressed: _selecionarDataFiltro),
                    if (_filtroData != null)
                      IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() => _filtroData = null)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: gastosFiltrados.length,
              itemBuilder: (context, indice) {
                final gasto = gastosFiltrados[indice];
                final classificacaoCor = gasto['classificacao'] == 'Necessidade' ? Colors.blue : Colors.red;
                final data = DateTime.tryParse(gasto['data'])!;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: ListTile(
                    onTap: () => _mostrarDetalhesGasto(gasto),
                    title: RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context).style,
                        children: [
                          TextSpan(text: '${gasto['nome']} - ', style: const TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: gasto['classificacao'], style: TextStyle(color: classificacaoCor, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Valor: R\$ ${gasto['valor'].toStringAsFixed(2)} ${_iconeFormaPagamento(gasto['formaPagamento'])}'),
                        Text(_resumirDescricao(gasto['descricao'])),
                        Text('${data.day.toString().padLeft(2,'0')}/${data.month.toString().padLeft(2,'0')}/${data.year}'),
                      ],
                    ),
                    trailing: isSmall
                      ? null
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _editarGasto(indice)),
                            IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _excluirGasto(indice)),
                          ],
                        ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
