class CustomInfo {
  final String addedDate;
  BookReadingStatus status;
  String startReadingDate;
  String finishReadingDate;
  String rate;
  String comment;
  List<Map<String, String>> note;
  List<Map<String, String>> highlight;

  CustomInfo({
    required this.addedDate,
    this.status = BookReadingStatus.initial,
    this.startReadingDate = '',
    this.finishReadingDate = '',
    this.rate = '',
    this.comment = '',
    List<Map<String, String>>? note,
    List<Map<String, String>>? highlight
  }) : note = note ?? [],
      highlight = highlight ?? [];

  Map<String, dynamic> toJson() {
    return {
      'addedDate': addedDate,
      'status': status.toString().split('.').last,
      'startReadingDate': startReadingDate,
      'finishReadingDate': finishReadingDate,
      'rate': rate,
      'comment': comment,
      'note': note.map((item) => item).toList(),
      'highlight': highlight.map((item) => item).toList()
    };
  }

  factory CustomInfo.fromJson(Map<String, dynamic> json) {
    return CustomInfo(
      addedDate: json['addedDate'] ?? '',
      status: stringToBookReadingStatus(json['status'] as String? ?? ''),
      startReadingDate: json['startReadingDate'] ?? '',
      finishReadingDate: json['finishReadingDate'] ?? '',
      rate: json['rate'] ?? '',
      comment: json['comment'] ?? '',
      note: (json['note'] as List<dynamic>?)
              ?.map((item) => Map<String, String>.from(item))
              .toList() ?? [],
      highlight: (json['highlight'] as List<dynamic>?)
              ?.map((item) => Map<String, String>.from(item))
              .toList() ?? [],
    );
  }

  static BookReadingStatus stringToBookReadingStatus(dynamic) {
    final String value = dynamic.toString();
    switch (value) {
      case 'initial':
        return BookReadingStatus.initial;
      case 'notStarted':
        return BookReadingStatus.notStarted;
      case 'reading':
        return BookReadingStatus.reading;
      case 'done':
        return BookReadingStatus.done;
      default:
        return BookReadingStatus.initial;
    }
  }
}

enum BookReadingStatus { initial, notStarted, reading, done }