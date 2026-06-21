import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cinewave/core/theme/app_theme.dart';
import 'package:cinewave/core/theme/bloc/theme_bloc.dart';
import 'package:cinewave/core/constants/app_constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = true;
  bool _autoPlayNext = true;
  String _preferredLanguage = 'English';
  late SharedPreferences _prefs;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = _prefs.getBool('dark_mode') ?? true;
      _autoPlayNext = _prefs.getBool('auto_play_next') ?? true;
      _preferredLanguage = _prefs.getString('preferred_language') ?? 'English';
      _loading = false;
    });
  }

  Future<void> _toggleDarkMode(bool value) async {
    await context.read<ThemeBloc>().toggleTheme(value);
    setState(() => _isDarkMode = value);
  }

  Future<void> _toggleAutoPlay(bool value) async {
    await _prefs.setBool('auto_play_next', value);
    setState(() => _autoPlayNext = value);
  }

  Future<void> _clearCache() async {
    await DefaultCacheManager().emptyCache();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cache cleared successfully')),
      );
    }
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
       appBar: AppBar(
         automaticallyImplyLeading: false,
         title: const Text('Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
         backgroundColor: Colors.black,
         elevation: 0,
       ),
      body: ListView(
        children: [
          _buildSectionHeader('Appearance'),
          SwitchListTile(
            title: const Text('Dark Mode', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Use darker theme across the app', style: TextStyle(color: Colors.white54)),
            value: _isDarkMode,
            onChanged: _toggleDarkMode,
            activeColor: const Color(0xFF46D369),
          ),
          
          _buildSectionHeader('Playback'),
          SwitchListTile(
            title: const Text('Auto-play Next', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Automatically start next episode', style: TextStyle(color: Colors.white54)),
            value: _autoPlayNext,
            onChanged: _toggleAutoPlay,
            activeColor: const Color(0xFF46D369),
          ),
          ListTile(
            title: const Text('Preferred Language', style: TextStyle(color: Colors.white)),
            subtitle: Text(_preferredLanguage, style: const TextStyle(color: Colors.white54)),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
            onTap: () {
               // Logic to select language
            },
          ),

          _buildSectionHeader('Storage'),
          ListTile(
            title: const Text('Clear App Cache', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Delete temporary data & image cache', style: TextStyle(color: Colors.white54)),
            trailing: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
            onTap: _clearCache,
          ),

          _buildSectionHeader('About'),
          const ListTile(
            title: Text('App Version', style: TextStyle(color: Colors.white)),
            trailing: Text('1.0.0', style: TextStyle(color: Colors.white54)),
          ),
          ListTile(
            title: const Text('Privacy Policy', style: TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.open_in_new, color: Colors.white24, size: 16),
            onTap: () => _launchURL('https://ayesh-chamodye.github.io/CineWave/privacy-policy.html'),
          ),
          const SizedBox(height: 40),
          Center(
            child: Text(
              'CineWave • Made with ❤️',
              style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 12),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF46D369),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
