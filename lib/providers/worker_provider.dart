import 'package:flutter/foundation.dart';
import '../models/worker.dart';
import '../repositories/worker_repository.dart';

/// Provider class for managing Worker state and operations
/// 
/// This class acts as a bridge between the UI and the data layer,
/// providing state management for worker-related operations using
/// the Provider pattern.
class WorkerProvider extends ChangeNotifier {
  final WorkerRepository _workerRepository = WorkerRepository();

  // Private state variables
  List<Worker> _workers = [];
  List<Worker> _filteredWorkers = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  bool _showActiveOnly = true;

  // Public getters for accessing state
  
  /// List of all workers (unfiltered)
  List<Worker> get workers => _workers;
  
  /// List of workers after applying filters and search
  List<Worker> get filteredWorkers => _filteredWorkers;
  
  /// Current loading state
  bool get isLoading => _isLoading;
  
  /// Current error message (null if no error)
  String? get errorMessage => _errorMessage;
  
  /// Current search query
  String get searchQuery => _searchQuery;
  
  /// Whether to show only active workers
  bool get showActiveOnly => _showActiveOnly;
  
  /// Get count of active workers
  int get activeWorkerCount => _workers.where((w) => w.isActive).length;
  
  /// Get count of senior workers
  int get seniorWorkerCount => _workers.where((w) => w.isSeniorWorker && w.isActive).length;

