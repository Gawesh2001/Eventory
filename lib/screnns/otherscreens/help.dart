import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:eventory/helpers/theme_helper.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.scaffoldBackground(context) : Colors.white,
      appBar: AppBar(
        systemOverlayStyle: isDarkMode ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        title: Text(
          'Help & Support',
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
                  // Support illustration
                  Container(
                    height: 150,
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.blueGrey[800] : Color(0xFFFFEEE6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.support_agent,
                        size: 80,
                        color: isDarkMode ? AppColors.orangePrimary : Color(0xffFF611A),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    'How can we help you?',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: isDarkMode ? AppColors.textColor(context) : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Find answers to your questions or contact our support team',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 20),

                  // Quick options
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildQuickOption(
                        context: context,
                        icon: Icons.email_outlined,
                        label: 'Email',
                        onTap: () {
                          final Uri emailLaunchUri = Uri(
                            scheme: 'mailto',
                            path: 'contact.eventory@gmail.com',
                          );
                          launchUrl(emailLaunchUri);
                        },
                      ),
                      SizedBox(width: 20),
                      _buildQuickOption(
                        context: context,
                        icon: Icons.phone_outlined,
                        label: 'Call',
                        onTap: () {
                          final Uri phoneLaunchUri = Uri(
                            scheme: 'tel',
                            path: '0712345678',
                          );
                          launchUrl(phoneLaunchUri);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // FAQ Categories
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Frequently Asked Questions',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? AppColors.textColor(context) : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 15),
                ],
              ),
            ),

            // Ticketing & Resale Section
            _buildFAQSection(
              context: context,
              title: 'Ticketing & Resale',
              icon: '🎟️',
              questions: [
                {
                  'question': 'How do I buy tickets on Eventory?',
                  'answer': 'Navigate to the home, select an event, and follow the checkout process.',
                },
                {
                  'question': 'Can I resell a ticket I no longer need?',
                  'answer': 'Yes! Go to "My Tickets," select the ticket, and list it for resale. Resale tickets cannot be priced above the original value.',
                },
                {
                  'question': 'When will I receive payment after reselling a ticket?',
                  'answer': 'If your ticket is purchased, payment will be transferred to your account within 5 days.',
                },
                {
                  'question': 'What happens if my resale ticket isn\'t sold?',
                  'answer': 'The listing stays active until the event date or until you remove it manually.',
                },
                {
                  'question': 'Can I edit my resale ticket after posting?',
                  'answer': 'Yes, you can modify the price (within allowed limits) or remove the listing at any time.',
                },
              ],
            ),

            // Account & Privacy Section
            _buildFAQSection(
              context: context,
              title: 'Account & Privacy',
              icon: '👤',
              questions: [
                {
                  'question': 'How is my data protected?',
                  'answer': 'We store your data securely and never share it without your permission.',
                },
              ],
            ),

            // Payments & Refunds Section
            _buildFAQSection(
              context: context,
              title: 'Payments & Refunds',
              icon: '💸',
              questions: [
                {
                  'question': 'Can I get a refund for a purchased ticket?',
                  'answer': 'Tickets are non-refundable, but resale is allowed through the marketplace.',
                },
                {
                  'question': 'Are there any charges or fees for reselling?',
                  'answer': 'Currently, Eventory does not take any commission or service charge on resale listings.',
                },
              ],
            ),

            SizedBox(height: 30),

            // Contact Us Section
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isDarkMode ? Color(0xFF212B36) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Need more help?',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDarkMode ? AppColors.textColor(context) : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Our support team is available 24/7',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 25),

                  _buildContactCard(
                    context: context,
                    icon: Icons.email,
                    label: 'Email us at',
                    value: 'contact.eventory@gmail.com',
                    onTap: () {
                      final Uri emailLaunchUri = Uri(
                        scheme: 'mailto',
                        path: 'contact.eventory@gmail.com',
                      );
                      launchUrl(emailLaunchUri);
                    },
                  ),

                  SizedBox(height: 15),

                  _buildContactCard(
                    context: context,
                    icon: Icons.phone,
                    label: 'Call us at',
                    value: '0712345678',
                    onTap: () {
                      final Uri phoneLaunchUri = Uri(
                        scheme: 'tel',
                        path: '0712345678',
                      );
                      launchUrl(phoneLaunchUri);
                    },
                  ),

                  SizedBox(height: 15),

                  _buildContactCard(
                    context: context,
                    icon: Icons.location_on,
                    label: 'Visit us at',
                    value: 'C-100, Pitipana, Homagama',
                    onTap: () {
                      final Uri mapsUri = Uri(
                        scheme: 'https',
                        host: 'www.google.com',
                        path: '/maps/search/',
                        queryParameters: {
                          'query': 'C-100,Pitipana,Homagama'
                        },
                      );
                      launchUrl(mapsUri);
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 30),

            // Footer
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 20),
              color: isDarkMode ? Color(0xFF1A1F24) : Color(0xFFFFEEE6),
              child: Center(
                child: Text(
                  'We\'re here to help you 24/7',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.grey[400] : Color(0xffFF611A),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isDarkMode ? Color(0xFF2D3748) : Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24,
              color: isDarkMode ? AppColors.orangePrimary : Color(0xffFF611A),
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQSection({
    required BuildContext context,
    required String title,
    required String icon,
    required List<Map<String, String>> questions,
  }) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isDarkMode ? Color(0xFF212B36) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        childrenPadding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
        leading: Text(
          icon,
          style: TextStyle(fontSize: 24),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        children: questions.map((questionData) {
          return _buildFAQItem(
            context: context,
            question: questionData['question']!,
            answer: questionData['answer']!,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFAQItem({
    required BuildContext context,
    required String question,
    required String answer,
  }) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: isDarkMode ? Color(0xFF2D3748) : Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        childrenPadding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
        title: Text(
          question,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDarkMode ? AppColors.orangePrimary : Color(0xffFF611A),
          ),
        ),
        children: [
          Text(
            answer,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDarkMode ? Color(0xFF2D3748) : Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDarkMode ? Color(0xFF3A4556) : Color(0xFFFFEEE6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 22,
                color: isDarkMode ? AppColors.orangePrimary : Color(0xffFF611A),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDarkMode ? Colors.grey[500] : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}