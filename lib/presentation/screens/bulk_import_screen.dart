import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/password_model.dart';
import '../../data/database/database_helper.dart';

/// Screen for bulk importing accounts from pasted text.
///
/// Parses text to find username/password patterns and auto-creates accounts.
class BulkImportScreen extends StatefulWidget {
  final String category;
  final int? subfolderId;
  final String? subfolderName;

  const BulkImportScreen({
    super.key,
    required this.category,
    this.subfolderId,
    this.subfolderName,
  });

  @override
  State<BulkImportScreen> createState() => _BulkImportScreenState();
}

class _BulkImportScreenState extends State<BulkImportScreen> {
  final _textController = TextEditingController();
  List<ParsedAccount> _parsedAccounts = [];
  bool _isLoading = false;
  bool _isParsed = false;

  // Patterns for password detection (case insensitive)
  static final List<String> passwordPatterns = [
    'password',
    'pass',
    'pw',
    'pwd',
    'sandi',
    'kata sandi',
  ];

  // Patterns for username detection (case insensitive)
  static final List<String> usernamePatterns = [
    'username',
    'user',
    'email',
    'akun',
    'account',
    'id',
    'login',
  ];

  // Dark Theme Colors
  final Color _bgDark = const Color(0xFF050505);
  final Color _surfaceColor = const Color(0xFF121212);
  final Color _textWhite = const Color(0xFFFFFFFF);
  final Color _textGrey = const Color(0xFF9CA3AF);

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _parseText() {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Silakan paste teks terlebih dahulu',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final accounts = _extractAccounts(text);

    if (accounts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tidak ditemukan pola username/password',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _parsedAccounts = accounts;
      _isParsed = true;
    });
  }

  List<ParsedAccount> _extractAccounts(String text) {
    final accounts = <ParsedAccount>[];

    // Split by common line separators
    final lines = text.split(RegExp(r'[\n\r]+'));

    String? currentUsername;
    String? currentPassword;
    int accountIndex = 1;

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      // Try social media format first: @username password or @username: password
      final socialMediaParsed = _parseSocialMediaFormat(line);
      if (socialMediaParsed != null) {
        accounts.add(
          ParsedAccount(
            title: 'Akun $accountIndex',
            accountName: 'Akun $accountIndex',
            username: socialMediaParsed['username']!,
            password: socialMediaParsed['password']!,
          ),
        );
        accountIndex++;
        continue;
      }

      // Try to extract username
      final extractedUsername = _extractValue(line, usernamePatterns);
      if (extractedUsername != null) {
        // If we already have a username and password, save the previous account
        if (currentUsername != null && currentPassword != null) {
          accounts.add(
            ParsedAccount(
              title: 'Akun $accountIndex',
              accountName: 'Akun $accountIndex',
              username: currentUsername,
              password: currentPassword,
            ),
          );
          accountIndex++;
          currentPassword = null;
        }
        currentUsername = extractedUsername;
        continue;
      }

      // Try to extract password
      final extractedPassword = _extractValue(line, passwordPatterns);
      if (extractedPassword != null) {
        currentPassword = extractedPassword;

        // If we have both, try to save
        if (currentUsername != null) {
          accounts.add(
            ParsedAccount(
              title: 'Akun $accountIndex',
              accountName: 'Akun $accountIndex',
              username: currentUsername,
              password: currentPassword,
            ),
          );
          accountIndex++;
          currentUsername = null;
          currentPassword = null;
        }
        continue;
      }

      // Try format: "username password" or "username : password" on same line
      final sameLineParsed = _parseSameLine(line);
      if (sameLineParsed != null) {
        accounts.add(
          ParsedAccount(
            title: 'Akun $accountIndex',
            accountName: 'Akun $accountIndex',
            username: sameLineParsed['username']!,
            password: sameLineParsed['password']!,
          ),
        );
        accountIndex++;
        continue;
      }

      // Try to detect if line contains password-like content after delimiter
      final delimiterParsed = _parseWithDelimiter(line);
      if (delimiterParsed != null) {
        accounts.add(
          ParsedAccount(
            title: 'Akun $accountIndex',
            accountName: 'Akun $accountIndex',
            username: delimiterParsed['username'],
            password: delimiterParsed['password']!,
          ),
        );
        accountIndex++;
      }
    }

    // Don't forget last pair if exists
    if (currentUsername != null && currentPassword != null) {
      accounts.add(
        ParsedAccount(
          title: 'Akun $accountIndex',
          accountName: 'Akun $accountIndex',
          username: currentUsername,
          password: currentPassword,
        ),
      );
    }

    return accounts;
  }

  /// Parse social media format: @username password or @username: password
  Map<String, String>? _parseSocialMediaFormat(String line) {
    // Check if line starts with @ (social media username)
    if (!line.startsWith('@')) return null;

    // Various patterns for @username followed by password
    // Format 1: @username password (space separated)
    // Format 2: @username: password
    // Format 3: @username | password
    // Format 4: @username pw: password
    // Format 5: @username pass: password

    // First, try to find password keyword
    final passwordKeywords = ['pw:', 'pass:', 'password:', 'pwd:', 'sandi:'];
    for (final keyword in passwordKeywords) {
      final keywordIndex = line.toLowerCase().indexOf(keyword);
      if (keywordIndex > 0) {
        final username = line.substring(0, keywordIndex).trim();
        final password = line.substring(keywordIndex + keyword.length).trim();
        if (username.isNotEmpty && password.isNotEmpty) {
          return {'username': username, 'password': password};
        }
      }
    }

    // Try separator format: @username | password or @username / password
    final separators = ['|', '/', '\\', '\t', ':'];
    for (final sep in separators) {
      final sepIndex = line.indexOf(sep, 1); // Start after @
      if (sepIndex > 1) {
        final username = line.substring(0, sepIndex).trim();
        final password = line.substring(sepIndex + 1).trim();
        if (username.startsWith('@') && password.isNotEmpty) {
          return {'username': username, 'password': password};
        }
      }
    }

    // Try simple space format: @username password (only 2 parts)
    final parts = line
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.length == 2 && parts[0].startsWith('@')) {
      return {'username': parts[0], 'password': parts[1]};
    }

    // Try format with multiple spaces: @username    password
    if (parts.length >= 2 && parts[0].startsWith('@')) {
      // Take first part as username, rest as password
      return {'username': parts[0], 'password': parts.sublist(1).join(' ')};
    }

    return null;
  }

  String? _extractValue(String line, List<String> patterns) {
    final lowerLine = line.toLowerCase();

    for (final pattern in patterns) {
      // Check various formats: "pattern: value", "pattern = value", "pattern value"
      final regexPatterns = [
        RegExp('$pattern\\s*[:\\-=]\\s*(.+)', caseSensitive: false),
        RegExp('^$pattern\\s+(.+)', caseSensitive: false),
      ];

      for (final regex in regexPatterns) {
        final match = regex.firstMatch(line);
        if (match != null && match.groupCount >= 1) {
          final value = match.group(1)?.trim();
          if (value != null && value.isNotEmpty) {
            return value;
          }
        }
      }

      // Check if line starts with pattern
      if (lowerLine.startsWith(pattern)) {
        final remaining = line.substring(pattern.length).trim();
        // Remove common separators
        final cleaned = remaining
            .replaceFirst(RegExp(r'^[:\-=]\s*'), '')
            .trim();
        if (cleaned.isNotEmpty) {
          return cleaned;
        }
      }
    }
    return null;
  }

  Map<String, String>? _parseSameLine(String line) {
    // Try format: "username | password" or "username / password"
    final separators = ['|', '/', '\\', '\t', '   '];

    for (final sep in separators) {
      if (line.contains(sep)) {
        final parts = line
            .split(sep)
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        if (parts.length >= 2) {
          return {'username': parts[0], 'password': parts[1]};
        }
      }
    }
    return null;
  }

  Map<String, String?>? _parseWithDelimiter(String line) {
    // Format: "label: username / password" or similar with colon
    final colonIndex = line.indexOf(':');
    if (colonIndex > 0) {
      final afterColon = line.substring(colonIndex + 1).trim();

      // Check if there's a separator for password
      final separators = ['|', '/', '\\', 'pw:', 'pass:', 'password:'];
      for (final sep in separators) {
        final sepIndex = afterColon.toLowerCase().indexOf(sep.toLowerCase());
        if (sepIndex > 0) {
          final username = afterColon.substring(0, sepIndex).trim();
          var password = afterColon.substring(sepIndex + sep.length).trim();

          // Clean up password if it has another separator
          password = password.split(RegExp(r'[\s|/\\]')).first.trim();

          if (username.isNotEmpty && password.isNotEmpty) {
            return {'username': username, 'password': password};
          }
        }
      }

      // Single value after colon - might be password only
      if (afterColon.isNotEmpty && !afterColon.contains(' ')) {
        return {'username': null, 'password': afterColon};
      }
    }
    return null;
  }

  Future<void> _importAccounts() async {
    if (_parsedAccounts.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      int successCount = 0;

      for (final account in _parsedAccounts) {
        if (!account.isSelected) continue;

        final password = PasswordModel(
          title: account.title,
          accountName: account.accountName,
          email: null,
          username: account.username,
          password: account.password,
          isActive: true,
          category: widget.category,
          subfolderId: widget.subfolderId,
        );

        await DatabaseHelper.instance.insertPassword(password);
        successCount++;
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$successCount akun berhasil diimport',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e', style: GoogleFonts.poppins()),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _toggleAccount(int index) {
    setState(() {
      _parsedAccounts[index].isSelected = !_parsedAccounts[index].isSelected;
    });
  }

  void _editAccountTitle(int index) async {
    final controller = TextEditingController(
      text: _parsedAccounts[index].title,
    );

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Edit Judul',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: TextField(
          controller: controller,
          style: GoogleFonts.poppins(),
          decoration: InputDecoration(
            hintText: 'Judul akun',
            hintStyle: GoogleFonts.poppins(color: Colors.grey),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text('Simpan', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _parsedAccounts[index].title = result;
        _parsedAccounts[index].accountName = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: _textWhite),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Import Massal',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: _textWhite,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.folder_rounded,
                      color: Color(0xFF6C63FF),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Target Folder",
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: _textGrey,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.subfolderId != null
                              ? '${widget.category} > ${widget.subfolderName}'
                              : widget.category,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: _textWhite,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFF59E0B).withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Color(0xFFF59E0B),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Petunjuk',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFF59E0B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Paste teks yang mengandung username dan password.\n'
                    'Format yang didukung:\n'
                    '• @username password (Instagram, dll)\n'
                    '• @username: password\n'
                    '• username: value / pw: value\n'
                    '• user: value | pass: value',
                    style: GoogleFonts.poppins(fontSize: 12, color: _textGrey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Text input
            Text(
              'Paste Teks',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _textWhite,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: _surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: TextField(
                controller: _textController,
                maxLines: 8,
                style: GoogleFonts.poppins(fontSize: 13, color: _textWhite),
                decoration: InputDecoration(
                  hintText: 'Paste teks berisi username dan password...',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 13,
                    color: _textGrey,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Parse button
            if (!_isParsed)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _parseText,
                  icon: const Icon(Icons.search_rounded),
                  label: Text(
                    'Deteksi Akun',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

            // Parsed accounts list
            if (_isParsed && _parsedAccounts.isNotEmpty) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Akun Terdeteksi (${_parsedAccounts.length})',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _textWhite,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isParsed = false;
                        _parsedAccounts.clear();
                      });
                    },
                    child: Text(
                      'Reset',
                      style: GoogleFonts.poppins(color: Colors.red),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ..._parsedAccounts.asMap().entries.map((entry) {
                final index = entry.key;
                final account = entry.value;
                return _buildAccountPreview(index, account);
              }),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _importAccounts,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.download_rounded),
                  label: Text(
                    'Import ${_parsedAccounts.where((a) => a.isSelected).length} Akun',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountPreview(int index, ParsedAccount account) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: account.isSelected ? const Color(0xFF10B981) : Colors.white10,
          width: account.isSelected ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Checkbox
          GestureDetector(
            onTap: () => _toggleAccount(index),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: account.isSelected
                    ? const Color(0xFF10B981)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: account.isSelected
                      ? const Color(0xFF10B981)
                      : _textGrey,
                ),
              ),
              child: account.isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          // Account info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => _editAccountTitle(index),
                  child: Row(
                    children: [
                      Text(
                        account.title,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _textWhite,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.edit, size: 14, color: _textGrey),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                if (account.username != null)
                  Text(
                    'User: ${account.username}',
                    style: GoogleFonts.poppins(fontSize: 12, color: _textGrey),
                  ),
                Text(
                  'Pass: ${account.password}',
                  style: GoogleFonts.poppins(fontSize: 12, color: _textGrey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Model for parsed account data
class ParsedAccount {
  String title;
  String accountName;
  String? username;
  String password;
  bool isSelected;

  ParsedAccount({
    required this.title,
    required this.accountName,
    this.username,
    required this.password,
    this.isSelected = true,
  });
}
