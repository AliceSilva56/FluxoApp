// Arquivo: rastreador_de_gastos.dart
import 'package:flutter/material.dart';
import 'dart:async'; // Para usar Timer no carrossel
import 'dart:convert'; // Para converter JSON
import 'package:shared_preferences/shared_preferences.dart'; // Armazenamento local
import 'package:intl/intl.dart'; // Para formatar datas
import 'package:fl_chart/fl_chart.dart'; // Pacote para gráficos de barras
import 'notificacoes.dart'; // Importa o arquivo de notificações

// Widget principal com estado
class RastreadorDeGastos extends StatefulWidget {
  @override
  _RastreadorDeGastosEstado createState() => _RastreadorDeGastosEstado();
}

class _RastreadorDeGastosEstado extends State<RastreadorDeGastos> {
  // Lista de gastos armazenada localmente
  final List<Map<String, dynamic>> _gastos = [];

  // Controladores dos campos de entrada
  final TextEditingController _controladorNome = TextEditingController();
  final TextEditingController _controladorValor = TextEditingController();
  final TextEditingController _controladorDescricao = TextEditingController();

  // Variáveis de estado
  String? _classificacaoSelecionada;
  String? _erroNome;
  String? _erroValor;
  String? _erroClassificacao;

  // Lista de imagens para o carrossel
  final List<String> _imagens = [
    'assets/img1.png',
    'assets/img2.png',
    'assets/img3.png',
    'assets/img4.png',
    'assets/img5.png',
    'assets/img6.png',
    'assets/img7.png',
    'assets/img8.png',
    'assets/img9.png',
    'assets/img10.png',
  ];

  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer; // Timer para navegação automática no carrossel

