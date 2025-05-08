// Created by [Alice Pinheiro Da Silva] on [Date].
//Arquivo: metas_financeiras.dart
//Descrição: Este arquivo contém a implementação da página de Metas Financeiras, que permite aos usuários gerenciar suas metas financeiras.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
}

class MetasFinanceirasPage extends StatefulWidget {
  @override
  _MetasFinanceirasPageState createState() => _MetasFinanceirasPageState();
}

class _MetasFinanceirasPageState extends State<MetasFinanceirasPage> {
  final List<MetaFinanceira> _metas = [];

  final _nomeController = TextEditingController();
  final _valorAlvoController = TextEditingController();
  final _descricaoController = TextEditingController();

  bool _conquistaCriou3Metas = false;
  bool _conquistaConcluiuUmaMeta = false;

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
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _adicionarMeta() {
    final nome = capitalizar(_nomeController.text.trim());
    final valor = double.tryParse(_valorAlvoController.text.trim()) ?? 0.0;
    final descricao = capitalizar(_descricaoController.text.trim());

    if (nome.isEmpty || valor <= 0) return;

    setState(() {
      _metas.add(MetaFinanceira(
        nome: nome,
        valorAlvo: valor,
        descricao: descricao,
        dataCriacao: DateTime.now(),
      ));
      _checarConquistas();
    });

    _nomeController.clear();
    _valorAlvoController.clear();
    _descricaoController.clear();
  }

  void _alterarValor(int index, bool adicionar) {
    final TextEditingController valorController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(adicionar ? 'Adicionar valor' : 'Remover valor'),
          content: TextField(
            controller: valorController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Valor'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
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
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
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
            child: Column(
              children: [
                TextField(
                  controller: _nomeController,
                  decoration: const InputDecoration(labelText: 'Nome da Meta'),
                ),
                TextField(
                  controller: _valorAlvoController,
                  decoration: const InputDecoration(labelText: 'Valor Alvo'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _descricaoController,
                  decoration: const InputDecoration(labelText: 'Descrição (opcional)'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _adicionarMeta,
                  child: const Text('Criar Meta', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: _metas.length,
              itemBuilder: (context, index) {
                final meta = _metas[index];

                return Card(
                  color: _getCardColor(context, meta),
                  margin: const EdgeInsets.all(8),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              meta.nome,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            if (meta.concluida)
                              const Icon(Icons.emoji_events, color: Colors.green)
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
                                    content: const Text('Tem certeza que deseja excluir esta meta?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: const Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          setState(() => _metas.removeAt(index));
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
