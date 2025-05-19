// Created by [Alice Pinheiro Da Silva].
//Arquivo: metas_financeiras.dart
//Descrição: Este arquivo contém a implementação da página de Metas Financeiras, que permite aos usuários gerenciar suas metas financeiras.

import 'dart:convert'; // Importação para manipulação de JSON
import 'package:flutter/material.dart'; // Importação do Flutter para widgets e UI
import 'package:intl/intl.dart'; // Importação para formatação de datas
import 'package:shared_preferences/shared_preferences.dart'; // Importação para armazenamento local

class MetaFinanceira {
  String nome;
  double valorAlvo;
  double valorAtual;
  String descricao;
  final DateTime dataCriacao;
  DateTime? dataConclusao;

  MetaFinanceira({
    required this.nome,
    required this.valorAlvo,
    this.valorAtual = 0.0,
    this.descricao = '',
    required this.dataCriacao,
    this.dataConclusao,
  });

  bool get concluida => valorAtual >= valorAlvo;
  double get progresso => valorAtual / valorAlvo;
  double get valorRestante => valorAlvo - valorAtual;
  bool get quaseConcluida => progresso >= 0.75 && !concluida;
  bool get parada => DateTime.now().difference(dataCriacao).inDays > 30 && valorAtual == 0;

  Map<String, dynamic> toJson() => {
        'nome': nome,
        'valorAlvo': valorAlvo,
        'valorAtual': valorAtual,
        'descricao': descricao,
        'dataCriacao': dataCriacao.toIso8601String(),
        'dataConclusao': dataConclusao?.toIso8601String(),
      };

  factory MetaFinanceira.fromJson(Map<String, dynamic> json) => MetaFinanceira(
        nome: json['nome'],
        valorAlvo: json['valorAlvo'],
        valorAtual: json['valorAtual'],
        descricao: json['descricao'],
        dataCriacao: DateTime.parse(json['dataCriacao']),
        dataConclusao: json['dataConclusao'] != null ? DateTime.parse(json['dataConclusao']) : null,
      );
}

class MetasFinanceirasPage extends StatefulWidget {
  @override
  _MetasFinanceirasPageState createState() => _MetasFinanceirasPageState();
}

class _MetasFinanceirasPageState extends State<MetasFinanceirasPage> {
  final List<MetaFinanceira> _metas = [];

  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _valorAlvoController = TextEditingController();
  final _descricaoController = TextEditingController();

  bool _conquistaCriou3Metas = false;
  bool _conquistaConcluiuUmaMeta = false;

  @override
  void initState() {
    super.initState();
    _carregarMetas();
  }

