import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/api_service.dart';
import 'app_theme.dart';
import 'ui_components.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatMessage {
  const _ChatMessage({
    required this.role,
    required this.text,
  });

  final String role;
  final String text;

  Map<String, String> toJson() => {'role': role, 'text': text};

  factory _ChatMessage.fromJson(Map<String, dynamic> json) => _ChatMessage(
        role: json['role'] == 'user' ? 'user' : 'assistant',
        text: (json['text'] ?? '').toString(),
      );
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  static const _historyKey = 'setor_in_chat_history_v1';
  static const _welcome =
      'Hai, saya SetoBot. Saya bisa membantu tentang pemilahan sampah, lingkungan, dan penggunaan aplikasi. Jawaban bersifat umum—saya tidak bisa melihat saldo atau data akunmu.';

  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _loadingHistory = true;
  bool _sending = false;
  String? _lastQuestion;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey);
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          _messages.addAll(decoded
              .whereType<Map>()
              .map((item) => _ChatMessage.fromJson(
                  Map<String, dynamic>.from(item)))
              .where((message) => message.text.isNotEmpty)
              .map((message) => _ChatMessage(
                    role: message.role,
                    text: message.text
                        .replaceAll('Asisten Setor.in', 'SetoBot')
                        .replaceAll('Asisten sedang menyiapkan jawaban', 'SetoBot sedang menyiapkan jawaban'),
                  ))
              .take(100));
        }
      } on FormatException {
        await prefs.remove(_historyKey);
      }
    }
    if (_messages.isEmpty) {
      _messages.add(const _ChatMessage(role: 'assistant', text: _welcome));
      await _saveHistory();
    }
    if (mounted) setState(() => _loadingHistory = false);
    _scrollToBottom();
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = _messages.toList();
    final trimmed = saved.length > 100
        ? saved.sublist(saved.length - 100)
        : saved;
    await prefs.setString(
      _historyKey,
      jsonEncode(trimmed.map((message) => message.toJson()).toList()),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send([String? suggested]) async {
    if (_sending) return;
    final question = (suggested ?? _controller.text).trim();
    if (question.isEmpty || question.length > 500) return;

    if (_errorText != null &&
        _messages.isNotEmpty &&
        _messages.last.role == 'user') {
      setState(() => _messages.removeLast());
    }

    final history = _messages
        .map((message) => <String, String>{
              'role': message.role,
              'content': message.text,
            })
        .toList();
    final contextHistory = history.length > 10
        ? history.sublist(history.length - 10)
        : history;

    setState(() {
      _messages.add(_ChatMessage(role: 'user', text: question));
      _sending = true;
      _lastQuestion = question;
      _errorText = null;
      _controller.clear();
    });
    _scrollToBottom();

    final result = await ApiService().sendChatMessage(
      message: question,
      history: contextHistory,
    );
    if (!mounted) return;

    setState(() {
      _sending = false;
      if (result['success'] == true) {
        _messages.add(_ChatMessage(
          role: 'assistant',
          text: (result['reply'] ?? '').toString(),
        ));
      } else {
        _errorText = (result['message'] ?? 'Asisten belum dapat menjawab.')
            .toString();
      }
    });
    if (result['success'] == true) await _saveHistory();
    _scrollToBottom();
  }

  Future<void> _retry() async {
    final question = _lastQuestion;
    if (question == null) return;
    if (_messages.isNotEmpty && _messages.last.role == 'user') {
      setState(() => _messages.removeLast());
    }
    setState(() => _errorText = null);
    await _send(question);
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus percakapan?'),
        content: const Text('Riwayat lokal di perangkat ini akan dihapus.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      _messages
        ..clear()
        ..add(const _ChatMessage(role: 'assistant', text: _welcome));
      _errorText = null;
      _lastQuestion = null;
    });
    await _saveHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        foregroundColor: kText,
        leading: IconButton(
          tooltip: 'Kembali',
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back, color: kText),
        ),
        title: Row(children: [
          ClipOval(child: Image.asset('assets/images/setobot-icon.png', width: 30, height: 30, fit: BoxFit.cover)),
          const SizedBox(width: 8),
          const Text('SetoBot', style: TextStyle(
              color: kText, fontSize: 18.4, fontWeight: FontWeight.w800)),
        ]),
        actions: [
          IconButton(
            tooltip: 'Hapus percakapan',
            onPressed: _sending ? null : _clearHistory,
            icon: const Icon(Icons.delete_outline_rounded, color: kText),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 2, 16, 10),
            child: InlineNotice(
              message:
                  'Jawaban bersifat umum. Jangan kirim email, nomor telepon, rekening, OTP, PIN, atau data pribadi.',
            ),
          ),
          Expanded(
            child: _loadingHistory
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: _messages.length + (_sending ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_sending && index == _messages.length) {
                        return const _TypingBubble();
                      }
                      final message = _messages[index];
                      return _MessageBubble(message: message);
                    },
                  ),
          ),
          if (_errorText != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(children: [
                Expanded(
                  child: Text(_errorText!,
                      style: const TextStyle(color: kDanger, fontSize: 13.8)),
                ),
                TextButton.icon(
                  onPressed: _sending ? null : _retry,
                  icon: const Icon(Icons.refresh_rounded, size: 20.1),
                  label: const Text('Coba lagi'),
                ),
              ]),
            ),
          if (_messages.length <= 1 && !_sending)
            SizedBox(
              height: 44,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                children: [
                  _SuggestionChip(
                    label: 'Cara menyiapkan setoran',
                    onTap: () => _send('Bagaimana cara menyiapkan setoran?'),
                  ),
                  _SuggestionChip(
                    label: 'Jenis sampah yang diterima',
                    onTap: () => _send('Jenis sampah apa yang diterima?'),
                  ),
                ],
              ),
            ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    enabled: !_sending,
                    minLines: 1,
                    maxLines: 4,
                    maxLength: 500,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(
                      hintText: 'Tulis pertanyaan…',
                      counterText: '',
                      filled: true,
                      fillColor: kSurface,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 13),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: kBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: kBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: kPrimary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 9),
                SizedBox(
                  height: 50,
                  width: 50,
                  child: FilledButton(
                    onPressed: _sending ? null : () => _send(),
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.arrow_upward_rounded),
                  ),
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});
  final _ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isUser) ...[
              ClipOval(child: Image.asset('assets/images/setobot-icon.png', width: 28, height: 28, fit: BoxFit.cover)),
              const SizedBox(width: 7),
            ],
            Flexible(
              child: Container(
                constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * .82),
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                decoration: BoxDecoration(
                  color: isUser ? kPrimary : kSurface,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(isUser ? 18 : 5),
                    bottomRight: Radius.circular(isUser ? 5 : 18),
                  ),
                  border: isUser ? null : Border.all(color: kBorder),
                ),
                child: Text(message.text,
                    style: TextStyle(
                        color: isUser ? Colors.white : kText,
                        fontSize: 16.1,
                        height: 1.45)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
          decoration: BoxDecoration(
              color: kSurface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: kBorder)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            ClipOval(child: Image.asset('assets/images/setobot-icon.png', width: 22, height: 22, fit: BoxFit.cover)),
            const SizedBox(width: 8),
            SizedBox(
              width: 15,
              height: 15,
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 9),
            const Text('SetoBot sedang menyiapkan jawaban…',
                style: TextStyle(color: kTextSoft, fontSize: 13.8)),
          ]),
        ),
      );
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ActionChip(
          onPressed: onTap,
          backgroundColor: kSurface,
          side: const BorderSide(color: kBorder),
          label: Text(label,
              style: const TextStyle(color: kPrimary, fontSize: 13.8)),
        ),
      );
}
