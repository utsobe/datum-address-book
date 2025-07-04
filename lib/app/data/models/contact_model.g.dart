// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ContactAdapter extends TypeAdapter<Contact> {
  @override
  final int typeId = 0;

  @override
  Contact read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Contact(
      id: fields[0] as String?,
      firstName: fields[1] as String,
      lastName: fields[2] as String,
      phone: fields[3] as String?,
      email: fields[4] as String?,
      address: fields[5] as String?,
      company: fields[6] as String?,
      notes: fields[7] as String?,
      avatarPath: fields[8] as String?,
      isFavorite: fields[9] as bool,
      createdAt: fields[10] as DateTime?,
      updatedAt: fields[11] as DateTime?,
      workPhone: fields[12] as String?,
      homePhone: fields[13] as String?,
      workEmail: fields[14] as String?,
      personalEmail: fields[15] as String?,
      website: fields[16] as String?,
      birthday: fields[17] as String?,
      tags: (fields[18] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Contact obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.firstName)
      ..writeByte(2)
      ..write(obj.lastName)
      ..writeByte(3)
      ..write(obj.phone)
      ..writeByte(4)
      ..write(obj.email)
      ..writeByte(5)
      ..write(obj.address)
      ..writeByte(6)
      ..write(obj.company)
      ..writeByte(7)
      ..write(obj.notes)
      ..writeByte(8)
      ..write(obj.avatarPath)
      ..writeByte(9)
      ..write(obj.isFavorite)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.updatedAt)
      ..writeByte(12)
      ..write(obj.workPhone)
      ..writeByte(13)
      ..write(obj.homePhone)
      ..writeByte(14)
      ..write(obj.workEmail)
      ..writeByte(15)
      ..write(obj.personalEmail)
      ..writeByte(16)
      ..write(obj.website)
      ..writeByte(17)
      ..write(obj.birthday)
      ..writeByte(18)
      ..write(obj.tags);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContactAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
