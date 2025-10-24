# FluxoApp — Controle Financeiro

Aplicativo Flutter para auxiliar no controle de gastos pessoais: registre despesas, visualize gráficos, gerencie metas e exporte relatórios em PDF.

## Funcionalidades
- **Rastreamento de Gastos**: cadastro de gastos com nome, valor, classificação (`Necessidade`/`Desejo`), forma de pagamento (💳 cartão, 💵 dinheiro, 📅 parcelado, 🅿️ pix), descrição e data.
- **Detalhes e Filtros**: busca por texto/valor, filtro por data e por classificação, edição e exclusão de gastos, total filtrado.
- **Gráficos**: visão percentual por categoria e resumo comparativo por período (Semanal/Mensal).
- **Metas Financeiras**: criação de metas com progresso, adição/remoção de valores, indicadores de status (concluída, quase concluída, parada).
- **Exportação para PDF**: gera relatório com resumo e tabela de gastos para compartilhamento.
- **Notificações Locais**: lembretes semanais configurados via notificações locais.
- **Perfil**: alternância de tema (Claro/Escuro/Sistema), contatos rápidos (GitHub e Instagram) e documentação do projeto.

## Capturas (ilustrativas)
- `lib/rastreador_de_gastos.dart`
- `lib/grafico_de_gastos.dart`
- `lib/detalhes_gastos.dart`
- `lib/metas_financeiras.dart`
- `lib/perfil_page.dart`

## Requisitos
- Flutter SDK (versão compatível com `sdk: ^3.6.2`)
- Dart SDK compatível

## Instalação
1. Instale dependências:
   ```bash
   flutter pub get
   ```
2. Verifique dispositivos/emuladores disponíveis:
   ```bash
   flutter devices
   ```

## Execução
```bash
flutter run
```

## Build
- Android (APK debug):
  ```bash
  flutter build apk --debug
  ```
- Android (APK release):
  ```bash
  flutter build apk --release
  ```
- iOS:
  ```bash
  flutter build ios
  ```

## Estrutura do Projeto
```
controle_financeiro/
├─ lib/
│  ├─ main.dart
│  ├─ rastreador_de_gastos.dart
│  ├─ detalhes_gastos.dart
│  ├─ grafico_de_gastos.dart
│  ├─ metas_financeiras.dart
│  ├─ perfil_page.dart
│  ├─ notificacoes.dart
│  └─ exportar_utils.dart
├─ assets/
│  └─ img1.png ... img10.png
└─ pubspec.yaml
```

## Principais Dependências
- `shared_preferences`: armazenamento local de dados simples.
- `fl_chart`: gráficos de pizza e barras.
- `intl`: formatação de datas e números.
- `flutter_local_notifications`, `timezone`: notificações locais e fuso horário.
- `pdf`, `printing`: geração e compartilhamento de PDFs.
- `url_launcher`: abertura de links externos (GitHub/Instagram).

Consulte `pubspec.yaml` para versões exatas.

## Permissões e Configurações
- **Android**:
  - Notificações: certifique-se de configurar canais e permissões conforme `flutter_local_notifications`.
  - Arquivos/Compartilhamento (PDF): algumas versões do Android podem exigir permissões adicionais.
  - Internet: necessária para abrir links externos via navegador (`url_launcher`).
- **iOS**:
  - Atualize `Info.plist` se necessário para uso de notificações e esquemas de URL.

## Dados e Privacidade
- Os dados dos usuários (gastos e metas) são persistidos localmente via `SharedPreferences`. Não há sincronização em nuvem nativamente.

## Contatos
- GitHub: https://github.com/AliceSilva56
- Instagram: https://instagram.com/a.pinheiro.dev

## Créditos
- Desenvolvido por **Alice Pinheiro Da Silva**.

## Licença
Este projeto é de uso pessoal/educacional. Adicione uma licença caso pretenda distribuir.

