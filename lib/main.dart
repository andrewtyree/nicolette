import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';
import 'providers/worker_provider.dart';

/// Main entry point for the Nicolette application
void main() {
  // Initialize SQLite for desktop platforms
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // Initialize the ffi loader for desktop platforms
    sqfliteFfiInit();
    // Set the database factory for desktop
    databaseFactory = databaseFactoryFfi;
  }
  
  runApp(const NicoletteApp());
}

/// Root application widget
class NicoletteApp extends StatelessWidget {
  const NicoletteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WorkerProvider(),
      child: MaterialApp(
        title: 'Nicolette - Workforce Scheduling',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}

/// Simple home screen to test our worker system
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load workers when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkerProvider>().loadWorkers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nicolette - Worker Management'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<WorkerProvider>(
        builder: (context, workerProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome to Nicolette',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Phase 1: Worker Management System',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Your intelligent workforce scheduling application is ready! '
                          'We have set up the complete foundation with database, models, and state management.',
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Statistics section
                Text(
                  'Worker Statistics',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Loading state
                if (workerProvider.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Loading workers...'),
                        ],
                      ),
                    ),
                  ),
                
                // Error state
                if (workerProvider.errorMessage != null)
                  Card(
                    color: Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.error, color: Colors.red.shade700),
                              const SizedBox(width: 8),
                              Text(
                                'Error',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(workerProvider.errorMessage!),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              workerProvider.clearError();
                              workerProvider.loadWorkers();
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                // Statistics cards
                if (!workerProvider.isLoading && workerProvider.errorMessage == null)
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          icon: Icons.people,
                          title: 'Total Workers',
                          value: workerProvider.workers.length.toString(),
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          icon: Icons.check_circle,
                          title: 'Active Workers',
                          value: workerProvider.activeWorkerCount.toString(),
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          icon: Icons.star,
                          title: 'Senior Workers',
                          value: workerProvider.seniorWorkerCount.toString(),
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                
                const SizedBox(height: 24),
                
                // Workers list
                if (!workerProvider.isLoading && workerProvider.errorMessage == null)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Workers (${workerProvider.workers.length})',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: ListView.builder(
                            itemCount: workerProvider.workers.length,
                            itemBuilder: (context, index) {
                              final worker = workerProvider.workers[index];
                              return Card(
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: worker.isActive 
                                        ? Theme.of(context).colorScheme.primary 
                                        : Colors.grey,
                                    child: Text(
                                      worker.initials,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          worker.fullName,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: worker.isActive ? null : Colors.grey,
                                          ),
                                        ),
                                      ),
                                      if (worker.isSeniorWorker)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.shade100,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: Colors.orange.shade300),
                                          ),
                                          child: Text(
                                            'Senior',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.orange.shade700,
                                            ),
                                          ),
                                        ),
                                      if (!worker.isActive)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.red.shade100,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: Colors.red.shade300),
                                          ),
                                          child: Text(
                                            'Inactive',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red.shade700,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (worker.email != null && worker.email!.isNotEmpty)
                                        Text(worker.email!),
                                      if (worker.employeeId != null && worker.employeeId!.isNotEmpty)
                                        Text('ID: ${worker.employeeId}'),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Build individual stat card
  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}