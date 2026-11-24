class Contact {
  int? id;
  String nom;
  String tel;

  Contact({
    this.id,
    required this.nom,
    required this.tel,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nom': nom,
      'tel': tel,
    };
  }

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'],
      nom: map['nom'] ?? '',
      tel: map['tel']?.toString() ?? '',
    );
  }
}
