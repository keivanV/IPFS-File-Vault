import 'package:hive/hive.dart';

part 'file_model.g.dart';

@HiveType(typeId: 1)
class UploadedFile extends HiveObject {
  @HiveField(0)
  String fileName;

  @HiveField(1)
  String hash;

  @HiveField(2)
  String uploadUrl;

  @HiveField(3)
  DateTime uploadDate;

  @HiveField(4)
  int accessCount;

  @HiveField(5)
  DateTime? expiryDate; //
  @HiveField(6)
  String? sharePassword; //
  @HiveField(7)
  String fileType;

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
