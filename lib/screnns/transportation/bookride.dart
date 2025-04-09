<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eventory/helpers/theme_helper.dart';
import 'package:intl/intl.dart';

class Bookride extends StatefulWidget {
=======
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Bookride extends StatelessWidget {
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
  final String eventId;
  final String userId;

  const Bookride({super.key, required this.eventId, required this.userId});

  @override
<<<<<<< HEAD
  State<Bookride> createState() => _BookrideState();
}

class _BookrideState extends State<Bookride> with SingleTickerProviderStateMixin {
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
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground(context),
      appBar: AppBar(
        systemOverlayStyle: Theme.of(context).brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        title: Text(
          'Available Rides',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: AppColors.textColor(context),
          ),
        ),
        backgroundColor: AppColors.cardColor(context),
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.orangePrimary),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('offerVehicles')
            .where('eventId', isEqualTo: widget.eventId)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      strokeWidth: 6,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.orangePrimary),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Loading Available Rides',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.directions_car,
                    size: 80,
                    color: Theme.of(context).hintColor,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No rides available',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Check back later or offer your own ride',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var vehicle = snapshot.data!.docs[index];
              return _buildVehicleCard(
                context,
                vehicle,
                index,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildVehicleCard(
      BuildContext context, QueryDocumentSnapshot vehicle, int index) {
    final availableSeats =
        int.tryParse(vehicle['availableSeats'].toString()) ?? 0;
    final seatingCapacity = vehicle['seatingCapacity'];

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
              color: AppColors.cardColor(context),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    if (vehicle['vehicleImage'] != null)
                      CachedNetworkImage(
                        imageUrl: vehicle['vehicleImage'],
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Theme.of(context).hoverColor,
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.orangePrimary),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Theme.of(context).hoverColor,
                          child: Icon(
                            Icons.directions_car,
                            color: AppColors.textColor(context),
                            size: 60,
                          ),
                        ),
                      ),
                    Positioned(
                      bottom: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${((seatingCapacity - availableSeats) / seatingCapacity * 100).toStringAsFixed(0)}% FULL',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicle['model'],
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColor(context),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            size: 18,
                            color: Theme.of(context).hintColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            vehicle['ownerName'],
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.credit_card,
                            size: 18,
                            color: Theme.of(context).hintColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            vehicle['plateNumber'],
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 18,
                            color: Theme.of(context).hintColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            vehicle['location'] ?? 'Not specified',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 18,
                            color: Theme.of(context).hintColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            vehicle['stayInTimePeriod'] ?? 'Not specified',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Seats',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Theme.of(context).hintColor,
                                  ),
                                ),
                                Text(
                                  seatingCapacity.toString(),
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).hintColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Available',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Theme.of(context).hintColor,
                                  ),
                                ),
                                Text(
                                  availableSeats.toString(),
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: availableSeats > 0
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: availableSeats > 0
                              ? () => _showBookRideDialog(context, vehicle)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.orangePrimary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 4,
                            shadowColor: AppColors.orangePrimary.withOpacity(0.3),
                          ),
                          child: Text(
                            availableSeats > 0 ? 'BOOK RIDE' : 'FULLY BOOKED',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
=======
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Available Rides",
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.orange,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5F5F5), Color(0xFFE0E0E0)],
          ),
        ),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('offerVehicles')
              .where('eventId', isEqualTo: eventId)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(
                color: Colors.orange,
              ));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.directions_car,
                        size: 60, color: Colors.grey[400]),
                    const SizedBox(height: 20),
                    Text(
                      "No vehicles available for this event",
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var vehicle = snapshot.data!.docs[index];
                return VehicleTile(
                  offerVehicleId: vehicle.id,
                  model: vehicle['model'],
                  ownerName: vehicle['ownerName'],
                  plateNumber: vehicle['plateNumber'],
                  seatingCapacity: vehicle['seatingCapacity'],
                  availableSeats:
                      int.tryParse(vehicle['availableSeats'].toString()) ?? 0,
                  userId: vehicle['userId'],
                  vehicleId: vehicle['vehicleId'],
                  vehicleType: vehicle['vehicleType'],
                  eventId: eventId,
                  currentUserId: userId,
                  location: vehicle['location'] ?? "Not specified",
                  stayInTimePeriod:
                      vehicle['stayInTimePeriod'] ?? "Not specified",
                  vehicleImage: vehicle['vehicleImage'], // Add vehicle image
                );
              },
            );
          },
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
        ),
      ),
    );
  }
