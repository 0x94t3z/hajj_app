import 'package:flutter/material.dart';
import 'package:hajj_app/helpers/styles.dart';

class EditNameScreen extends StatefulWidget {
  const EditNameScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _EditNameScreenState createState() => _EditNameScreenState();
}

class _EditNameScreenState extends State<EditNameScreen> {
  TextEditingController _nameController = TextEditingController();
  final String initialName = 'Muhamad Taopik';
  bool isButtonDisabled = true;

  @override
  void initState() {
    super.initState();
    _nameController.text = initialName; // Set initial value here
    _nameController.addListener(_onNameChanged);
  }

  void _onNameChanged() {
    final newName = _nameController.text;
    setState(() {
      isButtonDisabled = newName.isEmpty || newName == initialName;
    });
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: ColorSys.primary),
        title: const Text(
          'Change Name',
          style: TextStyle(color: ColorSys.primary),
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 30),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'New Name',
                  labelStyle: textStyle(fontSize: 14),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: ColorSys.primary),
                  ),
                ),
              ),
            ),
            const Spacer(), // Push the button to the bottom
            const SizedBox(
              height: 20,
            ), // Add some space between button and content
            Container(
              width: double.infinity, // Make the button span the entire width
              margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
              child: ElevatedButton(
                onPressed: isButtonDisabled
                    ? null // Disable the button if conditions are met
                    : () {
                        String newName = _nameController.text;
                        // Handle the button press with the new name here
                        // You can access the new name using the `newName` variable
                        print('New Name: $newName');
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16), // Adjust padding
                  foregroundColor: Colors.white,
                  backgroundColor: ColorSys.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
