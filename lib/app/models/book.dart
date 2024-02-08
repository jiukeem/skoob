class Book {
  final String title;
  final String author;
  final String publisher;
  final String pubDate;
  final String description;
  final String coverImageUrl;
  final String infoUrl;
  final String category;
  final String isbn13;
  final String isbn10;
  String translator;

  Book({
    required this.title,
    required this.author,
    required this.publisher,
    required this.pubDate,
    required this.description,
    required this.coverImageUrl,
    required this.infoUrl,
    required this.category,
    required this.isbn13,
    required this.isbn10,
    this.translator = '',
  });

  Map<String, String?> toJson() {
    return {
      'title': title,
      'author': author,
      'publisher': publisher,
      'pubDate': pubDate,
      'description': description,
      'coverImageUrl': coverImageUrl,
      'infoUrl': infoUrl,
      'category': category,
      'isbn13': isbn13,
      'isbn10': isbn10,
      'translator': translator,
    };
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      publisher: json['publisher'] ?? '',
      pubDate: json['pubDate'] ?? '',
      description: json['description'] ?? '',
      coverImageUrl: json['coverImageUrl'] ?? '',
      infoUrl: json['infoUrl'] ?? '',
      category: json['category'] ?? '',
      isbn13: json['isbn13'] ?? '',
      isbn10: json['isbn10'] ?? '',
      translator: json['translator'] ?? '',
    );
  }
}