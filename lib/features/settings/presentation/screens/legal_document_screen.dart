import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:tagme/core/constants/app_spacing.dart';

/// Screen that loads and renders a bundled HTML legal document.
///
/// The [type] parameter determines which document to display:
/// - `'privacy'` loads `assets/legal/privacy_policy.html`
/// - `'terms'` loads `assets/legal/terms_of_service.html`
class LegalDocumentScreen extends StatefulWidget {
  const LegalDocumentScreen({required this.type, super.key});

  /// The type of legal document: `'privacy'` or `'terms'`.
  final String type;

  @override
  State<LegalDocumentScreen> createState() => _LegalDocumentScreenState();
}

class _LegalDocumentScreenState extends State<LegalDocumentScreen> {
  String _htmlContent = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDocument();
  }

  Future<void> _loadDocument() async {
    final fileName = widget.type == 'privacy'
        ? 'privacy_policy.html'
        : 'terms_of_service.html';
    final content = await rootBundle.loadString('assets/legal/$fileName');
    if (mounted) {
      setState(() {
        _htmlContent = content;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.type == 'privacy'
        ? 'Privacy Policy'
        : 'Terms of Service';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _parseHtmlToWidgets(_htmlContent, context),
              ),
            ),
    );
  }

  /// Parses simple HTML content into a list of Flutter widgets.
  ///
  /// Handles `<h1>`, `<h2>`, `<p>`, `<ul>`, and `<li>` tags by mapping
  /// them to appropriately styled [Text] widgets.
  List<Widget> _parseHtmlToWidgets(String html, BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final widgets = <Widget>[];

    // Remove DOCTYPE, html, head, body tags and extract body content.
    var body = html;
    final bodyMatch = RegExp(
      r'<body[^>]*>([\s\S]*)</body>',
      caseSensitive: false,
    ).firstMatch(body);
    if (bodyMatch != null) {
      body = bodyMatch.group(1)!;
    }

    // Split by tags and process each element.
    final tagPattern = RegExp(
      r'<(/?)(h1|h2|p|ul|li|strong)\b[^>]*>',
      caseSensitive: false,
    );

    final segments = <_HtmlSegment>[];
    var lastEnd = 0;

    for (final match in tagPattern.allMatches(body)) {
      // Capture text before this tag.
      if (match.start > lastEnd) {
        final textBefore = body.substring(lastEnd, match.start).trim();
        if (textBefore.isNotEmpty) {
          segments.add(_HtmlSegment(tag: 'text', content: textBefore));
        }
      }

      final isClosing = match.group(1) == '/';
      final tag = match.group(2)!.toLowerCase();

      if (!isClosing) {
        // Find the closing tag and extract content.
        final closePattern = RegExp(
          '</$tag>',
          caseSensitive: false,
        );
        final closeMatch = closePattern.firstMatch(
          body.substring(match.end),
        );

        if (closeMatch != null) {
          final content = body
              .substring(match.end, match.end + closeMatch.start)
              .trim();
          segments.add(_HtmlSegment(tag: tag, content: content));
          lastEnd = match.end + closeMatch.end;
        } else {
          lastEnd = match.end;
        }
      } else {
        lastEnd = match.end;
      }
    }

    // Process segments into widgets.
    for (final segment in segments) {
      switch (segment.tag) {
        case 'h1':
          widgets
            ..add(const SizedBox(height: AppSpacing.md))
            ..add(
              Text(
                _stripInnerTags(segment.content),
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
            ..add(const SizedBox(height: AppSpacing.sm));
        case 'h2':
          widgets
            ..add(const SizedBox(height: AppSpacing.md))
            ..add(
              Text(
                _stripInnerTags(segment.content),
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
            ..add(const SizedBox(height: AppSpacing.sm));
        case 'p':
          widgets
            ..add(
              _buildRichText(segment.content, textTheme.bodyMedium),
            )
            ..add(const SizedBox(height: AppSpacing.sm));
        case 'li':
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.md,
                bottom: AppSpacing.xs,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('\u2022 ', style: textTheme.bodyMedium),
                  Expanded(
                    child: _buildRichText(
                      segment.content,
                      textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          );
        case 'ul':
          // Container tag; children (li) are processed individually.
          break;
        default:
          if (segment.content.isNotEmpty) {
            widgets.add(Text(
              _stripInnerTags(segment.content),
              style: textTheme.bodyMedium,
            ));
          }
      }
    }

    return widgets;
  }

  /// Builds a [RichText] widget that handles `<strong>` tags for bold text.
  Widget _buildRichText(String html, TextStyle? baseStyle) {
    final spans = <InlineSpan>[];
    final strongPattern = RegExp(
      '<strong>(.*?)</strong>',
      caseSensitive: false,
    );

    var lastEnd = 0;
    for (final match in strongPattern.allMatches(html)) {
      if (match.start > lastEnd) {
        final text = _stripInnerTags(html.substring(lastEnd, match.start));
        if (text.isNotEmpty) {
          spans.add(TextSpan(text: text, style: baseStyle));
        }
      }
      spans.add(TextSpan(
        text: _stripInnerTags(match.group(1)!),
        style: baseStyle?.copyWith(fontWeight: FontWeight.bold),
      ));
      lastEnd = match.end;
    }

    if (lastEnd < html.length) {
      final text = _stripInnerTags(html.substring(lastEnd));
      if (text.isNotEmpty) {
        spans.add(TextSpan(text: text, style: baseStyle));
      }
    }

    if (spans.isEmpty) {
      return Text(_stripInnerTags(html), style: baseStyle);
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }

  /// Removes all remaining HTML tags from a string.
  String _stripInnerTags(String html) {
    return html
        .replaceAll(RegExp('<[^>]*>'), '')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&mdash;', '\u2014')
        .replaceAll('&ndash;', '\u2013')
        .trim();
  }
}

/// A parsed HTML segment with its tag type and text content.
class _HtmlSegment {
  const _HtmlSegment({required this.tag, required this.content});
  final String tag;
  final String content;
}
