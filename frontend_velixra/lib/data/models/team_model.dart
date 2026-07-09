class ManagerListItem {
  final int id;
  final String name;
  final String email;

  ManagerListItem({required this.id, required this.name, required this.email});

  factory ManagerListItem.fromJson(Map<String, dynamic> json) {
    return ManagerListItem(id: json["id"], name: json["name"], email: json["email"]);
  }
}