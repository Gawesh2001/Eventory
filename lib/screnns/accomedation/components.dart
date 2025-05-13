import 'package:eventory/screnns/accomedation/accommodation_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eventory/helpers/theme_helper.dart';
import 'package:google_fonts/google_fonts.dart';

// 1. Custom App Bar
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackPressed;
  final String profileImageUrl;

  const CustomAppBar({
    super.key,
    required this.title,
    this.onBackPressed,
    required this.profileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColors.orangePrimary),
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
            color: AppColors.textColor(context),
            fontSize: 20,
            fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.orangePrimary, width: 2),
          ),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.green[100],
            backgroundImage: NetworkImage(profileImageUrl),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// 2. Toggle Buttons
class ToggleButtonsWidget extends StatelessWidget {
  final int activeIndex;
  final Function(int) onToggle;

  const ToggleButtonsWidget({
    super.key,
    required this.activeIndex,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildToggleButton(context, "Accommodation", 0),
        _buildToggleButton(context, "Transport", 1),
      ],
    );
  }

  Widget _buildToggleButton(BuildContext context, String text, int index) {
    return GestureDetector(
      onTap: () => onToggle(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
        decoration: BoxDecoration(
          color: activeIndex == index
              ? AppColors.orangePrimary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            color: activeIndex == index
                ? Colors.white
                : Theme.of(context).hintColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// 3. Title Text
class TitleText extends StatelessWidget {
  final String text;
  const TitleText({super.key, required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 16),
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.orangePrimary,
        ),
      ),
    );
  }
}

// 4. Input Field
class InputField extends StatelessWidget {
  final String label;
  final IconData icon;
  final String placeholder;
  final bool isEditable;
  final EdgeInsetsGeometry margin;
  final TextEditingController? controller;

  const InputField({
    super.key,
    required this.label,
    required this.icon,
    required this.placeholder,
    this.controller,
    this.isEditable = true,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.textColor(context),
            ),
          ),
          const SizedBox(height: 5),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
            child: TextField(
              enabled: isEditable,
              style: GoogleFonts.poppins(
                color: AppColors.textColor(context),
              ),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  icon,
                  color: Theme.of(context).hintColor,
                ),
                hintText: placeholder,
                hintStyle: GoogleFonts.poppins(
                  color: Theme.of(context).hintColor,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.cardColor(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 5. Quantity Selector
class QuantitySelector extends StatelessWidget {
  final String label;
  final int count;
  final Function(bool) onChanged;

  const QuantitySelector({
    super.key,
    required this.label,
    required this.count,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.textColor(context),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).dividerColor,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.remove, color: AppColors.textColor(context)),
                onPressed: () => onChanged(false),
              ),
              Text(
                count.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: AppColors.textColor(context),
                ),
              ),
              IconButton(
                icon: Icon(Icons.add, color: AppColors.textColor(context)),
                onPressed: () => onChanged(true),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// 7. Button
class Button extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  const Button({super.key, required this.onPressed, required this.text});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.orangePrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(text,
              style: GoogleFonts.poppins(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

// 9. Date Picker
class DatePickerWidget extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final Function(DateTime) onDateSelected;

  const DatePickerWidget({
    super.key,
    required this.label,
    required this.selectedDate,
    required this.onDateSelected,
  });

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textColor(context),
          ),
        ),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).dividerColor,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: GestureDetector(
            onTap: () => _selectDate(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedDate == null
                        ? ""
                        : DateFormat('dd/MM/yyyy').format(selectedDate!),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: selectedDate == null
                          ? Theme.of(context).hintColor
                          : AppColors.textColor(context),
                    ),
                  ),
                  Icon(
                    Icons.calendar_today,
                    color: Theme.of(context).hintColor,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Booking Details
class AccomodationBookingDetails extends StatelessWidget {
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int guestCount;
  final int roomCount;

  const AccomodationBookingDetails({
    super.key,
    required this.checkInDate,
    required this.checkOutDate,
    required this.guestCount,
    required this.roomCount,
  });

  String formatDate(DateTime date) {
    const months = [
      "JAN",
      "FEB",
      "MAR",
      "APR",
      "MAY",
      "JUN",
      "JUL",
      "AUG",
      "SEP",
      "OCT",
      "NOV",
      "DEC"
    ];
    return "${date.day} ${months[date.month - 1]}";
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildInfoCard(
          icon: Icons.calendar_today,
          text: "${formatDate(checkInDate)} - ${formatDate(checkOutDate)}",
        ),
        const SizedBox(width: 10),
        _buildInfoCard(
          icon: Icons.person,
          text: "$guestCount guests",
        ),
        const SizedBox(width: 10),
        _buildInfoCard(
          icon: Icons.king_bed,
          text: "$roomCount rooms",
        ),
      ],
    );
  }

  Widget _buildInfoCard({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.orangePrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.orangePrimary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.orangePrimary, size: 18),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.poppins(
              color: AppColors.orangePrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class SearchBarWidget extends StatelessWidget {
  final String placeholder;
  final bool showFilterButton;
  final VoidCallback? onFilterTap;
  final ValueChanged<String>? onChanged;

  const SearchBarWidget({
    super.key,
    required this.placeholder,
    this.showFilterButton = true,
    this.onFilterTap,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cardColor(context),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.orangePrimary
              : Theme.of(context).dividerColor,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Theme.of(context).hintColor),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              style: GoogleFonts.poppins(
                color: AppColors.textColor(context),
              ),
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: GoogleFonts.poppins(
                  color: Theme.of(context).hintColor,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          if (showFilterButton)
            GestureDetector(
              onTap: onFilterTap,
              child: Icon(Icons.tune, color: Theme.of(context).hintColor),
            ),
        ],
      ),
    );
  }
}

// Filter
class FilterModal extends StatefulWidget {
  const FilterModal({super.key});

  @override
  _FilterModalState createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  double _minPrice = 9000;
  double _maxPrice = 35000;
  int? selectedRating;
  List<String> selectedFacilities = [];

  final List<String> facilities = [
    "Fast Wi-Fi",
    "AC Conference rooms",
    "In-room work stations"
  ];

  void resetFilters() {
    setState(() {
      _minPrice = 9000;
      _maxPrice = 35000;
      selectedRating = null;
      selectedFacilities.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardColor(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel",
                      style: GoogleFonts.poppins(
                        color: AppColors.textColor(context),
                      ))),
              Text("Filter",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.orangePrimary,
                  )),
              TextButton(
                onPressed: resetFilters,
                child: Text("Reset",
                    style: GoogleFonts.poppins(
                      color: AppColors.textColor(context),
                    )),
              ),
            ],
          ),

          const SizedBox(height: 10),
          Text("Sort By",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor(context),
              )),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonFormField(
              value: "Price Lower to Higher",
              items: ["Price Lower to Higher", "Price Higher to Lower"]
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e,
                            style: GoogleFonts.poppins(
                              color: AppColors.textColor(context),
                            )),
                      ))
                  .toList(),
              onChanged: (value) {},
              dropdownColor: AppColors.cardColor(context),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),

          const SizedBox(height: 15),
          Text("Ratings",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor(context),
              )),
          Row(
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedRating = index + 1;
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: selectedRating == index + 1
                            ? AppColors.orangePrimary
                            : Theme.of(context).dividerColor,
                        width: 1),
                    color: selectedRating == index + 1
                        ? AppColors.orangePrimary.withOpacity(0.1)
                        : AppColors.cardColor(context),
                  ),
                  child: Row(
                    children: [
                      Text("${index + 1}",
                          style: GoogleFonts.poppins(
                            color: AppColors.textColor(context),
                          )),
                      Icon(Icons.star,
                          color: AppColors.orangePrimary, size: 16),
                    ],
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 15),
          Text("Price Ranges",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor(context),
              )),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                RangeSlider(
                  values: RangeValues(_minPrice, _maxPrice),
                  min: 5000,
                  max: 50000,
                  divisions: 10,
                  activeColor: AppColors.orangePrimary,
                  onChanged: (RangeValues values) {
                    setState(() {
                      _minPrice = values.start;
                      _maxPrice = values.end;
                    });
                  },
                ),
                Text("LKR${_minPrice.toInt()} - LKR${_maxPrice.toInt()}",
                    style: GoogleFonts.poppins(
                      color: AppColors.textColor(context),
                    )),
              ],
            ),
          ),

          const SizedBox(height: 15),
          Text("Facilities",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor(context),
              )),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Wrap(
              spacing: 8,
              children: facilities.map((facility) {
                bool isSelected = selectedFacilities.contains(facility);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      isSelected
                          ? selectedFacilities.remove(facility)
                          : selectedFacilities.add(facility);
                    });
                  },
                  child: Chip(
                    label: Text(facility,
                        style: GoogleFonts.poppins(
                          color: AppColors.textColor(context),
                        )),
                    backgroundColor: isSelected
                        ? AppColors.orangePrimary.withOpacity(0.1)
                        : AppColors.cardColor(context),
                    side: BorderSide(
                        color: isSelected
                            ? AppColors.orangePrimary
                            : Theme.of(context).dividerColor,
                        width: 1),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.orangePrimary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: Text("Apply",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white,
                )),
          ),
        ],
      ),
    );
  }
}

class AccommodationCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String location;
  final String mapLink;
  final double rating;
  final int minPrice;
  final int discount;
  final bool isEventOffer;
  final String contact;
  final String email;
  final String description;
  final String accommodationID;
  final String website;
  final String socialMedia;

  const AccommodationCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.mapLink,
    required this.rating,
    required this.minPrice,
    this.discount = 0,
    this.isEventOffer = false,
    required this.contact,
    required this.email,
    required this.description,
    required this.accommodationID,
    required this.website,
    required this.socialMedia,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AccommodationDetailsPage(
              imageUrl: imageUrl,
              title: title,
              location: location,
              mapLink: mapLink,
              rating: rating,
              price: minPrice,
              contact: contact,
              email: email,
              description: description,
              accommodationId: accommodationID,
              website: website,
              socialMedia: socialMedia,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Material(
          elevation: 12,
          borderRadius: BorderRadius.circular(15),
          shadowColor: Colors.black.withOpacity(0.3),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.cardColor(context),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 2,
                  spreadRadius: 0,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        height: 141,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          height: 150,
                          color: Theme.of(context).hoverColor,
                        ),
                        errorWidget: (context, url, error) => Icon(Icons.error,
                            color: AppColors.textColor(context)),
                      ),
                    ),
                    if (discount > 0)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.orangePrimary,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            '$discount% OFF',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    if (isEventOffer)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                            ),
                          ),
                          child: Text(
                            'EVENT OFFER',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: AppColors.orangePrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 20),
                    Text(
                      rating.toString(),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.textColor(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on,
                        size: 14, color: Theme.of(context).hintColor),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: GoogleFonts.poppins(
                          color: Theme.of(context).hintColor,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'LKR $minPrice',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: AppColors.orangePrimary,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
