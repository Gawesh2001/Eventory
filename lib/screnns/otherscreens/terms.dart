import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:eventory/helpers/theme_helper.dart';

class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.scaffoldBackground(context) : Color(0xFFFAFAFA),
      appBar: AppBar(
        systemOverlayStyle: isDarkMode ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        title: Text(
          'Terms & Conditions',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? AppColors.textColor(context) : Colors.black87,
          ),
        ),
        backgroundColor: isDarkMode ? AppColors.cardColor(context) : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: isDarkMode ? AppColors.orangePrimary : Color(0xffFF611A)),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            // Hero section
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.cardColor(context) : Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              padding: EdgeInsets.fromLTRB(20, 10, 20, 30),
              child: Column(
                children: [
                  // Terms icon
                  Container(
                    height: 120,
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.blueGrey[800] : Color(0xFFFFEEE6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.gavel,
                        size: 70,
                        color: isDarkMode ? AppColors.orangePrimary : Color(0xffFF611A),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Terms & Conditions',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: isDarkMode ? AppColors.textColor(context) : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Last updated: April 05, 2025',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Effective Date: April 05, 2026',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Terms content
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTermsSection(
                    context: context,
                    title: '1. Acceptance of Terms',
                    content: 'By using Eventory, you agree to comply with these terms. If you disagree, you may not use the app.',
                  ),

                  _buildTermsSection(
                    context: context,
                    title: '2. User Responsibilities',
                    content: 'You are responsible for maintaining your account security and any actions taken using it.',
                  ),

                  _buildTermsSection(
                    context: context,
                    title: '3. Ticket Purchases & Resale',
                    content: '',
                    bulletPoints: [
                      'All ticket sales are final and non-refundable.',
                      'Tickets may be resold at or below the original purchase price.',
                      'If a ticket is resold, the payment will be transferred within 5 days of sale.',
                    ],
                  ),

                  _buildTermsSection(
                    context: context,
                    title: '4. Content and Conduct',
                    content: 'You agree not to:',
                    bulletPoints: [
                      'Misrepresent or sell fake/invalid tickets.',
                      'Spam or harass other users.',
                      'Upload malicious or inappropriate content.',
                    ],
                  ),

                  _buildTermsSection(
                    context: context,
                    title: '5. Privacy & Data',
                    content: '',
                    bulletPoints: [
                      'Your data is stored securely and used in accordance with our Privacy Policy.',
                      'You may control visibility and download or delete your data at any time.',
                    ],
                  ),

                  _buildTermsSection(
                    context: context,
                    title: '6. Account Termination',
                    content: 'We reserve the right to suspend or terminate accounts that violate these terms or disrupt platform integrity.',
                  ),

                  _buildTermsSection(
                    context: context,
                    title: '7. Modifications',
                    content: 'We may update these terms at any time. Continued use after changes means acceptance of the new terms.',
                  ),
                ],
              ),
            ),

            SizedBox(height: 30),

            // Footer
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 25),
              decoration: BoxDecoration(
                color: isDarkMode ? Color(0xFF1A1F24) : Color(0xFFFFEEE6),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Have questions about our Terms?',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 10),
                  InkWell(
                    onTap: () async {
                      final Uri emailLaunchUri = Uri(
                        scheme: 'mailto',
                        path: 'contact.eventory@gmail.com',
                        queryParameters: {
                          'subject': 'Question about Terms & Conditions',
                        },
                      );

                      try {
                        await launchUrl(emailLaunchUri);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Could not launch email client.'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDarkMode ? AppColors.orangePrimary.withOpacity(0.2) : Color(0xFFFFD2C1),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: isDarkMode ? AppColors.orangePrimary.withOpacity(0.5) : Color(0xffFF611A).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.email_outlined,
                            size: 20,
                            color: isDarkMode ? AppColors.orangePrimary : Color(0xffFF611A),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Contact Support',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode ? AppColors.orangePrimary : Color(0xffFF611A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 15),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsSection({
    required BuildContext context,
    required String title,
    required String content,
    List<String>? bulletPoints,
  }) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDarkMode ? Color(0xFF212B36) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Color(0xFF2D3748) : Color(0xFFFFEEE6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.article_outlined,
                    size: 20,
                    color: isDarkMode ? AppColors.orangePrimary : Color(0xffFF611A),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (content.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(left: 16, right: 16, top: 12),
              child: Text(
                content,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                ),
              ),
            ),
          if (bulletPoints != null && bulletPoints.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(left: 16, right: 16, top: 12),
              child: Column(
                children: bulletPoints.map((point) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 6),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isDarkMode ? AppColors.orangePrimary : Color(0xffFF611A),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            point,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}