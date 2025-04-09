import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eventory/helpers/theme_helper.dart';
import 'package:intl/intl.dart';

class Bookride extends StatefulWidget {
  final String eventId;
  final String userId;

  const Bookride({super.key, required this.eventId, required this.userId});

  @override
  State<Bookride> createState() => _BookrideState();
}

class _BookrideState extends State<Bookride>
    with SingleTickerProviderStateMixin {
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
                            shadowColor:
                                AppColors.orangePrimary.withOpacity(0.3),
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
        ),
      ),
    );
  }

  Future<void> _showBookRideDialog(
      BuildContext context, QueryDocumentSnapshot vehicle) async {
    final availableSeats =
        int.tryParse(vehicle['availableSeats'].toString()) ?? 0;
    TextEditingController seatsController = TextEditingController();
    bool confirmBooking = false;

    await showDialog(
      context: context,
      builder: (context) {
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
                    _buildDialogInfoRow(context, Icons.directions_car,
                        'Vehicle', vehicle['model']),
                    _buildDialogInfoRow(
                        context, Icons.person, 'Owner', vehicle['ownerName']),
                    _buildDialogInfoRow(context, Icons.credit_card, 'Plate',
                        vehicle['plateNumber']),
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
                                    int.parse(seatsController.text) >
                                        availableSeats ||
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
                                int.parse(seatsController.text) >
                                    availableSeats ||
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
        );
      },
    );

    if (confirmBooking) {
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

  Future<void> _processBooking(BuildContext context,
      QueryDocumentSnapshot vehicle, int seatsBooked) async {
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
      'availableSeats':
          (int.tryParse(vehicle['availableSeats'].toString()) ?? 0) -
              seatsBooked,
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
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
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
}
