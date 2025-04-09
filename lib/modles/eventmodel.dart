// eventmodel.dart
class Event {
  String name;
  String venue;
  DateTime dateTime;
  String? imageUrl;

  Event({
    required this.name,
    required this.venue,
    required this.dateTime,
    this.imageUrl,
  });
}
