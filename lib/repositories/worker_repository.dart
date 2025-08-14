import 'package:sqflite/sqflite.dart';
import '../core/database/database_helper.dart';
import '../models/worker.dart';

/// Repository class for managing Worker data operations
/// 
/// This class provides a clean interface for all worker-related database operations
/// including CRUD operations, search functionality, and business logic queries.
class WorkerRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  /// Get database instance
  Future<Database> get _database async => await _databaseHelper.database;

  /// Create a new worker
  /// 
  /// Returns the ID of the newly created worker
  /// Throws an exception if creation fails (e.g., duplicate email/employee_id)
  Future<int> createWorker(Worker worker) async {
    final db = await _database;
    
    try {
      // Add creation timestamp if not provided
      final workerWithTimestamp = worker.copyWith(
        createdAt: worker.createdAt ?? DateTime.now(),
        updatedAt: worker.updatedAt ?? DateTime.now(),
      );
      
      final id = await db.insert(
        'workers',
        workerWithTimestamp.toDatabase(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      
      return id;
    } catch (e) {
      throw Exception('Failed to create worker: ${e.toString()}');
    }
  }

  /// Get a worker by ID
  /// 
  /// Returns null if worker is not found
  Future<Worker?> getWorkerById(int id) async {
    final db = await _database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'workers',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return Worker.fromDatabase(maps.first);
  }

  /// Get all workers
  /// 
  /// Optional parameters:
  /// - [activeOnly]: If true, returns only active workers
  /// - [orderBy]: Column to order by (default: last_name, first_name)
  Future<List<Worker>> getAllWorkers({
    bool activeOnly = false,
    String orderBy = 'last_name, first_name',
  }) async {
    final db = await _database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'workers',
      where: activeOnly ? 'is_active = ?' : null,
      whereArgs: activeOnly ? [1] : null,
      orderBy: orderBy,
    );

    return maps.map((map) => Worker.fromDatabase(map)).toList();
  }

  /// Get all active workers
  /// 
  /// Convenience method for getting only active workers
  Future<List<Worker>> getActiveWorkers() async {
    return getAllWorkers(activeOnly: true);
  }

  /// Get all senior workers
  /// 
  /// Optional parameters:
  /// - [activeOnly]: If true, returns only active senior workers
  Future<List<Worker>> getSeniorWorkers({bool activeOnly = true}) async {
    final db = await _database;
    
    String whereClause = 'is_senior_worker = 1';
    
    if (activeOnly) {
      whereClause += ' AND is_active = 1';
    }
    
    final List<Map<String, dynamic>> maps = await db.query(
      'workers',
      where: whereClause,
      orderBy: 'last_name, first_name',
    );

    return maps.map((map) => Worker.fromDatabase(map)).toList();
  }

  /// Search workers by name
  /// 
  /// Searches both first and last names using case-insensitive partial matching
  /// Optional [activeOnly] parameter to filter by active status
  Future<List<Worker>> searchWorkersByName(
    String searchTerm, {
    bool activeOnly = false,
  }) async {
    final db = await _database;
    
    String whereClause = '(LOWER(first_name) LIKE ? OR LOWER(last_name) LIKE ?)';
    List<dynamic> whereArgs = ['%${searchTerm.toLowerCase()}%', '%${searchTerm.toLowerCase()}%'];
    
    if (activeOnly) {
      whereClause += ' AND is_active = 1';
    }
    
    final List<Map<String, dynamic>> maps = await db.query(
      'workers',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'last_name, first_name',
    );

    return maps.map((map) => Worker.fromDatabase(map)).toList();
  }

  /// Update an existing worker
  /// 
  /// Returns the number of rows affected (should be 1 for successful update)
  /// Automatically updates the updated_at timestamp
  Future<int> updateWorker(Worker worker) async {
    final db = await _database;
    
    if (worker.id == null) {
      throw Exception('Cannot update worker without ID');
    }

    try {
      // Update the timestamp
      final workerWithTimestamp = worker.withUpdatedTimestamp();
      
      final rowsAffected = await db.update(
        'workers',
        workerWithTimestamp.toDatabase(),
        where: 'id = ?',
        whereArgs: [worker.id],
      );
      
      return rowsAffected;
    } catch (e) {
      throw Exception('Failed to update worker: ${e.toString()}');
    }
  }

  /// Delete a worker by ID
  /// 
  /// Returns the number of rows affected (should be 1 for successful deletion)
  /// Note: This performs a hard delete. Consider using soft delete (setting is_active = false) instead
  Future<int> deleteWorker(int id) async {
    final db = await _database;
    
    try {
      final rowsAffected = await db.delete(
        'workers',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      return rowsAffected;
    } catch (e) {
      throw Exception('Failed to delete worker: ${e.toString()}');
    }
  }

  /// Soft delete a worker (set as inactive)
  /// 
  /// This is preferred over hard delete as it preserves historical assignment data
  /// Returns the number of rows affected
  Future<int> deactivateWorker(int id) async {
    final worker = await getWorkerById(id);
    if (worker == null) {
      throw Exception('Worker not found');
    }

    final deactivatedWorker = worker.copyWith(isActive: false);
    return await updateWorker(deactivatedWorker);
  }

  /// Reactivate a worker (set as active)
  /// 
  /// Returns the number of rows affected
  Future<int> reactivateWorker(int id) async {
    final worker = await getWorkerById(id);
    if (worker == null) {
      throw Exception('Worker not found');
    }

    final reactivatedWorker = worker.copyWith(isActive: true);
    return await updateWorker(reactivatedWorker);
  }

  /// Set senior worker status for a worker
  /// 
  /// Returns the number of rows affected
  Future<int> setSeniorWorkerStatus(int id, bool isSeniorWorker) async {
    final worker = await getWorkerById(id);
    if (worker == null) {
      throw Exception('Worker not found');
    }

    final updatedWorker = worker.copyWith(isSeniorWorker: isSeniorWorker);
    return await updateWorker(updatedWorker);
  }

  /// Check if email address is already in use
  /// 
  /// Optional [excludeWorkerId] parameter to exclude a specific worker from the check
  /// (useful when updating an existing worker)
  Future<bool> isEmailInUse(String email, {int? excludeWorkerId}) async {
    final db = await _database;
    
    String whereClause = 'email = ?';
    List<dynamic> whereArgs = [email];
    
    if (excludeWorkerId != null) {
      whereClause += ' AND id != ?';
      whereArgs.add(excludeWorkerId);
    }
    
    final List<Map<String, dynamic>> maps = await db.query(
      'workers',
      columns: ['id'],
      where: whereClause,
      whereArgs: whereArgs,
      limit: 1,
    );

    return maps.isNotEmpty;
  }

  /// Check if employee ID is already in use
  /// 
  /// Optional [excludeWorkerId] parameter to exclude a specific worker from the check
  Future<bool> isEmployeeIdInUse(String employeeId, {int? excludeWorkerId}) async {
    final db = await _database;
    
    String whereClause = 'employee_id = ?';
    List<dynamic> whereArgs = [employeeId];
    
    if (excludeWorkerId != null) {
      whereClause += ' AND id != ?';
      whereArgs.add(excludeWorkerId);
    }
    
    final List<Map<String, dynamic>> maps = await db.query(
      'workers',
      columns: ['id'],
      where: whereClause,
      whereArgs: whereArgs,
      limit: 1,
    );

    return maps.isNotEmpty;
  }

  /// Get worker statistics
  /// 
  /// Returns counts of total, active, inactive, and senior workers
  Future<Map<String, int>> getWorkerStatistics() async {
    final db = await _database;
    
    // Get total count
    final totalResult = await db.rawQuery('SELECT COUNT(*) as count FROM workers');
    final totalCount = totalResult.first['count'] as int;
    
    // Get active count
    final activeResult = await db.rawQuery('SELECT COUNT(*) as count FROM workers WHERE is_active = 1');
    final activeCount = activeResult.first['count'] as int;
    
    // Get senior worker count
    final seniorResult = await db.rawQuery('SELECT COUNT(*) as count FROM workers WHERE is_senior_worker = 1 AND is_active = 1');
    final seniorCount = seniorResult.first['count'] as int;
    
    return {
      'total': totalCount,
      'active': activeCount,
      'inactive': totalCount - activeCount,
      'senior': seniorCount,
    };
  }
}