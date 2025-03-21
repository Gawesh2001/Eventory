import 'package:eventory/screnns/accomedation/accommodation_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
        icon: Icon(Icons.arrow_back, color: Colors.orange),
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
      ),
      title: Text(
        title,
        style: TextStyle(
            color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      actions: [
        Container(
          margin: EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.orange, width: 2),
          ),
          child: CircleAvatar(
            radius: 30,
            backgroundColor: Colors.green[100],
            backgroundImage: NetworkImage(profileImageUrl),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

// 2. Toggle Buttons
class ToggleButtonsWidget extends StatelessWidget {
  final int activeIndex; // Renamed from selectedIndex to avoid confusion
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
        _toggleButton("Accommodation", 0),
        _toggleButton("Transport", 1),
      ],
    );
  }

  Widget _toggleButton(String text, int index) {
    return GestureDetector(
      onTap: () => onToggle(index),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 50),
        decoration: BoxDecoration(
          color: activeIndex == index ? Colors.orange[700] : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: activeIndex == index ? Colors.white : Colors.grey,
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
      margin: EdgeInsets.only(left: 16), // Left margin
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.orange[700],
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

  const InputField({
    super.key,
    required this.label,
    required this.icon,
    required this.placeholder,
    this.isEditable = true, // Default is editable
    this.margin = const EdgeInsets.symmetric(
        horizontal: 16, vertical: 8), // Default margin
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin, // Apply margin
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 5),
          TextField(
            enabled: isEditable, // Controls editability
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: Colors.grey[400],
              ),
              hintText: placeholder, // Acts as placeholder text
              hintStyle: TextStyle(color: Colors.grey[400]),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: () => onChanged(false),
              ),
              Text(
                count.toString(),
                style: TextStyle(fontSize: 18),
              ),
              IconButton(
                icon: Icon(Icons.add),
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
          backgroundColor: Colors.orange[700],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Adjust radius as needed
          ),
        ),
        onPressed: onPressed,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Text(text,
              style: TextStyle(
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
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 5),
        GestureDetector(
          onTap: () => _selectDate(context),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDate == null
                      ? ""
                      : DateFormat('dd/MM/yyyy').format(selectedDate!),
                  style: TextStyle(
                    fontSize: 16,
                    color: selectedDate == null ? Colors.grey : Colors.black,
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  color: Colors.grey,
                ),
              ],
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
        SizedBox(width: 10),
        _buildInfoCard(
          icon: Icons.person,
          text: "$guestCount guests",
        ),
        SizedBox(width: 10),
        _buildInfoCard(
          icon: Icons.king_bed,
          text: "$roomCount rooms",
        ),
      ],
    );
  }

  Widget _buildInfoCard({required IconData icon, required String text}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 14),
      decoration: BoxDecoration(
        color: const Color.fromARGB(50, 255, 99, 26),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.orange[700], size: 18),
          SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: Colors.orange[800],
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
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.orange, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.grey[600]),
          SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: placeholder,
                border: InputBorder.none,
              ),
            ),
          ),
          if (showFilterButton)
            GestureDetector(
              onTap: onFilterTap,
              child: Icon(Icons.tune, color: Colors.grey[600]),
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

  // Reset Function
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
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                  child: Text("Cancel")),
              Text("Filter",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange)),
              TextButton(
                onPressed: resetFilters, // Reset Button
                child: Text("Reset"),
              ),
            ],
          ),

          SizedBox(height: 10),
          Text("Sort By",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          DropdownButtonFormField(
            value: "Price Lower to Higher",
            items: ["Price Lower to Higher", "Price Higher to Lower"]
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (value) {},
          ),

          SizedBox(height: 15),
          Text("Ratings",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Row(
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedRating = index + 1;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  margin: EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: selectedRating == index + 1
                            ? Colors.orange
                            : Colors.grey),
                    color: selectedRating == index + 1
                        ? Colors.orange[50]
                        : Colors.white,
                  ),
                  child: Row(
                    children: [
                      Text("${index + 1}"),
                      Icon(Icons.star, color: Colors.orange, size: 16),
                    ],
                  ),
                ),
              );
            }),
          ),

          SizedBox(height: 15),
          Text("Price Ranges",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          RangeSlider(
            values: RangeValues(_minPrice, _maxPrice),
            min: 5000,
            max: 50000,
            divisions: 10,
            activeColor: Colors.orange,
            onChanged: (RangeValues values) {
              setState(() {
                _minPrice = values.start;
                _maxPrice = values.end;
              });
            },
          ),
          Text("LKR${_minPrice.toInt()} - LKR${_maxPrice.toInt()}"),

          SizedBox(height: 15),
          Text("Facilities",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Wrap(
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
                  label: Text(facility),
                  backgroundColor:
                      isSelected ? Colors.orange[50] : Colors.white,
                  side: BorderSide(
                      color: isSelected ? Colors.orange : Colors.grey),
                ),
              );
            }).toList(),
          ),

          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              minimumSize: Size(double.infinity, 50),
            ),
            child: Text("Apply",
                style: TextStyle(fontSize: 16, color: Colors.white)),
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
        padding: const EdgeInsets.all(10), // Space around the card
        child: Material(
          elevation: 12, // Increased elevation for stronger shadow
          borderRadius: BorderRadius.circular(15),
          shadowColor: Colors.black.withOpacity(0.3), // Darker shadow
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1), // Darker shadow
                  blurRadius: 2, // Softer, more natural shadow
                  spreadRadius: 0, // Wider spread
                  offset: const Offset(0, 3), // Moves shadow downward
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
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          height: 150,
                          color: Colors.grey[300],
                        ),
                        errorWidget: (context, url, error) => Icon(Icons.error),
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
                            color: Colors.orangeAccent,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            '$discount% OFF',
                            style: TextStyle(
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
                            style: TextStyle(
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
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Colors.orange[700],
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
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'LKR $minPrice',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[700],
                    fontSize: 16,
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
