import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class ProfilePage extends StatefulWidget {
  final int userId;

  ProfilePage({required this.userId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final DatabaseHelper dbHelper = DatabaseHelper();

  TextEditingController usernameController = TextEditingController();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController nricController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController ageController = TextEditingController();

  // Dropdown values
  String? selectedCourse;
  String? selectedSemester;

  List<String> courses = [
    'Diploma Of Computer Science',
    'Diploma Of Accountancy',
    'Diploma Of Corporate Communication',
    'Bacherlor Of Accountancy',
    'Bachelor Of Corporate Communication',
  ]; // Sample courses
  List<String> semesters = [
    'Semester 1',
    'Semester 2',
    'Semester 3',
    'Semester 4',
    'Semester 5',
    'Semester 6',
  ]; // Sample semesters

  // Function to fetch user details
  Future<void> _loadUserData() async {
    try {
      var user = await dbHelper.getUserDataById(
        widget.userId,
      ); // Fetch user data from 'users' table
      var userDetails = await dbHelper.getUserDetail(
        widget.userId,
      ); // Fetch user details from 'user_detail' table

      if (user != null) {
        setState(() {
          emailController.text = user['email'] ?? '';
          usernameController.text = user['name'] ?? '';
        });
      }

      if (userDetails != null) {
        setState(() {
          fullNameController.text = userDetails['user_fullname'] ?? '';
          nricController.text = userDetails['nric'] ?? '';
          phoneController.text = userDetails['nophone'] ?? '';
          ageController.text = userDetails['age']?.toString() ?? '';

          // Ensure the selected values are part of the list
          selectedCourse =
              courses.contains(userDetails['course'])
                  ? userDetails['course']
                  : courses.first;
          selectedSemester =
              semesters.contains(userDetails['semester'])
                  ? userDetails['semester']
                  : semesters.first;
        });
      } else {
        print("No user details found for userId: ${widget.userId}");
      }
    } catch (e) {
      print("Error loading user data: $e");
    }
  }

  // Function to update user details
  Future<void> _updateUserDetails() async {
    if (_formKey.currentState!.validate()) {
      int result = await dbHelper.insertUserDetail({
        'id': widget.userId,
        'username': usernameController.text,
        'user_fullname': fullNameController.text,
        'user_email': emailController.text,
        'course': selectedCourse, // Store selected course
        'semester': selectedSemester, // Store selected semester
        'nric': nricController.text,
        'nophone': phoneController.text,
        'age': int.tryParse(ageController.text) ?? 0,
      });

      if (result > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully!')),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update profile.')));
      }
    }
  }

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load user data when the page is created
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Profile')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField('Email', emailController, enabled: false),
              _buildTextField('Username', usernameController),
              _buildTextField('Full Name', fullNameController),

              // Course Dropdown
              DropdownButtonFormField<String>(
                value: selectedCourse,
                decoration: InputDecoration(
                  labelText: 'Course',
                  border: OutlineInputBorder(),
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCourse = newValue;
                  });
                },
                items:
                    courses.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a course';
                  }
                  return null;
                },
              ),

              // Semester Dropdown
              DropdownButtonFormField<String>(
                value: selectedSemester,
                decoration: InputDecoration(
                  labelText: 'Semester',
                  border: OutlineInputBorder(),
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedSemester = newValue;
                  });
                },
                items:
                    semesters.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a semester';
                  }
                  return null;
                },
              ),

              _buildTextField('NRIC', nricController),
              _buildTextField(
                'Phone Number',
                phoneController,
                keyboardType: TextInputType.phone,
              ),
              _buildTextField(
                'Age',
                ageController,
                keyboardType: TextInputType.number,
              ),

              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateUserDetails,
                child: Text('Update Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build text input fields
  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        enabled: enabled,
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
