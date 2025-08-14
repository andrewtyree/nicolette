// lib/models/worker.dart
import 'package:equatable/equatable.dart';

/// Worker model represents an individual worker in the scheduling system
class Worker extends Equatable {
  final int? id;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;
  final String? employeeId;
  final bool isSeniorWorker;
  final bool isActive;
  final DateTime? hireDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Worker({
    this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phone,
    this.employeeId,
    this.isSeniorWorker = false,
    this.isActive = true,
    this.hireDate,
    this.createdAt,
    this.updatedAt,
  });

  /// Create a Worker instance from database row data
  factory Worker.fromDatabase(Map<String, dynamic> map) {
    return Worker(
      id: map['id'] as int?,
      firstName: map['first_name'] as String,
      lastName: map['last_name'] as String,
      email: map['email'] as String?,
      phone: map['phone'] as String?,
      employeeId: map['employee_id'] as String?,
      isSeniorWorker: (map['is_senior_worker'] as int?) == 1,
      isActive: (map['is_active'] as int?) == 1,
      hireDate: map['hire_date'] != null 
          ? DateTime.parse(map['hire_date'] as String)
          : null,
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null 
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  /// Convert Worker instance to database format
  Map<String, dynamic> toDatabase() {
    return {
      if (id != null) 'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'employee_id': employeeId,
      'is_senior_worker': isSeniorWorker ? 1 : 0,
      'is_active': isActive ? 1 : 0,
      'hire_date': hireDate?.toIso8601String().split('T')[0],
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  String get fullName => '$firstName $lastName';
  String get initials {
    final firstInitial = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final lastInitial = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$firstInitial$lastInitial';
  }

  Worker copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? employeeId,
    bool? isSeniorWorker,
    bool? isActive,
    DateTime? hireDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Worker(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      employeeId: employeeId ?? this.employeeId,
      isSeniorWorker: isSeniorWorker ?? this.isSeniorWorker,
      isActive: isActive ?? this.isActive,
      hireDate: hireDate ?? this.hireDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Worker withUpdatedTimestamp() {
    return copyWith(updatedAt: DateTime.now());
  }

  @override
  List<Object?> get props => [
    id, firstName, lastName, email, phone, employeeId,
    isSeniorWorker, isActive, hireDate, createdAt, updatedAt,
  ];
}