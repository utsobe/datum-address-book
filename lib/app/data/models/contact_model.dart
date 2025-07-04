import 'package:hive/hive.dart';

part 'contact_model.g.dart';

@HiveType(typeId: 0)
class Contact extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  String firstName;

  @HiveField(2)
  String lastName;

  @HiveField(3)
  String? phone;

  @HiveField(4)
  String? email;

  @HiveField(5)
  String? address;

  @HiveField(6)
  String? company;

  @HiveField(7)
  String? notes;

  @HiveField(8)
  String? avatarPath;

  @HiveField(9)
  bool isFavorite;

  @HiveField(10)
  late DateTime createdAt;

  @HiveField(11)
  late DateTime updatedAt;

  @HiveField(12)
  String? workPhone;

  @HiveField(13)
  String? homePhone;

  @HiveField(14)
  String? workEmail;

  @HiveField(15)
  String? personalEmail;

  @HiveField(16)
  String? website;

  @HiveField(17)
  String? birthday;

  @HiveField(18)
  List<String> tags;

  Contact({
    String? id,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.email,
    this.address,
    this.company,
    this.notes,
    this.avatarPath,
    this.isFavorite = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.workPhone,
    this.homePhone,
    this.workEmail,
    this.personalEmail,
    this.website,
    this.birthday,
    this.tags = const [],
  }) {
    this.id = id ?? DateTime.now().millisecondsSinceEpoch.toString();
    this.createdAt = createdAt ?? DateTime.now();
    this.updatedAt = updatedAt ?? DateTime.now();
  }

  String get fullName => '$firstName $lastName'.trim();

  String get displayName {
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '$firstName $lastName';
    } else if (firstName.isNotEmpty) {
      return firstName;
    } else if (lastName.isNotEmpty) {
      return lastName;
    } else if (company?.isNotEmpty == true) {
      return company!;
    } else if (email?.isNotEmpty == true) {
      return email!;
    } else if (phone?.isNotEmpty == true) {
      return phone!;
    }
    return 'Unnamed Contact';
  }

  String get initials {
    String first = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    String last = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    if (first.isEmpty && last.isEmpty && company?.isNotEmpty == true) {
      return company![0].toUpperCase();
    }
    return '$first$last';
  }

  String get primaryPhone => phone ?? workPhone ?? homePhone ?? '';
  String get primaryEmail => email ?? workEmail ?? personalEmail ?? '';

  Contact copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? address,
    String? company,
    String? notes,
    String? avatarPath,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? workPhone,
    String? homePhone,
    String? workEmail,
    String? personalEmail,
    String? website,
    String? birthday,
    List<String>? tags,
  }) {
    return Contact(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      company: company ?? this.company,
      notes: notes ?? this.notes,
      avatarPath: avatarPath ?? this.avatarPath,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      workPhone: workPhone ?? this.workPhone,
      homePhone: homePhone ?? this.homePhone,
      workEmail: workEmail ?? this.workEmail,
      personalEmail: personalEmail ?? this.personalEmail,
      website: website ?? this.website,
      birthday: birthday ?? this.birthday,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'email': email,
      'address': address,
      'company': company,
      'notes': notes,
      'avatarPath': avatarPath,
      'isFavorite': isFavorite,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'workPhone': workPhone,
      'homePhone': homePhone,
      'workEmail': workEmail,
      'personalEmail': personalEmail,
      'website': website,
      'birthday': birthday,
      'tags': tags,
    };
  }

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'],
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      company: json['company'],
      notes: json['notes'],
      avatarPath: json['avatarPath'],
      isFavorite: json['isFavorite'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      workPhone: json['workPhone'],
      homePhone: json['homePhone'],
      workEmail: json['workEmail'],
      personalEmail: json['personalEmail'],
      website: json['website'],
      birthday: json['birthday'],
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  @override
  String toString() {
    return 'Contact{id: $id, name: $displayName, phone: $phone, email: $email}';
  }
}
