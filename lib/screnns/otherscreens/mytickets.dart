import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'expired.dart';
import 'package:eventory/helpers/theme_helper.dart';

class MyTickets extends StatefulWidget {
  final String userId;

  const MyTickets({Key? key, required this.userId}) : super(key: key);

  @override
  _MyTicketsState createState() => _MyTicketsState();
}

class _MyTicketsState extends State<MyTickets>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All';
  bool isLoading = false;
  String? errorMessage;
  List<Map<String, dynamic>> ticketsList = [];
  Map<String, bool> isMarketplaceTicket = {};
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
    _fetchTickets();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchTickets() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      QuerySnapshot ticketsSnapshot = await FirebaseFirestore.instance
          .collection('Tickets')
          .where('userId', isEqualTo: widget.userId)
          .get();

      List<Map<String, dynamic>> tickets = [];
      for (var doc in ticketsSnapshot.docs) {
        var ticketData = doc.data() as Map<String, dynamic>;
        DocumentSnapshot eventDoc = await FirebaseFirestore.instance
            .collection('events')
            .doc(ticketData['eventId'])
            .get();

        if (eventDoc.exists) {
          var eventData = eventDoc.data() as Map<String, dynamic>;
          bool isMarketplace = await _checkIfMarketplaceTicket(
              ticketData['ticketId'].toString());
          DateTime eventDateTime = eventData['selectedDateTime'].toDate();
          bool isExpired = eventDateTime.isBefore(DateTime.now());

          if (!isExpired) {
            tickets.add({
              ...ticketData,
              'eventName': eventData['eventName'],
              'selectedDateTime': eventDateTime,
              'isMarketplace': isMarketplace,
            });

            isMarketplaceTicket[ticketData['ticketId'].toString()] =
                isMarketplace;
          }
        }
      }

      setState(() {
        ticketsList = tickets;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Error fetching tickets: ${e.toString()}";
      });
      print("Error fetching tickets: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<bool> _checkIfMarketplaceTicket(String ticketId) async {
    try {
      num? ticketIdNum = num.tryParse(ticketId);
      if (ticketIdNum == null) return false;

      QuerySnapshot marketSnapshot = await FirebaseFirestore.instance
          .collection('market')
          .where('ticketId', isEqualTo: ticketIdNum)
          .where('buyerId', isEqualTo: widget.userId)
          .where('isSold', isEqualTo: true)
          .limit(1)
          .get();

      return marketSnapshot.docs.isNotEmpty;
    } catch (e) {
      print("Error checking marketplace ticket: $e");
      return false;
    }
  }

  List<Map<String, dynamic>> _filterTickets() {
    List<Map<String, dynamic>> filtered = ticketsList.where((ticket) {
      final now = DateTime.now();
      final eventDateTime = ticket['selectedDateTime'];
      return eventDateTime.isAfter(now);
    }).toList();

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((ticket) {
        final ticketId = ticket['ticketId'].toString().toLowerCase();
        final eventName = ticket['eventName'].toString().toLowerCase();
        return ticketId.contains(_searchQuery) ||
            eventName.contains(_searchQuery);
      }).toList();
    }

    if (_selectedFilter != 'All') {
      final now = DateTime.now();
      filtered = filtered.where((ticket) {
        final eventDateTime = ticket['selectedDateTime'];

        switch (_selectedFilter) {
          case 'Today':
            return eventDateTime.year == now.year &&
                eventDateTime.month == now.month &&
                eventDateTime.day == now.day;
          case 'Tomorrow':
            final tomorrow = now.add(const Duration(days: 1));
            return eventDateTime.year == tomorrow.year &&
                eventDateTime.month == tomorrow.month &&
                eventDateTime.day == tomorrow.day;
          case 'This Week':
            final endOfWeek =
                now.add(Duration(days: DateTime.daysPerWeek - now.weekday));
            return eventDateTime.isAfter(now) &&
                eventDateTime.isBefore(endOfWeek);
          case 'This Month':
            return eventDateTime.year == now.year &&
                eventDateTime.month == now.month;
          default:
            return true;
        }
      }).toList();
    }

    return filtered;
  }

  Widget _buildTicketCard(Map<String, dynamic> ticket, int index) {
    var ticketId = ticket['ticketId'];
    var ticketName = ticket['ticketName'] ?? 'General';
    var eventName = ticket['eventName'];
    var eventDateTime = ticket['selectedDateTime'];
    var hoursRemaining = eventDateTime.difference(DateTime.now()).inHours;
    bool isMarketplace = ticket['isMarketplace'] ?? false;
    bool isUrgent = hoursRemaining < 24;
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.1 * index, 1.0, curve: Curves.easeOut),
      ),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _animationController.value)),
          child: Opacity(
            opacity: _animationController.value,
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
          child: Container(
            decoration: BoxDecoration(
              gradient: isDarkMode
                  ? null
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        isUrgent ? Color(0xFFFFF0E6) : Colors.white,
                      ],
                    ),
              color: isDarkMode
                  ? isUrgent
                      ? AppColors.orangePrimary.withOpacity(0.1)
                      : AppColors.cardColor(context)
                  : null,
              border: Border.all(
                color: isUrgent
                    ? isDarkMode
                        ? AppColors.orangePrimary.withOpacity(0.2)
                        : Color(0xffFF611A).withOpacity(0.2)
                    : isDarkMode
                        ? Theme.of(context).dividerColor
                        : Colors.grey.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
              },
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            eventName,
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode
                                  ? AppColors.textColor(context)
                                  : Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isMarketplace)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  isDarkMode
                                      ? AppColors.orangePrimary
                                      : Color(0xffFF611A),
                                  Color(0xffFF9349),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: (isDarkMode
                                          ? AppColors.orangePrimary
                                          : Color(0xffFF611A))
                                      .withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              'MARKETPLACE',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 16),
                    _buildInfoRow(Icons.confirmation_number, 'Ticket ID',
                        ticketId.toString()),
                    _buildInfoRow(Icons.category, 'Ticket Type', ticketName),
                    _buildInfoRow(Icons.calendar_today, 'Date',
                        DateFormat('EEE, MMM d, y').format(eventDateTime)),
                    _buildInfoRow(Icons.access_time, 'Time',
                        DateFormat('h:mm a').format(eventDateTime)),
                    SizedBox(height: 12),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isUrgent
                            ? isDarkMode
                                ? AppColors.orangePrimary.withOpacity(0.1)
                                : Color(0xffFF611A).withOpacity(0.1)
                            : isDarkMode
                                ? Theme.of(context).hoverColor
                                : Colors.grey.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isUrgent
                              ? isDarkMode
                                  ? AppColors.orangePrimary.withOpacity(0.3)
                                  : Color(0xffFF611A).withOpacity(0.3)
                              : isDarkMode
                                  ? Theme.of(context).dividerColor
                                  : Colors.grey.withOpacity(0.1),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Time Remaining',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isDarkMode
                                  ? Theme.of(context).hintColor
                                  : Colors.black54,
                            ),
                          ),
                          Text(
                            '${hoursRemaining}h',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: isUrgent
                                  ? isDarkMode
                                      ? AppColors.orangePrimary
                                      : Color(0xffFF611A)
                                  : isDarkMode
                                      ? AppColors.textColor(context)
                                      : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon,
              size: 20,
              color: isDarkMode ? AppColors.orangePrimary : Color(0xffFF611A)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode
                        ? Theme.of(context).hintColor
                        : Colors.black54,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode
                        ? AppColors.textColor(context)
                        : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredTickets = _filterTickets();
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode ? AppColors.scaffoldBackground(context) : Colors.grey[50],
      appBar: AppBar(
        systemOverlayStyle:
            isDarkMode ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        title: Text(
          'My Tickets',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? AppColors.textColor(context) : Colors.black87,
          ),
        ),
        backgroundColor:
            isDarkMode ? AppColors.cardColor(context) : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
            color: isDarkMode ? AppColors.orangePrimary : Color(0xffFF611A)),
        actions: [
          IconButton(
            icon: Icon(Icons.history, size: 28),
            color:
                isDarkMode ? AppColors.textColor(context) : Color(0xffFF611A),
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      Expired(userId: widget.userId),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    );
                  },
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh, size: 28),
            color:
                isDarkMode ? AppColors.textColor(context) : Color(0xffFF611A),
            onPressed: () {
              _animationController.reset();
              _fetchTickets().then((_) {
                _animationController.forward();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(30),
              shadowColor:
                  (isDarkMode ? AppColors.orangePrimary : Color(0xffFF611A))
                      .withOpacity(0.2),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color:
                      isDarkMode ? AppColors.cardColor(context) : Colors.white,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextField(
                          controller: _searchController,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: isDarkMode
                                ? AppColors.textColor(context)
                                : Colors.black87,
                          ),
                          decoration: InputDecoration(
                            hintText: "Search tickets...",
                            hintStyle: GoogleFonts.poppins(
                              color: isDarkMode
                                  ? Theme.of(context).hintColor
                                  : Colors.grey,
                            ),
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value.toLowerCase();
                            });
                          },
                        ),
                      ),
                    ),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      width: _searchQuery.isNotEmpty ? 100 : 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            isDarkMode
                                ? AppColors.orangePrimary
                                : Color(0xffFF611A),
                            Color(0xffFF9349),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(30),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: () {
                            setState(() {
                              _searchQuery =
                                  _searchController.text.toLowerCase();
                            });
                          },
                          child: Center(
                            child: AnimatedSwitcher(
                              duration: Duration(milliseconds: 300),
                              child: _searchQuery.isNotEmpty
                                  ? Text(
                                      'SEARCH',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    )
                                  : Icon(Icons.search, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children:
                    ['All', 'Today', 'Tomorrow', 'This Week', 'This Month']
                        .map((filter) => Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text(
                                  filter,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500,
                                    color: _selectedFilter == filter
                                        ? Colors.white
                                        : (isDarkMode
                                            ? AppColors.orangePrimary
                                            : Color(0xffFF611A)),
                                  ),
                                ),
                                selected: _selectedFilter == filter,
                                selectedColor: isDarkMode
                                    ? AppColors.orangePrimary
                                    : Color(0xffFF611A),
                                backgroundColor: isDarkMode
                                    ? AppColors.cardColor(context)
                                    : Colors.white,
                                shape: StadiumBorder(
                                  side: BorderSide(
                                      color: isDarkMode
                                          ? AppColors.orangePrimary
                                          : Color(0xffFF611A)),
                                ),
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedFilter = selected ? filter : 'All';
                                  });
                                },
                              ),
                            ))
                        .toList(),
              ),
            ),
          ),
          if (errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        errorMessage!,
                        style: GoogleFonts.poppins(
                          color: Colors.red[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(
                            strokeWidth: 6,
                            valueColor: AlwaysStoppedAnimation<Color>(isDarkMode
                                ? AppColors.orangePrimary
                                : Color(0xffFF611A)),
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Loading Tickets',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: isDarkMode
                                ? Theme.of(context).hintColor
                                : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  )
                : filteredTickets.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.confirmation_number_outlined,
                              size: 80,
                              color: isDarkMode
                                  ? Theme.of(context).hintColor
                                  : Colors.grey[300],
                            ),
                            SizedBox(height: 20),
                            Text(
                              'No tickets found',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: isDarkMode
                                    ? Theme.of(context).hintColor
                                    : Colors.grey,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Try adjusting your search or filter',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: isDarkMode
                                    ? Theme.of(context).hintColor
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        physics: BouncingScrollPhysics(),
                        itemCount: filteredTickets.length,
                        itemBuilder: (context, index) {
                          return _buildTicketCard(
                              filteredTickets[index], index);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