  @override
  void initState() {
    super.initState();
    _carregarGastos(); // Carrega os dados salvos
    _pageController = PageController(initialPage: 0);

    // Timer que altera as imagens a cada 2 segundos
    _timer = Timer.periodic(const Duration(seconds: 2), (Timer timer) {
      if (_currentPage < _imagens.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose(); // Libera recursos do PageController
    _timer?.cancel(); // Cancela o timer ao sair da tela
    super.dispose();
  }

  // Função para carregar os gastos do armazenamento local
  Future<void> _carregarGastos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? dadosGastos = prefs.getString('gastos');
    if (dadosGastos != null) {
      setState(() {
        _gastos.addAll(List<Map<String, dynamic>>.from(jsonDecode(dadosGastos)));
      });
    }
    await NotificacaoService.agendarNotificacaoSemanal(
      'Resumo Semanal',
      'Veja quanto você gastou com desejos essa semana!',
    );
  }

  // Salva os gastos no armazenamento local
  Future<void> _salvarGastos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gastos', jsonEncode(_gastos));
  }

  // Adiciona um novo gasto com validações
  void _adicionarGasto() {
    final String nome = _controladorNome.text.trim();
    final String textoValor = _controladorValor.text.replaceAll(',', '.').trim();
    final double? valor = double.tryParse(textoValor);
    final String descricao = _controladorDescricao.text.trim();

    // Validação dos campos
    setState(() {
      _erroNome = nome.isEmpty ? 'Preencha o nome do gasto' : null;
      _erroValor = valor == null ? 'Preencha um valor válido' : null;
      _erroClassificacao = _classificacaoSelecionada == null
          ? 'Selecione uma classificação'
          : null;
    });
    

    // Se houver erros, retorna
    if (_erroNome != null || _erroValor != null || _erroClassificacao != null) {
      return;
    }

    // Adiciona o gasto e limpa os campos
    setState(() {
      _gastos.add({
        'nome': nome[0].toUpperCase() + nome.substring(1),
        'valor': valor,
        'classificacao': _classificacaoSelecionada,
        'descricao': descricao,
        'data': DateTime.now().toIso8601String(),
      });
      _controladorNome.clear();
      _controladorValor.clear();
      _controladorDescricao.clear();
      _classificacaoSelecionada = null;
      _salvarGastos();

     ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gasto adicionado, mais informações em detalhes'),
          duration: Duration(seconds: 3),
        ),
      );

      double totalDesejo = _gastos
        .where((g) => g['classificacao'] == 'Desejo')
        .fold(0.0, (soma, g) => soma + g['valor']);

      if (totalDesejo > 100) {
        NotificacaoService.mostrarNotificacao(
          'Atenção!',
          'Você já gastou R\$ ${totalDesejo.toStringAsFixed(2)} em desejos.',
        );
      }
    });
  }

  // Função para editar um gasto existente
  void editarGasto(int indice) {
    final gasto = _gastos[indice];
    _controladorNome.text = gasto['nome'];
    _controladorValor.text = gasto['valor'].toString();
    _controladorDescricao.text = gasto['descricao'] ?? '';
    _classificacaoSelecionada = gasto['classificacao'];

    // Exibe diálogo de edição
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Gasto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _controladorNome,
                decoration: const InputDecoration(labelText: 'Nome do Gasto'),
              ),
              TextField(
                controller: _controladorValor,
                decoration: const InputDecoration(labelText: 'Valor do Gasto'),
                keyboardType: TextInputType.number,
              ),
              DropdownButtonFormField<String>(
                value: _classificacaoSelecionada,
                items: const [
                  DropdownMenuItem(
                    value: 'Necessidade',
                    child: Text('Gasto por necessidade'),
                  ),
                  DropdownMenuItem(
                    value: 'Desejo',
                    child: Text('Gasto não essencial (por desejo)'),
                  ),
                ],
                onChanged: (valor) {
                  setState(() {
                    _classificacaoSelecionada = valor;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Classificação do Gasto',
                ),
              ),
              TextField(
                controller: _controladorDescricao,
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
                    'nome': _controladorNome.text,
                    'valor': double.tryParse(_controladorValor.text) ?? 0.0,
                    'classificacao': _classificacaoSelecionada,
                    'descricao': _controladorDescricao.text,
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

  // Remove um gasto
  void excluirGasto(int indice) {
    setState(() {
      _gastos.removeAt(indice);
    });
    _salvarGastos();
  }

  // Calcula o total dos gastos
  double calcularTotal() {
    return _gastos.fold(0.0, (soma, gasto) => soma + gasto['valor']);
  }

  // Organiza os gastos por dia da semana e tipo
  Map<String, Map<String, double>> _calcularGastosPorDia() {
    final Map<String, Map<String, double>> gastosPorDia = {};

    for (var gasto in _gastos) {
      final data = DateTime.parse(gasto['data']);
      final diaSemana = DateFormat.E().format(data); // ex: Mon, Tue
      final classificacao = gasto['classificacao'];
      final valor = gasto['valor'];

      if (!gastosPorDia.containsKey(diaSemana)) {
        gastosPorDia[diaSemana] = {'Necessidade': 0.0, 'Desejo': 0.0};
      }

      gastosPorDia[diaSemana]![classificacao] =
          (gastosPorDia[diaSemana]![classificacao] ?? 0.0) + valor;
    }

    return gastosPorDia;
  }

  @override
  Widget build(BuildContext context) {
    final larguraTela = MediaQuery.of(context).size.width;
    final gastosPorDia = _calcularGastosPorDia();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Controle Financeiro'),
      ),
      body: Column(
        children: [
          // Campos de entrada
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Campo nome
                Expanded(
                  child: TextField(
                    controller: _controladorNome,
                    decoration: InputDecoration(
                      labelText: 'Nome do Gasto',
                      errorText: _erroNome,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Classificação
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _classificacaoSelecionada,
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
                        _classificacaoSelecionada = valor;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Classificação',
                      errorText: _erroClassificacao,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Campos valor e descrição
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controladorValor,
                    decoration: InputDecoration(
                      labelText: 'Valor do Gasto',
                      errorText: _erroValor,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _controladorDescricao,
                    decoration: const InputDecoration(
                      labelText: 'Descrição (opcional)',
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Botão adicionar
          ElevatedButton(
            onPressed: _adicionarGasto,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // ⬅️ borda mais quadrada
              ),
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            ),
            child: larguraTela < 400
                ? const Icon(Icons.add)
                : const Text(
                    'Adicionar Gasto',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
          const SizedBox(height: 20),

          // Linha com carrossel e dicas
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Carrossel de imagens
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 300,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _imagens.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            _imagens[index],
                            fit: BoxFit.contain,
                            width: double.infinity,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Dica bônus
              Expanded(
                flex: 1,
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "🧠 Dica bônus: Regra dos 50-30-20",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text("50% para necessidades (aluguel, contas, comida)"),
                        Text("30% para desejos (lazer, roupas, delivery)"),
                        Text("20% para economia/investimentos"),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Gráfico de barras dos gastos por dia
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barGroups: gastosPorDia.entries.map((entry) {
                    final dia = entry.key;
                    final necessidade = entry.value['Necessidade'] ?? 0.0;
                    final desejo = entry.value['Desejo'] ?? 0.0;
                    final total = necessidade + desejo;

                    return BarChartGroupData(
                      x: dia.hashCode,
                      barRods: [
                        BarChartRodData(
                          rodStackItems: [
                            BarChartRodStackItem(0, necessidade, Colors.blue),
                            BarChartRodStackItem(necessidade, total, Colors.red),
                          ],
                          toY: total,
                          width: 20,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toInt().toString());
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final dias = gastosPorDia.keys.toList();
                          if (value.toInt() >= 0 && value.toInt() < dias.length) {
                            return Text(dias[value.toInt()]);
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}