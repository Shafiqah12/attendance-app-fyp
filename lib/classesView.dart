import 'package:attendify/Parts/appDrawer.dart';
import 'package:attendify/util/appRoutes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:attendify/services/auth_service.dart';
import 'package:attendify/services/api_service.dart';
import 'Theme/appTheme.dart';
import 'Parts/Custom_listCardClass.dart'; // Removed 'hide Class' to see if you can use the model from here

class ClassesViewPage extends StatefulWidget {
  const ClassesViewPage({super.key});

  @override
  State<ClassesViewPage> createState() => _ClassesViewPageState();
}

class _ClassesViewPageState extends State<ClassesViewPage> {
  List<dynamic> _classes = []; // Using dynamic to avoid 'Class' naming conflict with Flutter internal tools
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.userId;
      
      if (userId == null) {
        setState(() { _error = 'User not logged in'; _isLoading = false; });
        return;
      }

      final response = await ApiService.getClasses(userId);
      
      setState(() {
        _classes = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load classes: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      endDrawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        title: Text('Classes', style: theme.appBarTheme.titleTextStyle),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              // ... (Keep your Header Row here)
              Expanded(
                child: ListView.builder(
                  itemCount: _classes.length,
                  itemBuilder: (context, index) {
                    return listCardClass(classes: _classes[index]);
                  },
                ),
              ),
            ],
          ),
    );
  }
}