  Future<void> _carregarMetas() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('metasFinanceiras');
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      setState(() {
        _metas.clear();
        _metas.addAll(jsonList.map((e) => MetaFinanceira.fromJson(e)));
      });
    }
  }

  Future<void> _salvarMetas() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _metas.map((m) => m.toJson()).toList();
    prefs.setString('metasFinanceiras', jsonEncode(jsonList));
  }

  String capitalizar(String texto) {
    if (texto.isEmpty) return '';
    return texto[0].toUpperCase() + texto.substring(1);
  }

  void _checarConquistas() {
    if (!_conquistaCriou3Metas && _metas.length >= 3) {
      _conquistaCriou3Metas = true;
      _mostrarConquista('🏆 Criou 3 metas!');
    }
    if (!_conquistaConcluiuUmaMeta && _metas.any((m) => m.concluida)) {
      _conquistaConcluiuUmaMeta = true;
      _mostrarConquista('🎯 Concluiu sua primeira meta!');
    }
  }

  void _mostrarConquista(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: Colors.amber,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _adicionarMeta() {
    if (_formKey.currentState!.validate()) {
      final nome = capitalizar(_nomeController.text.trim());
      final valor = double.tryParse(_valorAlvoController.text.trim()) ?? 0.0;
      final descricao = capitalizar(_descricaoController.text.trim());

      setState(() {
        _metas.add(MetaFinanceira(
          nome: nome,
          valorAlvo: valor,
          descricao: descricao,
          dataCriacao: DateTime.now(),
        ));
        _checarConquistas();
        _salvarMetas();
      });

      _formKey.currentState!.reset();
      _nomeController.clear();
      _valorAlvoController.clear();
      _descricaoController.clear();
    }
  }

  void _alterarValor(int index, bool adicionar) {
    final TextEditingController valorController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(adicionar ? 'Adicionar valor' : 'Remover valor'),
        content: TextField(
          controller: valorController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Valor'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              final valor = double.tryParse(valorController.text.trim()) ?? 0.0;
              if (valor > 0) {
                setState(() {
                  if (adicionar) {
                    _metas[index].valorAtual += valor;
                  } else {
                    _metas[index].valorAtual = (_metas[index].valorAtual - valor).clamp(0.0, double.infinity);
                  }
                  if (_metas[index].concluida) {
                    _metas[index].dataConclusao = DateTime.now();
                    _checarConquistas();
                  }
                  _salvarMetas();
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  Color _getCardColor(BuildContext context, MetaFinanceira meta) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (meta.concluida) {
      return isDark ? Colors.green.shade700 : Colors.green.shade100;
    } else if (meta.quaseConcluida) {
      return isDark ? Colors.yellow.shade800 : Colors.yellow.shade100;
    } else if (meta.parada) {
      return isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    } else {
      return Theme.of(context).cardColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatador = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('Metas Financeiras')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nomeController,
                    decoration: const InputDecoration(
                      labelText: 'Nome da Meta',
                      errorStyle: TextStyle(color: Colors.redAccent),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Campo obrigatório' : null,
                  ),
                  TextFormField(
                    controller: _valorAlvoController,
                    decoration: const InputDecoration(
                      labelText: 'Valor Alvo',
                      errorStyle: TextStyle(color: Colors.redAccent),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Campo obrigatório';
                      final valor = double.tryParse(value);
                      if (valor == null || valor <= 0) return 'Valor deve ser maior que zero';
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _descricaoController,
                    decoration: const InputDecoration(labelText: 'Descrição (opcional)'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _adicionarMeta,
                    child: const Text('Criar Meta'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: _metas.length,
              itemBuilder: (context, index) {
                final meta = _metas[index];
                return Card(
                  color: _getCardColor(context, meta),
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(meta.nome, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            if (meta.concluida) const Icon(Icons.emoji_events, color: Colors.green)
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('Criada em: ${formatador.format(meta.dataCriacao)}'),
                        if (meta.descricao.isNotEmpty) Text('📌 ${meta.descricao}'),
                        const SizedBox(height: 8),
                        Text('Progresso: R\$ ${meta.valorAtual.toStringAsFixed(2)} / R\$ ${meta.valorAlvo.toStringAsFixed(2)}'),
                        Text('Faltam: R\$ ${meta.valorRestante > 0 ? meta.valorRestante.toStringAsFixed(2) : '0.00'}'),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: meta.progresso.clamp(0.0, 1.0),
                          minHeight: 10,
                          backgroundColor: Colors.grey.shade300,
                          color: meta.concluida ? Colors.green : Colors.blue,
                        ),
                        if (meta.concluida)
                          const Padding(
                            padding: EdgeInsets.only(top: 4.0),
                            child: Text('🎉 Meta concluída!', style: TextStyle(color: Colors.green)),
                          ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          alignment: WrapAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              tooltip: 'Editar meta',
                              onPressed: () {
                                _nomeController.text = meta.nome;
                                _valorAlvoController.text = meta.valorAlvo.toString();
                                _descricaoController.text = meta.descricao;
                                setState(() => _metas.removeAt(index));
                                _salvarMetas();
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: 'Excluir meta',
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Confirmar Exclusão'),
                                    content: const Text('Deseja excluir esta meta?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
                                      TextButton(
                                        onPressed: () {
                                          setState(() => _metas.removeAt(index));
                                          _salvarMetas();
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Excluir', style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove, color: Colors.red),
                              onPressed: () => _alterarValor(index, false),
                              tooltip: 'Remover valor',
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, color: Colors.green),
                              onPressed: () => _alterarValor(index, true),
                              tooltip: 'Adicionar valor',
                            ),
                          ],
                        ),
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
