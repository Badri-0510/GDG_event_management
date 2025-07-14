// profile_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'auth_service.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? user = FirebaseAuth.instance.currentUser;
  
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // Controllers
  late TextEditingController _studentIdController;
  late TextEditingController _departmentController;
  late TextEditingController _yearController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;
  late TextEditingController _githubController;
  late TextEditingController _linkedinController;
  late TextEditingController _portfolioController;
  
  List<String> _skills = [];
  List<String> _achievements = [];
  List<String> _interests = [];
  
  final List<String> _availableSkills = [
    'Flutter', 'React', 'Node.js', 'Python', 'Java', 'Kotlin', 'Swift',
    'JavaScript', 'TypeScript', 'HTML/CSS', 'Firebase', 'AWS', 'Docker',
    'Machine Learning', 'AI', 'Data Science', 'UI/UX Design', 'Figma',
    'Git', 'MongoDB', 'PostgreSQL', 'MySQL', 'GraphQL', 'REST APIs'
  ];

  // Dark theme colors
  static const Color primaryColor = Color(0xFF6200EE);
  static const Color backgroundColor = Color(0xFF121212);
  static const Color surfaceColor = Color(0xFF1E1E1E);
  static const Color cardColor = Color(0xFF2A2A2A);
  static const Color textPrimaryColor = Color(0xFFFFFFFF);
  static const Color textSecondaryColor = Color(0xFFBBBBBB);
  static const Color accentColor = Color(0xFF03DAC6);

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadUserData();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  void _initializeControllers() {
    _studentIdController = TextEditingController();
    _departmentController = TextEditingController();
    _yearController = TextEditingController();
    _phoneController = TextEditingController();
    _bioController = TextEditingController();
    _githubController = TextEditingController();
    _linkedinController = TextEditingController();
    _portfolioController = TextEditingController();
  }

  Future<void> _loadUserData() async {
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user!.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _studentIdController.text = data['studentId'] ?? '';
          _departmentController.text = data['department'] ?? '';
          _yearController.text = data['year'] ?? '';
          _phoneController.text = data['phone'] ?? '';
          _bioController.text = data['bio'] ?? '';
          _githubController.text = data['githubUrl'] ?? '';
          _linkedinController.text = data['linkedinUrl'] ?? '';
          _portfolioController.text = data['portfolioUrl'] ?? '';
          _skills = List<String>.from(data['skills'] ?? []);
          _achievements = List<String>.from(data['achievements'] ?? []);
          _interests = List<String>.from(data['interests'] ?? []);
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _firestore.collection('users').doc(user!.uid).set({
          'studentId': _studentIdController.text,
          'department': _departmentController.text,
          'year': _yearController.text,
          'phone': _phoneController.text,
          'bio': _bioController.text,
          'githubUrl': _githubController.text,
          'linkedinUrl': _linkedinController.text,
          'portfolioUrl': _portfolioController.text,
          'skills': _skills,
          'achievements': _achievements,
          'interests': _interests,
          'profileCompleted': true,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        setState(() {
          _isEditing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: accentColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: AppBarTheme(
          backgroundColor: surfaceColor,
          foregroundColor: textPrimaryColor,
          elevation: 0,
        ),
        cardTheme: CardTheme(
          color: cardColor,
          elevation: 8,
          shadowColor: Colors.black54,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Profile', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
          actions: [
            if (!_isEditing)
              Container(
                margin: EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.edit, color: Colors.white, size: 20),
                  ),
                  onPressed: () {
                    setState(() {
                      _isEditing = true;
                    });
                  },
                ),
              ),
            if (_isEditing)
              Container(
                margin: EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.save, color: Colors.black, size: 20),
                  ),
                  onPressed: _isLoading ? null : _saveProfile,
                ),
              ),
            PopupMenuButton(
              icon: Icon(Icons.more_vert),
              color: cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: ListTile(
                    leading: Icon(Icons.logout, color: Colors.redAccent),
                    title: Text('Sign Out', style: TextStyle(color: textPrimaryColor)),
                    onTap: () async {
                      Navigator.pop(context);
                      await _authService.signOut();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                ),
              )
            : FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Profile Header
                        _buildProfileHeader(),
                        SizedBox(height: 30),
                        
                        // Basic Information
                        _buildSection('Basic Information', Icons.info_outline, [
                          _buildTextField('Student ID', _studentIdController, Icons.badge),
                          _buildTextField('Department', _departmentController, Icons.school),
                          _buildTextField('Year', _yearController, Icons.calendar_today),
                          _buildTextField('Phone', _phoneController, Icons.phone),
                        ]),
                        
                        // About Section
                        _buildSection('About', Icons.person_outline, [
                          _buildTextField('Bio', _bioController, Icons.description, maxLines: 3),
                        ]),
                        
                        // Skills Section
                        _buildSection('Skills', Icons.code, [
                          _buildSkillsChips(),
                        ]),
                        
                        // Achievements Section
                        _buildSection('Achievements', Icons.emoji_events, [
                          _buildListField('Achievements', _achievements),
                        ]),
                        
                        // Interests Section
                        _buildSection('Interests', Icons.favorite_outline, [
                          _buildListField('Interests', _interests),
                        ]),
                        
                        // Links Section
                        _buildSection('Links', Icons.link, [
                          _buildTextField('GitHub URL', _githubController, Icons.code),
                          _buildTextField('LinkedIn URL', _linkedinController, Icons.business),
                          _buildTextField('Portfolio URL', _portfolioController, Icons.web),
                        ]),
                        
                        SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundImage: user?.photoURL != null
                  ? CachedNetworkImageProvider(user!.photoURL!)
                  : null,
              backgroundColor: Colors.grey[300],
              child: user?.photoURL == null
                  ? Icon(Icons.person, size: 50, color: Colors.grey[600])
                  : null,
            ),
          ),
          SizedBox(height: 15),
          Text(
            user?.displayName ?? 'User Name',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 5),
          Text(
            user?.email ?? 'email@example.com',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: primaryColor, size: 24),
              SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textPrimaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {int maxLines = 1}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        enabled: _isEditing,
        maxLines: maxLines,
        style: TextStyle(color: textPrimaryColor),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: textSecondaryColor),
          prefixIcon: Icon(icon, color: primaryColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: textSecondaryColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: textSecondaryColor.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
          filled: true,
          fillColor: _isEditing ? surfaceColor : surfaceColor.withOpacity(0.5),
        ),
        validator: (value) {
          if (label == 'Student ID' && (value == null || value.isEmpty)) {
            return 'Please enter your student ID';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildSkillsChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isEditing)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableSkills.map((skill) {
              final isSelected = _skills.contains(skill);
              return FilterChip(
                label: Text(skill),
                selected: isSelected,
                selectedColor: primaryColor.withOpacity(0.3),
                checkmarkColor: primaryColor,
                backgroundColor: surfaceColor,
                labelStyle: TextStyle(
                  color: isSelected ? primaryColor : textSecondaryColor,
                ),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _skills.add(skill);
                    } else {
                      _skills.remove(skill);
                    }
                  });
                },
              );
            }).toList(),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _skills.map((skill) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: primaryColor.withOpacity(0.5)),
                ),
                child: Text(
                  skill,
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildListField(String label, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...items.asMap().entries.map((entry) {
          int index = entry.key;
          String item = entry.value;
          return Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: item,
                    enabled: _isEditing,
                    style: TextStyle(color: textPrimaryColor),
                    decoration: InputDecoration(
                      labelText: '$label ${index + 1}',
                      labelStyle: TextStyle(color: textSecondaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: textSecondaryColor.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                      filled: true,
                      fillColor: _isEditing ? surfaceColor : surfaceColor.withOpacity(0.5),
                    ),
                    onChanged: (value) {
                      items[index] = value;
                    },
                  ),
                ),
                if (_isEditing)
                  Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: IconButton(
                      icon: Icon(Icons.remove_circle, color: Colors.redAccent),
                      onPressed: () {
                        setState(() {
                          items.removeAt(index);
                        });
                      },
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
        if (_isEditing)
          Container(
            margin: EdgeInsets.only(top: 8),
            child: ElevatedButton.icon(
              icon: Icon(Icons.add, color: Colors.white),
              label: Text('Add $label', style: TextStyle(color: Colors.white)),
              onPressed: () {
                setState(() {
                  items.add('');
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _studentIdController.dispose();
    _departmentController.dispose();
    _yearController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _githubController.dispose();
    _linkedinController.dispose();
    _portfolioController.dispose();
    super.dispose();
  }
}