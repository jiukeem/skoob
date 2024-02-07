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
}