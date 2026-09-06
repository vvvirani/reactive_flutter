import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reactive_flutter/reactive_flutter.dart';

class LoggerView {
  final ReactiveLogger logger;
  final VoidCallback? onClose;
  final bool useOverlay;

  const LoggerView({
    required this.logger,
    this.onClose,
    this.useOverlay = false,
  });

  static Widget build({
    required ReactiveLogger logger,
    bool useOverlay = false,
    VoidCallback? onClose,
  }) {
    return _LoggerView(
      logger: logger,
      onClose: onClose,
      useOverlay: useOverlay,
    );
  }

  static Future<void> open(
    BuildContext context, {
    required ReactiveLogger logger,
    bool useOverlay = false,
    VoidCallback? onClose,
  }) async {
    if (useOverlay) {
      final overlay = Overlay.of(context);

      late OverlayEntry entry;

      void onCloseCallback() {
        entry.remove();
        onClose?.call();
      }

      entry = OverlayEntry(
        builder: (context) {
          return _LoggerView(
            logger: logger,
            useOverlay: true,
            onClose: onCloseCallback,
          );
        },
      );

      overlay.insert(entry);
    } else {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => _LoggerView(logger: logger)),
      );
    }
  }
}

class _LoggerView extends StatefulWidget {
  final ReactiveLogger logger;
  final bool useOverlay;
  final VoidCallback? onClose;

  const _LoggerView({
    required this.logger,
    this.useOverlay = false,
    this.onClose,
  });

  @override
  State<_LoggerView> createState() => _LoggerViewState();
}

class _LoggerViewState extends State<_LoggerView> {
  final Reactive<List<String>> _lines = Reactive<List<String>>([]);

  final Reactive<LogLevel?> _filter = Reactive<LogLevel?>(null);

  final Reactive<String> _search = Reactive<String>('');

  final TextEditingController _searchCtrl = TextEditingController();

  final ScrollController _scrollCtrl = ScrollController();

  List<String> get _visible {
    List<String> lines = _lines.value;
    final List<String> result = <String>[];

    bool inBlock = _filter.value == null;

    for (final String l in lines) {
      final LogLevel? lvl = LogLevelX.fromLine(l);
      if (lvl != null) {
        inBlock = _filter.value == null || lvl == _filter.value;
      }
      final bool isIndent = l.trimLeft().startsWith('└─');
      if (inBlock || (isIndent && result.isNotEmpty)) {
        result.add(l);
      }
    }

    lines = result;

    if (_search.value.isNotEmpty) {
      final String q = _search.value.toLowerCase();
      lines = lines
          .where(
            (l) => l.toLowerCase().contains(q),
          )
          .toList();
    }
    return lines;
  }

  Future<void> _load() async {
    try {
      final List<String> lines = await widget.logger.readLines();

      _lines.value = lines;
    } catch (_) {}
  }