  /// Load all workers from the database
  /// 
  /// This method fetches workers and applies current filters
  Future<void> loadWorkers() async {
    _setLoading(true);
    _clearError();

    try {
      _workers = await _workerRepository.getAllWorkers();
      _applyFilters();
    } catch (e) {
      _setError('Failed to load workers: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Create a new worker
  /// 
  /// Returns the ID of the created worker, or null if creation failed
  Future<int?> createWorker(Worker worker) async {
    _clearError();

    try {
      // Validate worker data before creation
      _validateWorker(worker);
      
      // Check for unique constraints
      if (worker.email != null && worker.email!.isNotEmpty) {
        final emailExists = await _workerRepository.isEmailInUse(worker.email!);
        if (emailExists) {
          throw Exception('Email address is already in use');
        }
      }
      
      if (worker.employeeId != null && worker.employeeId!.isNotEmpty) {
        final employeeIdExists = await _workerRepository.isEmployeeIdInUse(worker.employeeId!);
        if (employeeIdExists) {
          throw Exception('Employee ID is already in use');
        }
      }

      final id = await _workerRepository.createWorker(worker);
      
      // Reload workers to reflect the new addition
      await loadWorkers();
      
      return id;
    } catch (e) {
      _setError('Failed to create worker: ${e.toString()}');
      return null;
    }
  }

  /// Update an existing worker
  /// 
  /// Returns true if update was successful
  Future<bool> updateWorker(Worker worker) async {
    _clearError();

    try {
      if (worker.id == null) {
        throw Exception('Cannot update worker without ID');
      }

      // Validate worker data before update
      _validateWorker(worker);
      
      // Check for unique constraints (excluding current worker)
      if (worker.email != null && worker.email!.isNotEmpty) {
        final emailExists = await _workerRepository.isEmailInUse(
          worker.email!, 
          excludeWorkerId: worker.id,
        );
        if (emailExists) {
          throw Exception('Email address is already in use');
        }
      }
      
      if (worker.employeeId != null && worker.employeeId!.isNotEmpty) {
        final employeeIdExists = await _workerRepository.isEmployeeIdInUse(
          worker.employeeId!, 
          excludeWorkerId: worker.id,
        );
        if (employeeIdExists) {
          throw Exception('Employee ID is already in use');
        }
      }

      final rowsAffected = await _workerRepository.updateWorker(worker);
      
      if (rowsAffected > 0) {
        // Reload workers to reflect the update
        await loadWorkers();
        return true;
      } else {
        throw Exception('Worker not found');
      }
    } catch (e) {
      _setError('Failed to update worker: ${e.toString()}');
      return false;
    }
  }

  /// Delete a worker (soft delete - sets as inactive)
  /// 
  /// Returns true if deletion was successful
  Future<bool> deleteWorker(int workerId) async {
    _clearError();

    try {
      final rowsAffected = await _workerRepository.deactivateWorker(workerId);
      
      if (rowsAffected > 0) {
        // Reload workers to reflect the change
        await loadWorkers();
        return true;
      } else {
        throw Exception('Worker not found');
      }
    } catch (e) {
      _setError('Failed to delete worker: ${e.toString()}');
      return false;
    }
  }

  /// Reactivate a worker
  /// 
  /// Returns true if reactivation was successful
  Future<bool> reactivateWorker(int workerId) async {
    _clearError();

    try {
      final rowsAffected = await _workerRepository.reactivateWorker(workerId);
      
      if (rowsAffected > 0) {
        // Reload workers to reflect the change
        await loadWorkers();
        return true;
      } else {
        throw Exception('Worker not found');
      }
    } catch (e) {
      _setError('Failed to reactivate worker: ${e.toString()}');
      return false;
    }
  }

  /// Toggle senior worker status for a worker
  /// 
  /// Returns true if update was successful
  Future<bool> toggleSeniorWorkerStatus(int workerId) async {
    _clearError();

    try {
      final worker = _workers.firstWhere((w) => w.id == workerId);
      final newStatus = !worker.isSeniorWorker;
      
      final rowsAffected = await _workerRepository.setSeniorWorkerStatus(workerId, newStatus);
      
      if (rowsAffected > 0) {
        // Reload workers to reflect the change
        await loadWorkers();
        return true;
      } else {
        throw Exception('Worker not found');
      }
    } catch (e) {
      _setError('Failed to update senior worker status: ${e.toString()}');
      return false;
    }
  }

  /// Set search query and apply filters
  void setSearchQuery(String query) {
    _searchQuery = query.trim();
    _applyFilters();
    notifyListeners();
  }

  /// Toggle between showing all workers vs. active workers only
  void toggleShowActiveOnly() {
    _showActiveOnly = !_showActiveOnly;
    _applyFilters();
    notifyListeners();
  }

  /// Clear current search query
  void clearSearch() {
    _searchQuery = '';
    _applyFilters();
    notifyListeners();
  }

  /// Get a worker by ID
  Worker? getWorkerById(int id) {
    try {
      return _workers.firstWhere((worker) => worker.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Clear any current error message
  void clearError() {
    _clearError();
    notifyListeners();
  }

  // Private helper methods

  /// Set loading state and notify listeners
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error message and notify listeners
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _errorMessage = null;
  }

  /// Apply current filters to the worker list
  void _applyFilters() {
    List<Worker> filtered = List.from(_workers);

    // Apply active/inactive filter
    if (_showActiveOnly) {
      filtered = filtered.where((worker) => worker.isActive).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((worker) {
        return worker.firstName.toLowerCase().contains(query) ||
               worker.lastName.toLowerCase().contains(query) ||
               worker.fullName.toLowerCase().contains(query) ||
               (worker.email?.toLowerCase().contains(query) ?? false) ||
               (worker.employeeId?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Sort by last name, then first name
    filtered.sort((a, b) {
      final lastNameComparison = a.lastName.compareTo(b.lastName);
      if (lastNameComparison != 0) return lastNameComparison;
      return a.firstName.compareTo(b.firstName);
    });

    _filteredWorkers = filtered;
  }

  /// Validate worker data before database operations
  void _validateWorker(Worker worker) {
    if (worker.firstName.trim().isEmpty) {
      throw Exception('First name is required');
    }
    
    if (worker.lastName.trim().isEmpty) {
      throw Exception('Last name is required');
    }

    // Validate email format if provided
    if (worker.email != null && worker.email!.isNotEmpty) {
      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
      if (!emailRegex.hasMatch(worker.email!)) {
        throw Exception('Invalid email format');
      }
    }

    // Validate employee ID if provided
    if (worker.employeeId != null && worker.employeeId!.isNotEmpty) {
      if (worker.employeeId!.length < 2) {
        throw Exception('Employee ID must be at least 2 characters');
      }
    }
  }
}