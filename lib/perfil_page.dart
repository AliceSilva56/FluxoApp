// Created by [Alice Pinheiro Da Silva].
// Arquivo: perfil_page.dart
// Descrição: Página de perfil do usuário, onde ele pode alterar o tema e visualizar suas conquistas

import 'package:flutter/material.dart'; // Importação de Color
import 'package:shared_preferences/shared_preferences.dart'; // Importação de SharedPreferences
import 'package:url_launcher/url_launcher.dart';

class PerfilPage extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;
  const PerfilPage({super.key, required this.onThemeChanged});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> with AutomaticKeepAliveClientMixin<PerfilPage> {
  String _temaSelecionado = 'system';

  @override
  bool get wantKeepAlive => false;

  @override
  void initState() {
    super.initState();
    _carregarTema();
  }

  Future<void> _carregarTema() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _temaSelecionado = prefs.getString('tema') ?? 'system';
    });
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

  Future<void> _abrirUrl(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
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
          const Text('Contatos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ChoiceChip(
                label: const Text('GitHub'),
                selected: false,
                onSelected: (_) => _abrirUrl('https://github.com/AliceSilva56'),
              ),
              ChoiceChip(
                label: const Text('Instagram'),
                selected: false,
                onSelected: (_) => _abrirUrl('https://instagram.com/a.pinheiro.dev'),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text('Documentação do Projeto', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Nome: FluxoApp'),
                  SizedBox(height: 6),
                  Text('Objetivo: Auxiliar no controle de gastos pessoais.'),
                  SizedBox(height: 6),
                  Text('Principais recursos:'),
                  Text('• Registro rápido de gastos (nome, valor, classificação, forma de pagamento).'),
                  Text('• Detalhamento com filtros por texto, data e classificação.'),
                  Text('• Gráficos de distribuição e resumo por período (semanal/mensal).'),
                  Text('• Metas financeiras com progresso e histórico.'),
                  Text('• Exportação de dados para PDF.'),
                  SizedBox(height: 6),
                  Text('Tecnologias: Flutter, fl_chart, shared_preferences, pdf/printing, notifications.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Sobre'),
              subtitle: const Text('Desenvolvido por Alice Pinheiro Da Silva.'),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text('Privacidade de Dados'),
              subtitle: const Text('Os dados ficam armazenados localmente no dispositivo (SharedPreferences).'),
            ),
          ),
        ],
      ),
    );
  }
}