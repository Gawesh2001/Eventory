import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eventory/helpers/theme_helper.dart';
import 'package:intl/intl.dart';

class RegisterVehiclePage extends StatefulWidget {
  final String userId;
  final String eventId;

  const RegisterVehiclePage({
    super.key,
    required this.userId,
    required this.eventId,
  });

  @override
  _RegisterVehiclePageState createState() => _RegisterVehiclePageState();
}

class _RegisterVehiclePageState extends State<RegisterVehiclePage>
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
          'Your Vehicles',
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
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('vehicles')
                    .where('userId', isEqualTo: widget.userId)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
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
                            'Loading Your Vehicles',
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

                  var vehicles = snapshot.data!.docs;
                  if (vehicles.isEmpty) {
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
                            'No vehicles registered',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Register a vehicle first to offer rides',
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
                    itemCount: vehicles.length,
                    itemBuilder: (context, index) {
                      var vehicle = vehicles[index];
                      int seatingCapacity =
                          int.tryParse(vehicle['seatingCapacity'].toString()) ??
                              0;

                      return AnimatedBuilder(
                        animation: CurvedAnimation(
                          parent: _animationController,
                          curve:
                              Interval(0.1 * index, 1.0, curve: Curves.easeOut),
                        ),
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(
                                0, 50 * (1 - _animationController.value)),
                            child: Opacity(
                              opacity: _animationController.value,
                              child: child,
                            ),
                          );
                        },
                        child: VehicleCard(
                          ownerName: vehicle['ownerName'],
                          plateNumber: vehicle['plateNumber'],
                          vehicleId: vehicle['vehicleId'],
                          seatingCapacity: seatingCapacity,
                          model: vehicle['model'],
                          vehicleType: vehicle['vehicleType'],
                          userId: widget.userId,
                          eventId: widget.eventId,
                          vehicleImage: vehicle['vehicleImage'],
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
    );
  }
}

class VehicleCard extends StatelessWidget {
  final String ownerName;
  final String plateNumber;
  final String vehicleId;
  final int seatingCapacity;
  final String model;
  final String vehicleType;
  final String userId;
  final String eventId;
  final String? vehicleImage;

  const VehicleCard({
    super.key,
    required this.ownerName,
    required this.plateNumber,
    required this.vehicleId,
    required this.seatingCapacity,
    required this.model,
    required this.vehicleType,
    required this.userId,
    required this.eventId,
    this.vehicleImage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
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
              if (vehicleImage != null && vehicleImage!.isNotEmpty)
                Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: vehicleImage!,
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
                          vehicleType.toUpperCase(),
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
                      model,
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
                          ownerName,
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
                          plateNumber,
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
                          Icons.event_seat,
                          size: 18,
                          color: Theme.of(context).hintColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Seats: $seatingCapacity',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _showOfferDialog(context),
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
                          'OFFER VEHICLE',
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
    );
  }

  Future<void> _showOfferDialog(BuildContext context) async {
    TextEditingController locationController = TextEditingController();
    TextEditingController timePeriodController = TextEditingController();
    bool confirmOffer = false;

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
                      "Offer Vehicle",
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: AppColors.orangePrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (vehicleImage != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: vehicleImage!,
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
                        context, Icons.directions_car, 'Vehicle', model),
                    _buildDialogInfoRow(
                        context, Icons.person, 'Owner', ownerName),
                    _buildDialogInfoRow(
                        context, Icons.credit_card, 'Plate', plateNumber),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    TextField(
                      controller: locationController,
                      decoration: InputDecoration(
                        labelText: 'Pickup Location',
                        labelStyle: GoogleFonts.poppins(
                          color: Theme.of(context).hintColor,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: Icon(
                          Icons.location_on,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textColor(context),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: timePeriodController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Available Time Period',
                        labelStyle: GoogleFonts.poppins(
                          color: Theme.of(context).hintColor,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: Icon(
                          Icons.access_time,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      onTap: () async {
                        final TimeOfDay? start = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (start != null) {
                          final TimeOfDay? end = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay(
                              hour: start.hour + 1,
                              minute: start.minute,
                            ),
                          );
                          if (end != null) {
                            timePeriodController.text =
                                "${start.format(context)} - ${end.format(context)}";
                          }
                        }
                      },
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
                            if (locationController.text.isEmpty ||
                                timePeriodController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Please fill all fields')),
                              );
                              return;
                            }
                            confirmOffer = true;
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
                            'OFFER',
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

    if (confirmOffer) {
      await _processVehicleOffer(
        context,
        locationController.text,
        timePeriodController.text,
      );
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

  Future<void> _processVehicleOffer(
      BuildContext context, String location, String timePeriod) async {
    final firestore = FirebaseFirestore.instance;
    final offerId = await _generateOfferId(firestore);

    try {
      await firestore.collection('offerVehicles').add({
        'offerVehicleId': offerId,
        'userId': userId,
        'eventId': eventId,
        'ownerName': ownerName,
        'plateNumber': plateNumber,
        'vehicleId': vehicleId,
        'seatingCapacity': seatingCapacity,
        'availableSeats': seatingCapacity,
        'model': model,
        'vehicleType': vehicleType,
        'vehicleImage': vehicleImage,
        'location': location,
        'stayInTimePeriod': timePeriod,
        'status': 'available',
        'createdAt': FieldValue.serverTimestamp(),
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
                    "Vehicle Offered!",
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor(context),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (vehicleImage != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: vehicleImage!,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    "Your $model is now available for rides at $location",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Time: $timePeriod",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.orangePrimary,
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to offer vehicle: $e')),
      );
    }
  }

  Future<String> _generateOfferId(FirebaseFirestore firestore) async {
    final querySnapshot = await firestore
        .collection('offerVehicles')
        .orderBy('offerVehicleId', descending: true)
        .limit(1)
        .get();

    int newId = 500000;
    if (querySnapshot.docs.isNotEmpty) {
      final lastOffer = int.parse(querySnapshot.docs.first['offerVehicleId']);
      newId = lastOffer + 1;
    }

    return newId.toString();
  }
}
