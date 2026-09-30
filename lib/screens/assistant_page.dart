import 'package:flutter/material.dart';

import '../data/student_store.dart';
import '../services/offline_assistant_service.dart';
import '../widgets/app_shell.dart';
import '../widgets/page_header.dart';

class AssistantPage extends StatefulWidget {
  const AssistantPage({super.key});
  @override
  State<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantMessage {
  const _AssistantMessage({required this.text, required this.fromUser});
  final String text;
  final bool fromUser;
}

class _AssistantPageState extends State<AssistantPage> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _assistant = const OfflineAssistantService();
  final _messages = <_AssistantMessage>[];

  @override
  void initState() {
    super.initState();
    _messages.add(const _AssistantMessage(text: 'Hi! I am your Student Life Hub offline assistant. I only use the data stored on this device.', fromUser: false));
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send([String? preset]) {
    final text = (preset ?? _input.text).trim();
    if (text.isEmpty) return;
    _input.clear();
    final reply = _assistant.reply(text, StudentStore.instance);
    setState(() => _messages
      ..add(_AssistantMessage(text: text, fromUser: true))
      ..add(_AssistantMessage(text: reply.message, fromUser: false)));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 280), curve: Curves.easeOut);
    });
  }

  @override
  Widget build(BuildContext context) => AppShell(
        index: 5,
        child: Column(children: [
          const PageHeader(title: 'Student Life AI Assistant', subtitle: 'Private, offline, and built around your routine.', showBackButton: true),
          Expanded(child: ListView.builder(controller: _scroll, padding: const EdgeInsets.fromLTRB(20, 0, 20, 12), itemCount: _messages.length, itemBuilder: (context, index) => _bubble(context, _messages[index]))),
          _suggestions(),
          SafeArea(top: false, child: Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 16), child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Expanded(child: TextField(controller: _input, minLines: 1, maxLines: 4, textInputAction: TextInputAction.send, onSubmitted: (_) => _send(), decoration: const InputDecoration(hintText: 'Ask about your student life...', prefixIcon: Icon(Icons.auto_awesome_outlined)))),
            const SizedBox(width: 8),
            IconButton.filled(tooltip: 'Send message', onPressed: _send, icon: const Icon(Icons.arrow_upward_rounded)),
          ]))),
        ]),
      );

  Widget _bubble(BuildContext context, _AssistantMessage message) {
    final scheme = Theme.of(context).colorScheme;
    return Align(alignment: message.fromUser ? Alignment.centerRight : Alignment.centerLeft, child: Container(
      constraints: const BoxConstraints(maxWidth: 640), margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(color: message.fromUser ? scheme.primary : scheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(20).copyWith(bottomRight: message.fromUser ? const Radius.circular(5) : null, bottomLeft: message.fromUser ? null : const Radius.circular(5))),
      child: SelectableText(message.text, style: TextStyle(color: message.fromUser ? scheme.onPrimary : scheme.onSurface, height: 1.4)),
    ));
  }

  Widget _suggestions() {
    const suggestions = ['What do I have today?', 'Show my open tasks', 'How is my GPA?', 'Make a study plan'];
    return SizedBox(height: 48, child: ListView.separated(padding: const EdgeInsets.symmetric(horizontal: 16), scrollDirection: Axis.horizontal, itemCount: suggestions.length, separatorBuilder: (_, _) => const SizedBox(width: 8), itemBuilder: (_, index) => ActionChip(label: Text(suggestions[index]), onPressed: () => _send(suggestions[index]))));
  }
}
