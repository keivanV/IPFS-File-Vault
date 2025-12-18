import 'package:hive/hive.dart';

part 'file_model.g.dart';

@HiveType(typeId: 1)
class UploadedFile extends HiveObject {
  @HiveField(0)
  final String fileName;

  @HiveField(1)
  final String hash;

  @HiveField(2)
  final String uploadUrl;

  @HiveField(3)
  final DateTime uploadDate;

  @HiveField(4)
  int accessCount;

  @HiveField(5)
  final DateTime? expiryDate;

  @HiveField(6)
  final String? sharePassword;

  @HiveField(7)
  final String fileType;

  UploadedFile({
    required this.fileName,
    required this.hash,
    required this.uploadUrl,
    required this.uploadDate,
    this.accessCount = 0,
    this.expiryDate,
    this.sharePassword,
    required this.fileType,
  });
}
