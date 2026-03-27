import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../application/providers/player_providers.dart';
import '../../application/providers/resonance_providers.dart';
import '../../application/providers/subtitle_providers.dart';

/// Displays a script (台本) — supports plain text (md/txt) and PDF files.
class ScriptView extends ConsumerWidget {
  const ScriptView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentEntry = ref.watch(
      playerStateNotifierProvider.select((s) => s.currentEntry),
    );

    if (currentEntry == null) {
      return const _EmptyState();
    }

    final refreshTick = ref.watch(
      entryResourceRefreshTickProvider(currentEntry.id),
    );
    return _ScriptContent(
      key: ValueKey('${currentEntry.id}:$refreshTick'),
      entryId: currentEntry.id,
    );
  }
}

class _ScriptContent extends ConsumerStatefulWidget {
  const _ScriptContent({super.key, required this.entryId});

  final int entryId;

  @override
  ConsumerState<_ScriptContent> createState() => _ScriptContentState();
}

class _ScriptContentState extends ConsumerState<_ScriptContent> {
  String? _scriptPath;
  String? _scriptText;
  bool _isPdf = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadScript();
  }

  @override
  void didUpdateWidget(_ScriptContent old) {
    super.didUpdateWidget(old);
    if (old.entryId != widget.entryId) {
      _loadScript();
    }
  }

  Future<void> _loadScript() async {
    setState(() => _loading = true);
    try {
      final repo = ref.read(resonanceRepositoryProvider);
      final scriptPath = await repo.getScriptFilePathForEntry(widget.entryId);
      if (scriptPath != null) {
        final file = File(scriptPath);
        if (await file.exists()) {
          final ext = p.extension(scriptPath).toLowerCase();
          if (ext == '.pdf') {
            if (mounted) {
              setState(() {
                _scriptPath = scriptPath;
                _isPdf = true;
                _scriptText = null;
                _loading = false;
              });
            }
            return;
          }

          // Plain text / markdown
          final text = await file.readAsString();
          if (mounted) {
            setState(() {
              _scriptText = text;
              _isPdf = false;
              _scriptPath = scriptPath;
              _loading = false;
            });
          }
          return;
        }
      }
    } catch (_) {}
    if (mounted) {
      setState(() {
        _scriptText = null;
        _scriptPath = null;
        _isPdf = false;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    // PDF rendering
    if (_isPdf && _scriptPath != null) {
      return _PdfScriptView(filePath: _scriptPath!);
    }

    // Plain text
    if (_scriptText == null || _scriptText!.trim().isEmpty) {
      return const _EmptyState();
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Text(
        _scriptText!,
        style: const TextStyle(
          fontSize: 16,
          height: 1.5,
          color: Color(0xFF4A4A4A),
        ),
      ),
    );
  }
}

/// Renders a PDF file using the native PDF viewer.
class _PdfScriptView extends StatefulWidget {
  const _PdfScriptView({required this.filePath});

  final String filePath;

  @override
  State<_PdfScriptView> createState() => _PdfScriptViewState();
}

class _PdfScriptViewState extends State<_PdfScriptView> {
  int _totalPages = 0;
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PDFView(
          filePath: widget.filePath,
          enableSwipe: true,
          swipeHorizontal: false,
          autoSpacing: true,
          pageFling: false,
          pageSnap: false,
          fitPolicy: FitPolicy.WIDTH,
          onRender: (pages) {
            if (mounted) {
              setState(() => _totalPages = pages ?? 0);
            }
          },
          onViewCreated: (controller) {},
          onPageChanged: (page, total) {
            if (mounted) {
              setState(() {
                _currentPage = page ?? 0;
                _totalPages = total ?? 0;
              });
            }
          },
        ),
        if (_totalPages > 1)
          Positioned(
            right: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_currentPage + 1} / $_totalPages',
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Text(
          '暂无台本\n可从右上角更多中导入台本',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            height: 1.45,
            color: const Color(0xFF4A4A4A).withValues(alpha: 0.45),
          ),
        ),
      ),
    );
  }
}
