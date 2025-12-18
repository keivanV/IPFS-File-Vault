import 'package:flutter/material.dart';

IconData getFileIcon(String type) {
  switch (type.toLowerCase()) {
    case 'pdf':
      return Icons.picture_as_pdf;
    case 'docx':
    case 'pptx':
      return Icons.description;
    case 'png':
    case 'jpg':
    case 'jpeg':
      return Icons.image;
    case 'zip':
    case 'rar':
      return Icons.archive;
    case 'mp4':
    case 'mov':
    case 'avi':
      return Icons.videocam;
    case 'xlsx':
    case 'xls':
      return Icons.table_chart;
    case 'txt':
    case 'log':
    case 'sql':
      return Icons.text_snippet;
    default:
      return Icons.insert_drive_file;
  }
}