<<<<<<< HEAD

  Future<void> _showBookRideDialog(
      BuildContext context, QueryDocumentSnapshot vehicle) async {
    final availableSeats = int.tryParse(vehicle['availableSeats'].toString()) ?? 0;
=======
}

class VehicleTile extends StatelessWidget {
  final String offerVehicleId;
  final String model;
  final String ownerName;
  final String plateNumber;
  final int seatingCapacity;
  final int availableSeats;
  final String userId;
  final String vehicleId;
  final String vehicleType;
  final String eventId;
  final String currentUserId;
  final String location;
  final String stayInTimePeriod;
  final String? vehicleImage;

  const VehicleTile({
    super.key,
    required this.offerVehicleId,
    required this.model,
    required this.ownerName,
    required this.plateNumber,
    required this.seatingCapacity,
    required this.availableSeats,
    required this.userId,
    required this.vehicleId,
    required this.vehicleType,
    required this.eventId,
    required this.currentUserId,
    required this.location,
    required this.stayInTimePeriod,
    this.vehicleImage,
  });

  Future<void> _bookRide(BuildContext context) async {
    final firestore = FirebaseFirestore.instance;
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
    TextEditingController seatsController = TextEditingController();
    bool confirmBooking = false;

    await showDialog(
      context: context,
      builder: (context) {
<<<<<<< HEAD
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.cardColor(context),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Book Ride",
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: AppColors.orangePrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (vehicle['vehicleImage'] != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: vehicle['vehicleImage'],
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Theme.of(context).hoverColor,
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Theme.of(context).hoverColor,
                            child: Icon(
                              Icons.directions_car,
                              size: 40,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    _buildDialogInfoRow(
                        context, Icons.directions_car, 'Vehicle', vehicle['model']),
                    _buildDialogInfoRow(
                        context, Icons.person, 'Owner', vehicle['ownerName']),
                    _buildDialogInfoRow(context, Icons.credit_card,
                        'Plate', vehicle['plateNumber']),
                    _buildDialogInfoRow(context, Icons.location_on, 'Location',
                        vehicle['location'] ?? 'Not specified'),
                    _buildDialogInfoRow(context, Icons.access_time, 'Time',
                        vehicle['stayInTimePeriod'] ?? 'Not specified'),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      "Available seats: $availableSeats",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColor(context),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: seatsController,
                      decoration: InputDecoration(
                        labelText: 'Number of seats',
                        labelStyle: GoogleFonts.poppins(
                          color: Theme.of(context).hintColor,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: Icon(
                          Icons.event_seat,
                          color: Theme.of(context).hintColor,
                        ),
                        errorText: seatsController.text.isNotEmpty &&
                            (int.tryParse(seatsController.text) == null ||
                                int.parse(seatsController.text) > availableSeats ||
                                int.parse(seatsController.text) <= 0)
                            ? "Enter valid number (1-$availableSeats)"
                            : null,
                      ),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textColor(context),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'CANCEL',
                            style: GoogleFonts.poppins(
                              color: Theme.of(context).hintColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () {
                            if (seatsController.text.isEmpty ||
                                int.tryParse(seatsController.text) == null ||
                                int.parse(seatsController.text) > availableSeats ||
                                int.parse(seatsController.text) <= 0) {
                              setState(() {});
                              return;
                            }
                            confirmBooking = true;
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.orangePrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                          ),
                          child: Text(
                            'CONFIRM',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
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
=======
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text("Book Ride",
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Available seats: $availableSeats",
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              TextField(
                controller: seatsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Number of seats',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.grey)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      if (seatsController.text.isNotEmpty &&
                          int.parse(seatsController.text) <= availableSeats &&
                          int.parse(seatsController.text) > 0) {
                        confirmBooking = true;
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please enter a valid number!')),
                        );
                      }
                    },
                    child: const Text('Confirm',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
        );
      },
    );

    if (confirmBooking) {
<<<<<<< HEAD
      await _processBooking(context, vehicle, int.parse(seatsController.text));
    }
  }

  Widget _buildDialogInfoRow(
      BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.orangePrimary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textColor(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processBooking(
      BuildContext context, QueryDocumentSnapshot vehicle, int seatsBooked) async {
    final firestore = FirebaseFirestore.instance;
    final rideId = await _generateRideId(firestore);

    await firestore.collection('bookedRides').add({
      'rideId': rideId,
      'userId': widget.userId,
      'eventId': widget.eventId,
      'vehicleId': vehicle['vehicleId'],
      'seatsBooked': seatsBooked,
      'ownerName': vehicle['ownerName'],
      'model': vehicle['model'],
      'plateNumber': vehicle['plateNumber'],
      'vehicleType': vehicle['vehicleType'],
      'location': vehicle['location'],
      'stayInTimePeriod': vehicle['stayInTimePeriod'],
      'vehicleImage': vehicle['vehicleImage'],
      'bookingTime': FieldValue.serverTimestamp(),
    });

    await firestore.collection('offerVehicles').doc(vehicle.id).update({
      'availableSeats': (int.tryParse(vehicle['availableSeats'].toString()) ?? 0) - seatsBooked,
    });

    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: AppColors.cardColor(context),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 60,
                  color: Colors.green,
                ),
                const SizedBox(height: 16),
                Text(
                  "Booking Confirmed!",
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor(context),
                  ),
                ),
                const SizedBox(height: 16),
                if (vehicle['vehicleImage'] != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: vehicle['vehicleImage'],
=======
      int seatsBooked = int.parse(seatsController.text);
      final rideId = await _generateRideId(firestore);

      await firestore.collection('bookedRides').add({
        'rideId': rideId,
        'userId': currentUserId,
        'eventId': eventId,
        'vehicleId': vehicleId,
        'seatsBooked': seatsBooked,
        'ownerName': ownerName,
        'model': model,
        'plateNumber': plateNumber,
        'vehicleType': vehicleType,
        'location': location,
        'stayInTimePeriod': stayInTimePeriod,
        'vehicleImage': vehicleImage,
        'bookingTime': FieldValue.serverTimestamp(),
      });

      await firestore.collection('offerVehicles').doc(offerVehicleId).update({
        'availableSeats': availableSeats - seatsBooked,
      });

      // Show success dialog
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text("Booking Confirmed",
                style: TextStyle(color: Colors.green)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (vehicleImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      vehicleImage!,
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
<<<<<<< HEAD
                  "You've successfully booked $seatsBooked seat${seatsBooked > 1 ? 's' : ''} in ${vehicle['model']}.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orangePrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      "DONE",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
=======
                    "You've successfully booked $seatsBooked seat${seatsBooked > 1 ? 's' : ''} in $model.",
                    style: const TextStyle(fontSize: 16)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK', style: TextStyle(color: Colors.orange)),
              ),
            ],
          );
        },
      );
    }
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
  }

  Future<String> _generateRideId(FirebaseFirestore firestore) async {
    final querySnapshot = await firestore
        .collection('bookedRides')
        .orderBy('rideId', descending: true)
        .limit(1)
        .get();

    int newId = 900000;
    if (querySnapshot.docs.isNotEmpty) {
      String lastRideId = querySnapshot.docs.first['rideId'];
      newId = int.parse(lastRideId.substring(1)) + 1;
    }

    return 'V$newId';
  }
<<<<<<< HEAD
}
=======

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vehicle Image
          if (vehicleImage != null && vehicleImage!.isNotEmpty)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: SizedBox(
                height: 180,
                width: double.infinity,
                child: Image.network(
                  vehicleImage!,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.directions_car, size: 60),
                    ),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      model,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        vehicleType.toUpperCase(),
                        style: TextStyle(
                          color: Colors.orange[800],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      ownerName,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const Spacer(),
                    const Icon(Icons.confirmation_number,
                        size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      plateNumber,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildInfoChip(Icons.location_on, location, Colors.blue),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                        Icons.access_time, stayInTimePeriod, Colors.green),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildSeatInfo(
                        'Total Seats', seatingCapacity.toString(), Colors.grey),
                    const SizedBox(width: 16),
                    _buildSeatInfo('Available', availableSeats.toString(),
                        availableSeats > 0 ? Colors.green : Colors.red),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed:
                        availableSeats > 0 ? () => _bookRide(context) : null,
                    child: Text(
                      availableSeats > 0 ? 'Book Now' : 'Fully Booked',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                text,
                style: TextStyle(color: color, fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeatInfo(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
