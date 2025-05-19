// Created by [Alice Pinheiro Da Silva].
// Arquivo: perfil_page.dart
// Descrição: Página de perfil do usuário, onde ele pode alterar o tema e visualizar suas conquistas

import 'package:flutter/material.dart'; // Importação de Color
import 'package:shared_preferences/shared_preferences.dart'; // Importação de SharedPreferences
import 'conquistas_service.dart'; // Importação do serviço de conquistas

class PerfilPage extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;
  const PerfilPage({Key? key, required this.onThemeChanged}) : super(key: key);

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> with AutomaticKeepAliveClientMixin<PerfilPage> {
  String _temaSelecionado = 'system';
  List<String> conquistas = [];

  // Definição dos objetivos adicionais
  final List<Map<String, String>> _objetivos = [
    {'id': 'primeiro_gasto', 'descricao': 'Primeiro Gasto Registrado'},
    {'id': 'meta_atingida', 'descricao': 'Primeira Meta Atingida'},
    {'id': 'semana_sem_desejos', 'descricao': 'Uma semana sem gastar em desejos'},
    {'id': 'duas_metas', 'descricao': '2 Metas Concluídas'},
    {'id': 'exportou_dados', 'descricao': 'Exportou para PDF'},
  ];

  @override
  bool get wantKeepAlive => false;

  @override
  void initState() {
    super.initState();
    _carregarTema();
    _carregarConquistas();
  }

  Future<void> _carregarTema() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _temaSelecionado = prefs.getString('tema') ?? 'system';
    });
  }

  Future<void> _carregarConquistas() async {
    final conquistadas = await ConquistasService.obterConquistas();
    setState(() => conquistas = conquistadas);
  }

  void _atualizarTema(String valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tema', valor);
    setState(() => _temaSelecionado = valor);
    widget.onThemeChanged({
      'light': ThemeMode.light,
      'dark': ThemeMode.dark,
      'system': ThemeMode.system
    }[valor]!);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('⚙️ Configurações de Tema', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ChoiceChip(
                label: const Text('Claro'),
                selected: _temaSelecionado == 'light',
                onSelected: (_) => _atualizarTema('light'),
              ),
              ChoiceChip(
                label: const Text('Escuro'),
                selected: _temaSelecionado == 'dark',
                onSelected: (_) => _atualizarTema('dark'),
              ),
              ChoiceChip(
                label: const Text('Sistema'),
                selected: _temaSelecionado == 'system',
                onSelected: (_) => _atualizarTema('system'),
              ),
            ],
          ),
           const SizedBox(height: 32),
          const Text(
            'Conquistas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildTrofeu('primeiro_gasto', 'Primeiro Gasto Registrado'),
              _buildTrofeu('meta_atingida', 'Primeira Meta Atingida'),
              _buildTrofeu('semana_economica', 'Semana Econômica'),
              _buildTrofeu('exportou_dados', 'Exportou para PDF'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrofeu(String id, String descricao) {
    final conquistado = conquistas.contains(id);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.emoji_events,
          size: 48,
          color: conquistado ? Colors.amber : Colors.grey,
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 80,
          child: Text(
            descricao,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
}
