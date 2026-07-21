import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../theme.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback? onSettingsChanged;
  const SettingsScreen({super.key, this.onSettingsChanged});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _alertSound = true;
  bool _vibration = true;
  double _earSensitivity = 0.28;
  String _language = 'English';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = prefs.getBool('darkMode') ?? false;
      _alertSound = prefs.getBool('alertSound') ?? true;
      _vibration = prefs.getBool('vibration') ?? true;
      _earSensitivity = prefs.getDouble('earSensitivity') ?? 0.28;
      _language = prefs.getString('language') ?? 'English';
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) await prefs.setBool(key, value);
    if (value is double) await prefs.setDouble(key, value);
    if (value is String) await prefs.setString(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Settings',
                  style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text(context))),
              Text('Customize your experience',
                  style: GoogleFonts.inter(
                      fontSize: 14, color: AppColors.subText(context))),

              const SizedBox(height: 24),

              _sectionHeader(context, 'APPEARANCE'),
              _settingsCard(context, [
                _toggleTile(
                  context,
                  icon: Icons.dark_mode_outlined,
                  title: 'Dark Mode',
                  subtitle: _darkMode ? 'Enabled' : 'Disabled',
                  value: _darkMode,
                  onChanged: (val) {
                    setState(() => _darkMode = val);
                    _saveSetting('darkMode', val);
                    SurakshaDriveApp.of(context)?.toggleTheme(val);
                  },
                ),
              ]),

              const SizedBox(height: 16),

              _sectionHeader(context, 'ALERT SETTINGS'),
              _settingsCard(context, [
                _toggleTile(
                  context,
                  icon: Icons.volume_up_outlined,
                  title: 'Alert Sound',
                  subtitle: _alertSound ? 'Enabled' : 'Disabled',
                  value: _alertSound,
                  onChanged: (val) {
                    setState(() => _alertSound = val);
                    _saveSetting('alertSound', val);
                  },
                ),
                _divider(context),
                _toggleTile(
                  context,
                  icon: Icons.vibration_outlined,
                  title: 'Vibration',
                  subtitle: _vibration ? 'Enabled' : 'Disabled',
                  value: _vibration,
                  onChanged: (val) {
                    setState(() => _vibration = val);
                    _saveSetting('vibration', val);
                  },
                ),
              ]),

              const SizedBox(height: 16),

              _sectionHeader(context, 'DETECTION SETTINGS'),
              _settingsCard(context, [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.remove_red_eye_outlined,
                                color: AppColors.primary, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('EAR Sensitivity',
                                  style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.text(context))),
                              Text(
                                  'Threshold: ${_earSensitivity.toStringAsFixed(2)}',
                                  style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: AppColors.subText(context))),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: AppColors.primary,
                          inactiveTrackColor: AppColors.divider(context),
                          thumbColor: AppColors.primary,
                          overlayColor: AppColors.primary.withOpacity(0.12),
                        ),
                        child: Slider(
                          value: _earSensitivity,
                          min: 0.15,
                          max: 0.40,
                          divisions: 25,
                          onChanged: (val) {
                            setState(() => _earSensitivity = val);
                            _saveSetting('earSensitivity', val);
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('More Sensitive',
                              style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: AppColors.subText(context))),
                          Text('Less Sensitive',
                              style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: AppColors.subText(context))),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.lightbulb_outline,
                                color: AppColors.primary, size: 14),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                  'Lower values trigger alerts more frequently. Default: 0.28',
                                  style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: AppColors.primary)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ]),

              const SizedBox(height: 16),

              _sectionHeader(context, 'APP SETTINGS'),
              _settingsCard(context, [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.language_outlined,
                                color: AppColors.primary, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Language',
                                  style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.text(context))),
                              Text('Choose your preferred language',
                                  style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: AppColors.subText(context))),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          _langButton(context, 'English'),
                          const SizedBox(width: 10),
                          _langButton(context, 'हिन्दी'),
                        ],
                      ),
                    ],
                  ),
                ),
                _divider(context),
                _infoTile(context,
                  icon: Icons.info_outline,
                  title: 'About SurakshaDrive',
                  subtitle: 'Version 1.0.0',
                ),
              ]),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.green.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline, color: AppColors.green, size: 16),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                          '100% Private: All processing happens on your device. Your camera feed never leaves your phone.',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.green,
                              fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_outlined,
                        color: AppColors.primary, size: 16),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                          'Important: SurakshaDrive is an assistance tool, not a replacement for proper rest. Always prioritize safety.',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(title,
          style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.subText(context),
              letterSpacing: 0.8)),
    );
  }

  Widget _settingsCard(BuildContext context, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _toggleTile(BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text(context))),
                Text(subtitle,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppColors.subText(context))),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _infoTile(BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text(context))),
                Text(subtitle,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppColors.subText(context))),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.subText(context), size: 20),
        ],
      ),
    );
  }

  Widget _divider(BuildContext context) {
    return Divider(
      height: 1,
      indent: 64,
      endIndent: 16,
      color: AppColors.divider(context),
    );
  }

  Widget _langButton(BuildContext context, String lang) {
    final isSelected = _language == lang;
    return GestureDetector(
      onTap: () {
        setState(() => _language = lang);
        _saveSetting('language', lang);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.divider(context),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(lang,
            style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.subText(context))),
      ),
    );
  }
}