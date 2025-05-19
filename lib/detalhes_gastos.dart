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
        _gastos.sort((a, b) => DateTime.parse(b['data'])
            .compareTo(DateTime.parse(a['data'])));
      });
    }
  }

  Future<void> _salvarGastos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gastos', jsonEncode(_gastos));
  }

  List<Map<String, dynamic>> _filtrarGastos() {
    if (_filtroClassificacao == null) return _gastos;
    return _gastos
        .where((gasto) => gasto['classificacao'] == _filtroClassificacao)
        .toList();
  }

  String _resumirDescricao(String? texto) {
    if (texto == null || texto.trim().isEmpty) return 'Sem descrição';
    return texto.length > 40 ? '${texto.substring(0, 40)}...' : texto;
  }

  void _editarGasto(int indice) {
    final gasto = _gastos[indice];
    final TextEditingController controladorNome =
        TextEditingController(text: gasto['nome']);
    final TextEditingController controladorValor =
        TextEditingController(text: gasto['valor'].toString());
    final TextEditingController controladorDescricao =
        TextEditingController(text: gasto['descricao']);
    String? classificacaoSelecionada = gasto['classificacao'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Gasto'),
          content: Column(
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
                  DropdownMenuItem(
                    value: 'Necessidade',
                    child: Text('Necessidade'),
                  ),
                  DropdownMenuItem(
                    value: 'Desejo',
                    child: Text('Desejo'),
                  ),
                ],
                onChanged: (valor) {
                  setState(() {
                    classificacaoSelecionada = valor;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Classificação do Gasto',
                ),
              ),
              TextField(
                controller: controladorDescricao,
                decoration: const InputDecoration(labelText: 'Descrição (opcional)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _gastos[indice] = {
                    'nome': controladorNome.text,
                    'valor': double.tryParse(controladorValor.text) ?? 0.0,
                    'classificacao': classificacaoSelecionada,
                    'descricao': controladorDescricao.text,
                    'data': gasto['data'],
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
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir Gasto'),
          content: const Text('Tem certeza de que deseja excluir este gasto?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _gastos.removeAt(indice);
                  _salvarGastos();
                });
                Navigator.of(context).pop();
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
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
                  const TextSpan(
                      text: 'Nome: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: gasto['nome']),
                ],
              )),
              const SizedBox(height: 4),
              Text.rich(TextSpan(
                children: [
                  const TextSpan(
                      text: 'Valor: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: 'R\$ ${gasto['valor'].toStringAsFixed(2)}'),
                ],
              )),
              const SizedBox(height: 4),
              Text.rich(TextSpan(
                children: [
                  const TextSpan(
                      text: 'Descrição: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: gasto['descricao'] ?? 'Sem descrição'),
                ],
              )),
              const SizedBox(height: 4),
              Text.rich(TextSpan(
                children: [
                  const TextSpan(
                      text: 'Classificação: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
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
              Text.rich(TextSpan(
                children: [
                  const TextSpan(
                      text: 'Data: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
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
  final double total = gastosFiltrados.fold(
    0.0,
    (soma, gasto) => soma + (gasto['valor'] ?? 0.0),
  );

  final bool isSmallScreen = MediaQuery.of(context).size.width < 360;

  return Scaffold(
    appBar: AppBar(
      title: const Text('Detalhes dos Gastos'),
    ),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DropdownButton<String>(
            value: _filtroClassificacao,
            items: const [
              DropdownMenuItem(value: null, child: Text('Todos')),
              DropdownMenuItem(value: 'Necessidade', child: Text('Necessidade')),
              DropdownMenuItem(value: 'Desejo', child: Text('Desejo')),
            ],
            onChanged: (valor) {
              setState(() {
                _filtroClassificacao = valor;
              });
            },
            hint: const Text('Filtrar por Classificação'),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: gastosFiltrados.length,
            itemBuilder: (context, indice) {
              final gasto = gastosFiltrados[indice];
              final classificacaoCor = gasto['classificacao'] == 'Necessidade'
                  ? Colors.blue
                  : Colors.red;
              final data = DateTime.tryParse(gasto['data'] ?? '');
              final dataFormatada = data != null
                  ? '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}'
                  : 'Data inválida';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: ListTile(
                  onTap: () => _mostrarDetalhesGasto(gasto),
                  title: RichText(
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style,
                      children: [
                        TextSpan(
                          text: '${gasto['nome']} - ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: '${gasto['classificacao']}',
                          style: TextStyle(
                            color: classificacaoCor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Valor: R\$ ${gasto['valor'].toStringAsFixed(2)}'),
                      Text('Descrição: ${_resumirDescricao(gasto['descricao'])}'),
                      Text('Data: $dataFormatada'),
                      if (isSmallScreen)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editarGasto(indice),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _excluirGasto(indice),
                            ),
                          ],
                        ),
                    ],
                  ),
                  trailing: isSmallScreen
                      ? null
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editarGasto(indice),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _excluirGasto(indice),
                            ),
                          ],
                        ),
                ),
              );
            },
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).cardColor,
          child: Text(
            '${isSmallScreen ? 'R\$' : 'Total: R\$'} ${total.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
