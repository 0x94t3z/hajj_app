import 'package:flutter/material.dart';
import 'package:hajj_app/helpers/styles.dart';
import 'package:iconsax/iconsax.dart';

class EditNameScreen extends StatefulWidget {
  const EditNameScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _EditNameScreenState createState() => _EditNameScreenState();
}

class _EditNameScreenState extends State<EditNameScreen> {
  final TextEditingController _nameController = TextEditingController();
  final String initialName = 'Muhamad Taopik';
  bool isButtonDisabled = true;
  bool _isLoading = false;

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: ColorSys.primary),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2),
          onPressed: () {
            Navigator.pop(context); // Navigate back when the arrow is pressed
          },
        ),
        title: Text(
          'Change Name',
          style: textStyle(color: ColorSys.primary),
        ),
        centerTitle: true,
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
                    borderSide: BorderSide(color: ColorSys.lightPrimary),
                  ),
                ),
              ),
            ),
            const Spacer(), // Push the button to the bottom
            const SizedBox(
              height: 20,
            ), // Add some space between button and content
            // Initialize isLoading to false

            Container(
              width: double.infinity, // Make the button span the entire width
              margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
              child: ElevatedButton(
                onPressed: isButtonDisabled || _isLoading
                    ? null
                    : () async {
                        String newName = _nameController.text;

                        // Set isLoading to true to indicate loading
                        setState(() {
                          _isLoading = true;
                        });

                        // Simulate a delay, replace this with your actual async operation
                        await Future.delayed(const Duration(seconds: 2));

                        // After the async operation is done, set isLoading to false
                        setState(() {
                          _isLoading = false;
                        });

                        // Handle the button press with the new name here
                        // You can access the new name using the `newName` variable
                        print('New Name: $newName');

                        // Navigate to the SettingScreen using the stored BuildContext reference
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16), // Adjust padding
                  foregroundColor: Colors.white,
                  backgroundColor: ColorSys.darkBlue,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height:
                            20, // Set the desired height for the loading indicator
                        width:
                            20, // Set the desired width for the loading indicator
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16,
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
