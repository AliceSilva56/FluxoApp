// Created by [Alice Pinheiro Da Silva].
//Arquivo: conquista_service.dart
//Descrição: Este arquivo contém a implementação do serviço de conquistas, que permite adicionar e verificar conquistas do usuário.
import 'package:shared_preferences/shared_preferences.dart';

class ConquistasService {
  static const String _chaveConquistas = 'conquistas';

  static Future<List<String>> obterConquistas() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_chaveConquistas) ?? [];
  }

  static Future<void> adicionarConquista(String conquista) async {
    final prefs = await SharedPreferences.getInstance();
    final conquistas = prefs.getStringList(_chaveConquistas) ?? [];

    if (!conquistas.contains(conquista)) {
      conquistas.add(conquista);
      await prefs.setStringList(_chaveConquistas, conquistas);
    }
  }

  // Verifica se a conquista de 7 dias sem gastar desejo foi alcançada
  static Future<void> verificarSeteDiasSemDesejo(List<Map<String, dynamic>> gastos) async {
    final agora = DateTime.now();
    final seteDiasAtras = agora.subtract(const Duration(days: 7));

    final gastosDesejo = gastos.where((gasto) {
      final data = DateTime.tryParse(gasto['data']);
      return gasto['classificacao'] == 'Desejo' && data != null && data.isAfter(seteDiasAtras);
    }).toList();

    if (gastosDesejo.isEmpty) {
      await adicionarConquista('🎯 7 dias sem gastar com desejo');
    }
  }

  // Verifica se a primeira meta foi concluída
  static Future<void> verificarPrimeiraMetaConcluida(List<Map<String, dynamic>> metas) async {
    final algumaConcluida = metas.any((meta) {
      return meta['valorAtual'] >= meta['valorAlvo'];
    });

    if (algumaConcluida) {
      await adicionarConquista('🏆 Primeira meta concluída');
    }
  }
}
