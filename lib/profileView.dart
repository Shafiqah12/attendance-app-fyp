// profileView.dart
import 'package:attendify/Parts/appDrawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:attendify/services/auth_service.dart';
import 'package:attendify/services/api_service.dart';
import 'Theme/appTheme.dart';
import 'util/appRoutes.dart';

// REMOVED local UserProfile - using from api_service.dart

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  UserProfile? _userProfile;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.userId;
      final userEmail = authService.userEmail;
      final userName = authService.userName;
      
      if (userId == null) {
        setState(() {
          _error = 'User not logged in';
          _isLoading = false;
        });
        return;
      }

      // Try to get full profile from API
      final profile = await ApiService.getUserProfile(userId);
      
      if (profile != null) {
        setState(() {
          _userProfile = profile;
          _isLoading = false;
        });
      } else {
        // Create basic profile from auth service
        final nameParts = (userName ?? 'User').split(' ');
        setState(() {
          _userProfile = UserProfile(
            firstName: nameParts.isNotEmpty ? nameParts[0] : '',
            lastName: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '',
            email: userEmail ?? '',
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load profile: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTh = theme.textTheme;
    final colors = theme.colorScheme;

    return Scaffold(
      endDrawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: colors.primary,
        title: Text(
          'Profile',
          style: theme.appBarTheme.titleTextStyle,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadUserProfile,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _buildProfileContent(context, _userProfile!),
    );
  }

  Widget _buildProfileContent(BuildContext context, UserProfile profile) {
    final theme = Theme.of(context);
    final textTh = theme.textTheme;
    final colors = theme.colorScheme;

    return Column(
      children: [
        // Profile picture
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.primary.withOpacity(0.1),
                image: const DecorationImage(
                  image: AssetImage("Student_Images/StudentProfile.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: profile.firstName.isEmpty
                  ? Center(
                      child: Text(
                        profile.email.isNotEmpty ? profile.email[0].toUpperCase() : 'U',
                        style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                      ),
                    )
                  : null,
            ),
          ),
        ),

        // Details list
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _buildInfoTile(
                icon: Icons.person,
                label: 'Name',
                value: profile.fullName,
                textTh: textTh,
                colors: colors,
              ),
              _buildInfoTile(
                icon: Icons.email,
                label: 'Email',
                value: profile.email,
                textTh: textTh,
                colors: colors,
              ),
              if (profile.role != null)
                _buildInfoTile(
                  icon: Icons.work,
                  label: 'Role',
                  value: profile.role!,
                  textTh: textTh,
                  colors: colors,
                ),
              if (profile.phone != null)
                _buildInfoTile(
                  icon: Icons.phone,
                  label: 'Phone',
                  value: profile.phone!,
                  textTh: textTh,
                  colors: colors,
                ),

              // Edit Profile button
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: ElevatedButton(
                  style: theme.elevatedButtonTheme.style,
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      appRoutes.editProfilePage,
                    ).then((_) => _loadUserProfile()); // Refresh after edit
                  },
                  child: Text(
                    'Edit Profile',
                    style: textTh.labelLarge,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    required TextTheme textTh,
    required ColorScheme colors,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Icon(icon, size: 40, color: colors.primary),
        title: Text(
          label,
          style: textTh.titleSmall,
        ),
        subtitle: Text(
          value,
          style: textTh.headlineMedium,
        ),
      ),
    );
  }
}