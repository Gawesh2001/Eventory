import 'package:eventory/screnns/otherscreens/terms.dart';
import 'package:flutter/material.dart';
import 'package:eventory/screnns/authentication/sign_in.dart';
import 'package:eventory/navigators/bottomnavigatorbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:eventory/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'help.dart';

class settings extends StatefulWidget {
  const settings({Key? key}) : super(key: key);

  @override
  State<settings> createState() => _SettingsState();
}

class _SettingsState extends State<settings> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.logout,
                  size: 60,
                  color: Color(0xffFF611A),
                ),
                const SizedBox(height: 16),
                Text(
                  "Log Out?",
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Are you sure you want to log out?",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "CANCEL",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _logOut();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: Text(
                        "LOG OUT",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _logOut() async {
    // When logging out:
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showWelcomeAfterLogin', false); // Reset for next login
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Sign_In()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error logging out: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Settings",
          style: GoogleFonts.poppins(
            color: const Color(0xffFF611A),
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xffFF611A)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              Animate(
                effects: [FadeEffect(), SlideEffect(begin: Offset(0, 0.1))],
                child: _buildSettingsCard(
                  title: "Preferences",
                  children: [
                    _buildSettingItem(
                      icon: Icons.notifications_active,
                      title: "Enable Notifications",
                      trailing: Switch(
                        activeColor: const Color(0xffFF611A),
                        value: _notificationsEnabled,
                        onChanged: (value) {
                          setState(() {
                            _notificationsEnabled = value;
                          });
                        },
                      ),
                    ),
                    const Divider(height: 1, color: Colors.grey),
                    _buildSettingItem(
                      icon: Icons.phone_android,
                      title: "Use System Theme",
                      trailing: Switch(
                        activeColor: const Color(0xffFF611A),
                        value: themeProvider.systemThemeEnabled,
                        onChanged: (value) {
                          themeProvider.toggleSystemTheme(value);
                        },
                      ),
                    ),
                    if (!themeProvider.systemThemeEnabled) ...[
                      const Divider(height: 1, color: Colors.grey),
                      _buildSettingItem(
                        icon: Icons.dark_mode,
                        title: "Dark Mode",
                        trailing: Switch(
                          activeColor: const Color(0xffFF611A),
                          value: themeProvider.darkModeEnabled,
                          onChanged: (value) {
                            themeProvider.toggleDarkMode(value);
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Animate(
                effects: [FadeEffect(), SlideEffect(begin: Offset(0, 0.2))],
                child: _buildSettingsCard(
                  title: "Help",
                  children: [
                    _buildSettingItem(
                      icon: Icons.description_rounded,
                      title: "Terms & Conditions",
                      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const TermsConditionsPage()));
                      },
                    ),
                    const Divider(height: 1, color: Colors.grey),
                    _buildSettingItem(
                      icon: Icons.help_center,
                      title: "Help & Support",
                      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const HelpSupportPage()));
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Animate(
                effects: [FadeEffect(), SlideEffect(begin: Offset(0, 0.3))],
                child: _buildSettingsCard(
                  title: "Actions",
                  children: [
                    _buildSettingItem(
                      icon: Icons.logout,
                      title: "Log Out",
                      textColor: Colors.redAccent,
                      iconColor: Colors.redAccent,
                      trailing: const Icon(Icons.chevron_right, color: Colors.redAccent),
                      onTap: _confirmLogout,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavigatorBar(currentIndex: 3, userId: '',),
    );
  }

  Widget _buildSettingsCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 8),
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    Color? iconColor,
    Color? textColor,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? const Color(0xffFF611A),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textColor ?? Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      minLeadingWidth: 0,
    );
  }
}