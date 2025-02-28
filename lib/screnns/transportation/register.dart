import 'package:flutter/material.dart';

class RegisterVehiclePage extends StatefulWidget {
  const RegisterVehiclePage({super.key});

  @override
  _RegisterVehiclePageState createState() => _RegisterVehiclePageState();
}

class _RegisterVehiclePageState extends State<RegisterVehiclePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _vehicleTypeController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _plateNumberController = TextEditingController();
  final TextEditingController _vehicleColorController = TextEditingController();
  final TextEditingController _seatingCapacityController =
      TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();

  @override
  void dispose() {
    _vehicleTypeController.dispose();
    _modelController.dispose();
    _plateNumberController.dispose();
    _vehicleColorController.dispose();
    _seatingCapacityController.dispose();
    _ownerNameController.dispose();
    _contactNumberController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Handle form submission (e.g., send data to Firestore)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vehicle Registered Successfully!')),
      );
      Navigator.pop(context); // Return to previous screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register Vehicle'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(_vehicleTypeController, 'Vehicle Type'),
              _buildTextField(_modelController, 'Model'),
              _buildTextField(_plateNumberController, 'Plate Number'),
              _buildTextField(_vehicleColorController, 'Vehicle Color'),
              _buildTextField(_seatingCapacityController, 'Seating Capacity',
                  isNumber: true),
              _buildTextField(_ownerNameController, 'Owner Full Name'),
              _buildTextField(_contactNumberController, 'Contact Number',
                  isNumber: true),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text('Confirm', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }
}
