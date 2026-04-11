import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opendevnote/models/code_snippet.dart';
import 'package:opendevnote/providers/code_snippet_provider.dart';
import 'package:opendevnote/providers/providers.dart';
import 'package:opendevnote/services/syntax_highlighter.dart';
import 'package:opendevnote/utils/language_detector.dart';
import 'package:opendevnote/widgets/code_snippet_card.dart';
import 'package:opendevnote/widgets/keyboard_shortcuts_help.dart';
import 'package:opendevnote/widgets/command_bar.dart';
import 'package:code_text_field/code_text_field.dart';

class CodeSnippetEditorScreen extends ConsumerStatefulWidget {
  final CodeSnippet snippet;

  const CodeSnippetEditorScreen({super.key, required this.snippet});

  @override
  ConsumerState<CodeSnippetEditorScreen> createState() => _CodeSnippetEditorScreenState();
}

class _CodeSnippetEditorScreenState extends ConsumerState<CodeSnippetEditorScreen> {
  late CodeController _controller;
  final FocusNode _focusNode = FocusNode();
  Timer? _saveTimer;
  bool _hasUnsavedChanges = false;
  String _detectedLanguage = '';
  int _cursorLine = 1;
  int _cursorColumn = 1;

  @override
  void initState() {
    super.initState();
    _detectedLanguage = widget.snippet.language;

    final allStringMap = <String, TextStyle>{};
    for (final lang in SyntaxHighlighter.getAvailableLanguages()) {
      allStringMap.addAll(SyntaxHighlighter.getStringMap(lang));
    }

    _controller = CodeController(
      text: widget.snippet.code,
      stringMap: allStringMap,
      patternMap: SyntaxHighlighter.getPatternMap(),
    );
    _updateCursorPosition();
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    if (_hasUnsavedChanges) {
      _saveSnippet();
    }
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _updateCursorPosition() {
    final text = _controller.text;
    final selection = _controller.selection?.start ?? 0;

    if (selection < 0) return;

    int line = 1;
    int column = 1;
    for (int i = 0; i < selection && i < text.length; i++) {
      if (text[i] == '\n') {
        line++;
        column = 1;
      } else {
        column++;
      }
    }
    setState(() {
      _cursorLine = line;
      _cursorColumn = column;
    });
  }

  void _onCodeChanged() {
    setState(() => _hasUnsavedChanges = true);

    final detected = LanguageDetector.detect(_controller.text);
    if (detected != null && detected != _detectedLanguage) {
      setState(() => _detectedLanguage = detected);
    }

    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 1000), () {
      _saveSnippet();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final def = SyntaxHighlighter.getDefinition(_detectedLanguage);

    final editorWidget = Column(
      children: [
        _buildStatusBar(colorScheme, textTheme, def),
        Expanded(
          child: Container(
            color: colorScheme.surface,
            child: _buildEditor(context, colorScheme),
          ),
        ),
      ],
    );

    Widget body = CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyS, control: true): () {
          _saveSnippet();
        },
        const SingleActivator(LogicalKeyboardKey.slash, control: true): () {
          showDialog(context: context, builder: (_) => const KeyboardShortcutsHelp());
        },
        const SingleActivator(LogicalKeyboardKey.keyP, control: true): () {
          showDialog(context: context, builder: (_) => const CommandBar());
        },
      },
      child: Focus(
        autofocus: true,
        child: editorWidget,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(selectedSnippetIdProvider.notifier).state = null;
            ref.read(selectedSnippetProjectIdProvider.notifier).state = null;
          },
          tooltip: 'Wróć',
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LanguageIcons.getIcon(_detectedLanguage),
              size: 18,
              color: LanguageColors.getColor(_detectedLanguage),
            ),
            const SizedBox(width: 8),
            Flexible(child: Text(widget.snippet.title, overflow: TextOverflow.ellipsis)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined),
            onPressed: _saveSnippet,
            tooltip: 'Zapisz (Ctrl+S)',
          ),
        ],
      ),
      body: body,
    );
  }

  Widget _buildStatusBar(ColorScheme colorScheme, TextTheme textTheme, SyntaxDefinition? def) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(
            LanguageIcons.getIcon(_detectedLanguage),
            size: 16,
            color: LanguageColors.getColor(_detectedLanguage),
          ),
          const SizedBox(width: 6),
          Text(
            def?.displayName ?? LanguageIcons.getDisplayName(_detectedLanguage),
            style: textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Ln $_cursorLine, Col $_cursorColumn',
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                fontFamily: 'monospace',
                fontSize: 10,
              ),
            ),
          ),
          const Spacer(),
          if (_hasUnsavedChanges)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Zapisywanie...',
                  style: textTheme.labelSmall?.copyWith(color: colorScheme.primary),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildEditor(BuildContext context, ColorScheme colorScheme) {
    return CodeField(
      controller: _controller,
      textStyle: TextStyle(
        fontFamily: 'monospace',
        fontSize: 14,
        height: 1.5,
        color: colorScheme.onSurface,
      ),
      cursorColor: colorScheme.primary,
      lineNumbers: true,
      lineNumberStyle: LineNumberStyle(
        textStyle: TextStyle(
          fontFamily: 'monospace',
          fontSize: 14,
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
        ),
      ),
      minLines: null,
      expands: true,
      decoration: BoxDecoration(
        color: colorScheme.surface,
      ),
      padding: const EdgeInsets.all(12),
      onChanged: (_) {
        _onCodeChanged();
      },
    );
  }

  void _saveSnippet() {
    final detected = LanguageDetector.detect(_controller.text);
    final updated = widget.snippet.copyWith(
      code: _controller.text,
      language: detected ?? _detectedLanguage,
    );
    ref.read(snippetsProvider(widget.snippet.projectId).notifier).updateSnippet(updated);
    setState(() => _hasUnsavedChanges = false);
  }
}