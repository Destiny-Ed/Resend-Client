import 'dart:convert';
import 'dart:io' show File, Platform;

import 'package:flutter/foundation.dart';

/// Data model for email attachments.
class EmailAttachment {
  final String? path;
  final String? content;
  final String filename;

  /// List of unsupported file extensions for attachments.
  static const _unsupportedExtensions = {
    'adp', 'app', 'asp', 'bas', 'bat', 'cer', 'chm', 'cmd', 'com', 'cpl',
    'crt', 'csh', 'der', 'exe', 'fxp', 'gadget', 'hlp', 'hta', 'inf', 'ins',
    'isp', 'its', 'js', 'jse', 'ksh', 'lib', 'lnk', 'mad', 'maf', 'mag',
    'mam', 'maq', 'mar', 'mas', 'mat', 'mau', 'mav', 'maw', 'mda', 'mdb',
    'mde', 'mdt', 'mdw', 'mdz', 'msc', 'msh', 'msh1', 'msh2', 'mshxml',
    'msh1xml', 'msh2xml', 'msi', 'msp', 'mst', 'ops', 'pcd', 'pif', 'plg',
    'prf', 'prg', 'reg', 'scf', 'scr', 'sct', 'shb', 'shs', 'sys', 'ps1',
    'ps1xml', 'ps2', 'ps2xml', 'psc1', 'psc2', 'tmp', 'url', 'vb', 'vbe',
    'vbs', 'vps', 'vsmacros', 'vss', 'vst', 'vsw', 'vxd', 'ws', 'wsc',
    'wsf', 'wsh', 'xnk'
  };

  /// Creates an [EmailAttachment] with either a [path] (URL) or [content] (Base64-encoded string) and a required [filename].
  ///
  /// Exactly one of [path] or [content] must be provided.
  /// Throws [ArgumentError] if both or neither are provided, or if the file extension is unsupported.
  EmailAttachment({
    this.path,
    this.content,
    required this.filename,
  }) {
    if ((path == null) == (content == null)) {
      throw ArgumentError('Exactly one of path or content must be provided.');
    }
    final extension = filename.split('.').last.toLowerCase();
    if (_unsupportedExtensions.contains(extension)) {
      throw ArgumentError('File extension .$extension is not supported.');
    }
  }

  /// Converts a local file to a Base64-encoded [EmailAttachment].
  ///
  /// Throws [ArgumentError] if the file size exceeds 40MB or the file extension is unsupported.
  /// Not supported on web platforms.
  static Future<EmailAttachment> fromLocalFile(String filePath, {String? filename}) async {
    if (kIsWeb) {
      throw UnsupportedError('Local file attachments are not supported on web.');
    }
    final file = File(filePath);
    if (!await file.exists()) {
      throw ArgumentError('File does not exist: $filePath');
    }
    final fileSize = await file.length();
    if (fileSize > 40 * 1024 * 1024) {
      throw ArgumentError('File size exceeds 40MB limit.');
    }
    final extension = filePath.split('.').last.toLowerCase();
    if (_unsupportedExtensions.contains(extension)) {
      throw ArgumentError('File extension .$extension is not supported.');
    }
    final bytes = await file.readAsBytes();
    final base64Content = base64Encode(bytes);
    return EmailAttachment(
      content: base64Content,
      filename: filename ?? filePath.split(Platform.pathSeparator).last,
    );
  }

  /// Converts the attachment to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
        if (path != null) 'path': path,
        if (content != null) 'content': content,
        'filename': filename,
      };
}

/// Data model for an email request to the Resend API.
class EmailRequest {
  final List<String> to;
  final String from;
  final String subject;
  final String? html;
  final String? text;
  final List<String> bcc;
  final List<String> cc;
  final List<String> replyTo;
  final List<EmailAttachment> attachments;
  final String? scheduledAt;

  /// Creates an [EmailRequest] with required [to], [from], and [subject] fields.
  /// Optional fields include [html], [text], [bcc], [cc], [replyTo], [attachments], and [scheduledAt].
  const EmailRequest({
    required this.to,
    required this.from,
    required this.subject,
    this.html,
    this.text,
    this.bcc = const [],
    this.cc = const [],
    this.replyTo = const [],
    this.attachments = const [],
    this.scheduledAt,
  });

  /// Converts the email request to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
        'to': to,
        'from': from,
        'subject': subject,
        if (html != null) 'html': html,
        if (text != null) 'text': text,
        'bcc': bcc,
        'cc': cc,
        'reply_to': replyTo,
        'attachments': attachments.map((a) => a.toJson()).toList(),
        if (scheduledAt != null) 'scheduled_at': scheduledAt,
      };
}