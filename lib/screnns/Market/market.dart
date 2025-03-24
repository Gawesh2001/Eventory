import 'package:eventory/screnns/Market/sell.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventory/navigators/bottomnavigatorbar.dart';
import 'marketpayment.dart'; // Import the new MarketPayment page

class Market extends StatefulWidget {
  final String userId;

  const Market({Key? key, required this.userId}) : super(key: key);

  @override
  _MarketState createState() => _MarketState();
}

class _MarketState extends State<Market> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool isLoading = false;
  String? errorMessage;
  List<Map<String, dynamic>> marketListings = []; // Declare marketListings here

  @override
  void initState() {
    super.initState();
    _fetchMarketListings();
  }

  void _fetchMarketListings() async {
    setState(() {
      isLoading = true;
      errorMessage = null; // Reset error message
    });

    try {
      QuerySnapshot marketDocs = await FirebaseFirestore.instance
          .collection('market')
          .where('isListed', isEqualTo: true)
          .where('isSold', isEqualTo: false)
          .where('userId', isNotEqualTo: widget.userId)
          .get();

      List<Map<String, dynamic>> listings = [];
      for (var doc in marketDocs.docs) {
        var marketData = doc.data() as Map<String, dynamic>;
        DocumentSnapshot eventDoc = await FirebaseFirestore.instance
            .collection('events')
            .doc(marketData['eventId'])
            .get();

        if (eventDoc.exists) {
          var eventData = eventDoc.data() as Map<String, dynamic>;
          listings.add({
            ...marketData,
            'eventName': eventData['eventName'],
            'eventPhoto': eventData['eventPhoto'],
            'selectedDateTime': eventData['selectedDateTime'],
          });
        }
      }

      setState(() {
        marketListings = listings;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Error fetching market listings: ${e.toString()}";
      });
      print("Error fetching market listings: $e"); // Log the error
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter listings based on search query
    final filteredListings = marketListings.where((listing) {
      final eventName = listing['eventName'].toString().toLowerCase();
      final ticketId = listing['ticketId'].toString().toLowerCase();
      return eventName.contains(_searchQuery) || ticketId.contains(_searchQuery);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Market"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.orange),
            onPressed: _fetchMarketListings,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
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
                        hintText: "Enter Event name or Ticket ID",
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                        prefixIcon: const Icon(Icons.search, color: Colors.orange),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.toLowerCase();
                        });
                      },
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
                      onPressed: () {
                        setState(() {
                          _searchQuery = _searchController.text.toLowerCase();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          if (errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),

          Expanded(
            child: isLoading
                ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
            )
                : filteredListings.isEmpty
                ? Center(
              child: Text(
                "No listings found.",
                style: TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredListings.length,
              itemBuilder: (context, index) {
                var listing = filteredListings[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(15)),
                        child: Image.network(
                          listing['eventPhoto']['url'],
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              listing['eventName'],
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  "LKR ${listing['currentPrice'].toInt()}", // Explicitly cast to int
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "LKR ${listing['originalPrice'].toInt()}", // Explicitly cast to int
                                  style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                      decoration: TextDecoration.lineThrough),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Event Date: ${listing['selectedDateTime'].toDate().toString().split(' ')[0]}",
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Ticket ID: ${listing['ticketId']}",
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  // Navigate to MarketPayment page
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MarketPayment(
                                        userId: widget.userId,
                                        ticketId: listing['ticketId'].toString(),
                                        eventId: listing['eventId'],
                                        currentPrice: listing['currentPrice'].toInt(), // Explicitly cast to int
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: const Text(
                                  "Buy Now",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Sell(userId: widget.userId)),
          );
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigatorBar(),
    );
  }
}