  @override
  void initState() {
    _load();
    super.initState();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    ReactiveLogger logger = widget.logger;

    return Watch(builder: () {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.light,
          backgroundColor: Colors.white10,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          leading: Icon(
            Icons.receipt_long_rounded,
            color: theme.colorScheme.primary,
            size: 32,
          ),
          titleSpacing: 0,
          title: Text(
            'Log Viewer',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 22,
            ),
          ),
          actions: [
            _IconBtn(icon: Icons.refresh, onPressed: _load),
            _IconBtn(
              icon: Icons.copy,
              size: 20,
              onPressed: () async {
                final String? path = await logger.getFilePath();

                if (path != null) {
                  Clipboard.setData(
                    ClipboardData(text: path),
                  );
                }
              },
            ),
            _IconBtn(
              icon: Icons.delete_sweep,
              onPressed: () async {
                await logger.clearFile();
                _load();
              },
            ),
            _IconBtn(
                icon: Icons.close,
                size: 26,
                color: theme.colorScheme.primary,
                onPressed: () {
                  if (widget.onClose != null) {
                    widget.onClose?.call();
                  } else {
                    Navigator.pop(context);
                  }
                }),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              child: Column(
                spacing: 10,
                children: [
                  TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => _search.value = v,
                    style: const TextStyle(
                        color: Colors.white, fontFamily: 'monospace'),
                    decoration: InputDecoration(
                      hintText: 'Search',
                      hintStyle: const TextStyle(
                          color: Colors.white30, fontFamily: 'monospace'),
                      prefixIcon: Icon(
                        Icons.search,
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                      suffixIcon: _search.value.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                _searchCtrl.clear();
                                _search.value = '';
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white10,
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: ClampingScrollPhysics(),
                    child: Row(
                      spacing: 10,
                      children: [
                        _chipBtn(null, 'ALL'),
                        _chipBtn(LogLevel.debug, 'DEBUG'),
                        _chipBtn(LogLevel.info, 'INFO'),
                        _chipBtn(LogLevel.warning, 'WARNING'),
                        _chipBtn(LogLevel.error, 'ERROR'),
                        _chipBtn(LogLevel.fatal, 'FATAL'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: widget.logger.isLoading
                  ? Center(
                      child: CircularProgressIndicator.adaptive(
                        valueColor:
                            AlwaysStoppedAnimation(theme.colorScheme.primary),
                      ),
                    )
                  : _visible.isEmpty
                      ? Center(
                          child: Text(
                            _lines.value.isEmpty
                                ? 'Log file is empty'
                                : 'No matching lines',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'monospace'),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollCtrl,
                          physics: ClampingScrollPhysics(),
                          itemCount: _visible.length,
                          itemBuilder: (_, i) {
                            return _LogLine(line: _visible[i]);
                          },
                        ),
            ),
            Container(
              color: Colors.white10,
              padding: const EdgeInsets.symmetric(
                vertical: 4,
              ).copyWith(left: 12, right: 4),
              child: SafeArea(
                child: () {
                  TextStyle textStyle = TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontFamily: 'monospace',
                  );
                  return Row(
                    children: [
                      RichText(
                        text: TextSpan(
                          text: _visible.length.toString(),
                          children: [
                            TextSpan(text: ' / ', style: textStyle),
                            TextSpan(
                              text: _lines.value.length.toString(),
                              style: textStyle.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            TextSpan(text: ' Lines', style: textStyle),
                          ],
                          style: textStyle,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          if (_scrollCtrl.hasClients) {
                            _scrollCtrl.animateTo(
                              _scrollCtrl.position.maxScrollExtent + 400,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                          }
                        },
                        color: Colors.white,
                        iconSize: 24,
                        icon: Icon(Icons.arrow_downward_rounded),
                      )
                    ],
                  );
                }(),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _chipBtn(LogLevel? level, String label) {
    Color activeColor = switch (level) {
      LogLevel.debug => const Color(0xFF888888),
      LogLevel.info => const Color(0xFF64B5F6),
      LogLevel.warning => const Color(0xFFFFB74D),
      LogLevel.error => const Color(0xFFEF5350),
      LogLevel.fatal => const Color(0xFFFF1744),
      null => Colors.white,
    };

    return InkWell(
      borderRadius: BorderRadius.circular(99),
      splashColor: activeColor.withValues(alpha: 0.1),
      highlightColor: activeColor.withValues(alpha: 0.1),
      onTap: () => _filter.value = level,
      child: _LevelChip(
        label: label,
        level: level,
        activeColor: activeColor,
        active: _filter.value == level,
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final double? size;
  final Color? color;
  final VoidCallback? onPressed;

  const _IconBtn(
      {required this.icon, required this.onPressed, this.size, this.color});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      color: color ?? Colors.white,
      iconSize: size,
      icon: Icon(icon),
    );
  }
}

class _LogLine extends StatelessWidget {
  final String line;

  const _LogLine({required this.line});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: line.bgColor,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: SelectableText(
        line,
        style: TextStyle(
          color: line.textColor,
          fontFamily: 'monospace',
          fontWeight: line.fontWeight,
          height: 1.5,
        ),
      ),
    );
  }
}

class _LevelChip extends StatelessWidget {
  final String label;
  final LogLevel? level;
  final bool active;
  final Color activeColor;

  const _LevelChip({
    required this.label,
    required this.level,
    required this.active,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: active ? activeColor.withValues(alpha: 0.18) : Colors.white10,
        border: Border.all(
          color: active ? activeColor : Colors.transparent,
        ),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? activeColor : Colors.white38,
          fontWeight: active ? FontWeight.w800 : FontWeight.normal,
        ),
      ),
    );
  }
}

extension _LineColor on String {
  LogLevel? get level => LogLevelX.fromLine(this);

  Color? get textColor {
    return switch (level) {
      LogLevel.debug => Colors.white,
      LogLevel.info => const Color(0xFF64B5F6),
      LogLevel.warning => const Color(0xFFFFB74D),
      LogLevel.error => const Color(0xFFEF5350),
      LogLevel.fatal => const Color(0xFFFF1744),
      null => Colors.white70,
    };
  }

  Color? get bgColor {
    double opacity = 0.1;
    return switch (level) {
      LogLevel.debug => Colors.white.withValues(alpha: opacity),
      LogLevel.info => const Color(0xFF64B5F6).withValues(alpha: opacity),
      LogLevel.warning => const Color(0xFFFFB74D).withValues(alpha: opacity),
      LogLevel.error => const Color(0xFFEF5350).withValues(alpha: opacity),
      LogLevel.fatal => const Color(0xFFFF1744).withValues(alpha: opacity),
      _ => null,
    };
  }

  FontWeight get fontWeight {
    return switch (level) {
      LogLevel.error || LogLevel.fatal => FontWeight.w600,
      _ => FontWeight.normal,
    };
  }
}
