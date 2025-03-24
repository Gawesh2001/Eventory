import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventory/navigators/bottomnavigatorbar.dart';
import 'orders.dart'; // Import the Orders page

class Sell extends StatefulWidget {
  final String userId;

  const Sell({Key? key, required this.userId}) : super(key: key);

  @override
  _SellState createState() => _SellState();
}

class OrdersIconButton extends StatelessWidget {
  final String userId;

  const OrdersIconButton({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('market')
          .where('userId', isEqualTo: userId) // Only fetch this user's orders
          .snapshots(),
      builder: (context, snapshot) {
        int orderCount = snapshot.hasData ? snapshot.data!.docs.length : 0;

        return Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.receipt_long, color: Colors.orange),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Orders(userId: userId)),
                );
              },
            ),
            if (orderCount > 0) // Show red dot only if orders exist
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SellState extends State<Sell> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _sellPriceController = TextEditingController();
  List<Map<String, dynamic>> tickets = [];
  String? errorMessage;
  String selectedTicketType = "All"; // Default filter is "All"
  final List<String> ticketTypes = ["All", "normal", "vip", "special", "other"];
  bool isLoading = false;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  void _searchTickets() async {
    setState(() {
      isLoading = true;
      tickets = []; // Clear previous tickets while loading
    });

    String searchText = _searchController.text.trim();
    if (searchText.isEmpty) {
      setState(() {
        errorMessage = "Please enter a booking ID or ticket ID.";
        isLoading = false;
      });
      return;
    }

    int? searchId = int.tryParse(searchText);
    if (searchId == null) {
      setState(() {
        errorMessage = "Invalid ID. Please enter a number.";
        isLoading = false;
      });
      return;
    }

    try {
      QuerySnapshot ticketDocs = await FirebaseFirestore.instance
          .collection('Tickets')
          .where('userId', isEqualTo: widget.userId)
          .where('bookingId', isEqualTo: searchId)
          .get();

      if (ticketDocs.docs.isEmpty) {
        ticketDocs = await FirebaseFirestore.instance
            .collection('Tickets')
            .where('userId', isEqualTo: widget.userId)
            .where('ticketId', isEqualTo: searchId)
            .get();
      }

      if (ticketDocs.docs.isNotEmpty) {
        List<Map<String, dynamic>> ticketList = [];
        for (var doc in ticketDocs.docs) {
          var ticket = doc.data() as Map<String, dynamic>;
          DocumentSnapshot eventDoc = await FirebaseFirestore.instance
              .collection('events')
              .doc(ticket['eventId'])
              .get();

          ticket['eventName'] = eventDoc.exists ? eventDoc['eventName'] : "Unknown Event";
          ticketList.add(ticket);
        }

        setState(() {
          tickets = ticketList;
          selectedTicketType = "All"; // Reset filter to "All" after search
          errorMessage = null;
        });
      } else {
        setState(() {
          tickets = [];
          selectedTicketType = "All"; // Reset filter to "All" if no tickets are found
          errorMessage = "No tickets found for this ID.";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error fetching ticket details.";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Function to show the Sell Popup
  void _showSellPopup(Map<String, dynamic> ticket) async {
    // Check if the ticket is already listed
    QuerySnapshot marketDocs = await FirebaseFirestore.instance
        .collection('market')
        .where('ticketId', isEqualTo: ticket['ticketId'])
        .where('isListed', isEqualTo: true)
        .get();

    if (marketDocs.docs.isNotEmpty) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("This ticket is already listed for sale."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Sell Ticket", style: TextStyle(color: Colors.orange)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "You are about to sell the ticket: ${ticket['ticketId']}.",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                "Original Price: LKR ${ticket['ticketPrice']}",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _sellPriceController,
                decoration: InputDecoration(
                  hintText: "Enter selling price",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              if (_sellPriceController.text.isNotEmpty &&
                  double.parse(_sellPriceController.text) > ticket['ticketPrice'])
                const Text(
                  "Selling price cannot exceed the original price.",
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text("Cancel", style: TextStyle(color: Colors.orange)),
            ),
            ElevatedButton(
              onPressed: () async {
                double sellPrice = double.tryParse(_sellPriceController.text) ?? 0;
                if (sellPrice > ticket['ticketPrice']) {
                  _scaffoldMessengerKey.currentState?.showSnackBar(
                    const SnackBar(
                      content: Text("Selling price cannot exceed the original price."),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // Fetch event details to get expiryDate
                DocumentSnapshot eventDoc = await FirebaseFirestore.instance
                    .collection('events')
                    .doc(ticket['eventId'])
                    .get();

                if (!eventDoc.exists) {
                  _scaffoldMessengerKey.currentState?.showSnackBar(
                    const SnackBar(
                      content: Text("Event not found."),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // Add the ticket to the market collection
                await FirebaseFirestore.instance.collection('market').add({
                  'buyerId': null,
                  'currentPrice': sellPrice,
                  'eventId': ticket['eventId'],
                  'expiryDate': eventDoc['selectedDateTime'],
                  'isListed': true,
                  'isSold': false,
                  'originalPrice': ticket['ticketPrice'],
                  'ticketId': ticket['ticketId'], // Ensure ticketId is a number
                  'userId': widget.userId,
                });

                _scaffoldMessengerKey.currentState?.showSnackBar(
                  SnackBar(
                    content: Text("Ticket ${ticket['ticketId']} listed for sale!"),
                    backgroundColor: Colors.green,
                  ),
                );

                Navigator.pop(context); // Close the dialog
                _searchTickets(); // Refresh the ticket list
              },
              child: const Text("Sell", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
            ),
          ],
        );
      },
    );
  }

  // Function to show ticket details
  void _showTicketDetails(Map<String, dynamic> ticket) async {
    QuerySnapshot marketDocs = await FirebaseFirestore.instance
        .collection('market')
        .where('ticketId', isEqualTo: ticket['ticketId'])
        .get();

    if (marketDocs.docs.isEmpty) return;

    var marketData = marketDocs.docs.first.data() as Map<String, dynamic>;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Ticket Details", style: TextStyle(color: Colors.orange)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("currentPrice: ${marketData['currentPrice']}"),
                Text("eventId: ${marketData['eventId']}"),
                Text("expiryDate: ${marketData['expiryDate']}"),
                Text("isListed: ${marketData['isListed']}"),
                Text("isSold: ${marketData['isSold']}"),
                Text("originalPrice: ${marketData['originalPrice']}"),
                Text("ticketId: ${marketData['ticketId']}"),
                Text("userId: ${marketData['userId']}"),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Close", style: TextStyle(color: Colors.orange)),
            ),
          ],
        );
      },
    );
  }

  // Function to cancel a listing
  void _cancelListing(int ticketId) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Cancel Listing", style: TextStyle(color: Colors.orange)),
          content: const Text("Are you sure you want to cancel this listing?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text("No", style: TextStyle(color: Colors.orange)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context); // Close the dialog

                QuerySnapshot marketDocs = await FirebaseFirestore.instance
                    .collection('market')
                    .where('ticketId', isEqualTo: ticketId) // Ensure ticketId is a number
                    .where('isListed', isEqualTo: true)
                    .get();

                if (marketDocs.docs.isEmpty) return;

                await FirebaseFirestore.instance
                    .collection('market')
                    .doc(marketDocs.docs.first.id)
                    .delete();

                _scaffoldMessengerKey.currentState?.showSnackBar(
                  const SnackBar(
                    content: Text("Listing canceled successfully."),
                    backgroundColor: Colors.green,
                  ),
                );

                _searchTickets(); // Refresh the ticket list
              },
              child: const Text("Yes", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter tickets based on the selected ticket type
    List<Map<String, dynamic>> filteredTickets = selectedTicketType == "All"
        ? tickets
        : tickets.where((ticket) => ticket['ticketName'] == selectedTicketType).toList();

    return Scaffold(
      key: _scaffoldMessengerKey,
      appBar: AppBar(
        title: const Text("Sell Ticket"),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          // Refresh Icon Button
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.orange),
            onPressed: _searchTickets,
          ),
          // Listing/Orders Icon Button
          OrdersIconButton(userId: widget.userId),
        ],
      ),
      body: Stack(
        children: [
          if (!isLoading)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: "Enter booking ID or ticket ID",
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                              prefixIcon: const Icon(Icons.search, color: Colors.orange),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.search, color: Colors.white),
                            onPressed: _searchTickets,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Filter Section
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: ticketTypes.length,
                      itemBuilder: (context, index) {
                        String type = ticketTypes[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: ChoiceChip(
                            label: Text(type),
                            selected: selectedTicketType == type,
                            selectedColor: Colors.orange,
                            labelStyle: TextStyle(
                              color: selectedTicketType == type ? Colors.white : Colors.black,
                            ),
                            onSelected: (selected) {
                              setState(() {
                                selectedTicketType = type;
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Error Message
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ),

                  // Tickets List
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredTickets.length,
                      itemBuilder: (context, index) {
                        var ticket = filteredTickets[index];
                        return FutureBuilder<QuerySnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('market')
                              .where('ticketId', isEqualTo: ticket['ticketId'])
                              .get(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const SizedBox(); // Hide per-ticket loading indicator
                            }

                            bool isListed = snapshot.hasData &&
                                snapshot.data!.docs.isNotEmpty &&
                                (snapshot.data!.docs.first.data() as Map<String, dynamic>)['isListed'] == true;

                            bool isSold = snapshot.hasData &&
                                snapshot.data!.docs.isNotEmpty &&
                                (snapshot.data!.docs.first.data() as Map<String, dynamic>)['isSold'] == true;

                            return Card(
                              elevation: 4,
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white, // White background
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Ticket ID: ${ticket['ticketId']}",
                                      style: const TextStyle(
                                        color: Colors.black, // Black text
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      "Event: ${ticket['eventName']}",
                                      style: const TextStyle(color: Colors.black87, fontSize: 16),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      "Ticket Name: ${ticket['ticketName']}",
                                      style: const TextStyle(color: Colors.black87, fontSize: 16),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      "Price: LKR ${ticket['ticketPrice']}",
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    if (isSold)
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: Colors.green,
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: const Text(
                                              "Market",
                                              style: TextStyle(color: Colors.white, fontSize: 14),
                                            ),
                                          ),
                                          const Spacer(),
                                          IconButton(
                                            icon: const Icon(Icons.info, color: Colors.black),
                                            onPressed: () => _showTicketDetails(ticket),
                                          ),
                                        ],
                                      )
                                    else if (isListed)
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: Colors.blue,
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: const Text(
                                              "Listed",
                                              style: TextStyle(color: Colors.white, fontSize: 14),
                                            ),
                                          ),
                                          const Spacer(),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.cancel, color: Colors.white, size: 16),
                                                const SizedBox(width: 4),
                                                GestureDetector(
                                                  onTap: () => _cancelListing(ticket['ticketId'] as int), // Ensure ticketId is a number
                                                  child: const Text(
                                                    "Cancel",
                                                    style: TextStyle(color: Colors.white, fontSize: 14),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            icon: const Icon(Icons.info, color: Colors.black),
                                            onPressed: () => _showTicketDetails(ticket),
                                          ),
                                        ],
                                      )
                                    else
                                      Center(
                                        child: ElevatedButton(
                                          onPressed: () => _showSellPopup(ticket),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.orange,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                          ),
                                          child: const Text(
                                            "Sell Ticket",
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

          // Centralized Loading Indicator
          if (isLoading)
            Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange), // Orange loading indicator
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigatorBar(),
    );
  }
}