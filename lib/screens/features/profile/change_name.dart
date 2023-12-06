import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hajj_app/helpers/styles.dart';
import 'package:iconsax/iconsax.dart';

class EditNameScreen extends StatefulWidget {
  final String initialName;
  final Function(String) updateName;

  const EditNameScreen({
    Key? key,
    required this.initialName,
    required this.updateName,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _EditNameScreenState createState() => _EditNameScreenState();
}

class _EditNameScreenState extends State<EditNameScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool isButtonDisabled = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName;
    _nameController.addListener(_onNameChanged);
  }

  Future<void> _saveChanges() async {
    String newName = _nameController.text;

    // Update the name in the Realtime Database
    widget.updateName(newName);

    // Refresh the user data to sync changes with the server
    try {
      await FirebaseAuth.instance.currentUser!.reload();
    } catch (e) {
      print("Error while reloading user data: $e");
    }

    // ignore: use_build_context_synchronously
    Navigator.pop(context, newName);
  }

  void _onNameChanged() {
    final newName = _nameController.text;
    setState(() {
      isButtonDisabled = newName.isEmpty || newName == widget.initialName;
    });
  }

  @override
  void dispose() {
    // _nameController.removeListener(_onNameChanged);
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

                        // Call the saveChanges method
                        await _saveChanges();
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
