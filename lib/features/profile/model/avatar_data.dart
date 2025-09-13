class Avatar {
  final String id;
  final String path;
  final String category;
  final String label;

  Avatar({
    required this.id,
    required this.path,
    required this.category,
    required this.label,
  });
}

class AvatarData {
  static List<Avatar> avatars = [
    Avatar(
      id: 'person1',
      path: 'assets/avatars/person1.png',
      category: 'Personnages',
      label: 'Personnage 1',
    ),
    Avatar(
      id: 'person2',
      path: 'assets/avatars/person2.png',
      category: 'Personnages',
      label: 'Personnage 2',
    ),
    Avatar(
      id: 'person3',
      path: 'assets/avatars/person3.png',
      category: 'Personnages',
      label: 'Personnage 3',
    ),
    Avatar(
      id: 'person4',
      path: 'assets/avatars/person4.png',
      category: 'Personnages',
      label: 'Personnage 4',
    ),
    Avatar(
      id: 'person5',
      path: 'assets/avatars/person5.png',
      category: 'Personnages',
      label: 'Personnage 5',
    ),
    Avatar(
      id: 'person6',
      path: 'assets/avatars/person6.png',
      category: 'Personnages',
      label: 'Personnage 6',
    ),
    Avatar(
      id: 'person7',
      path: 'assets/avatars/person7.png',
      category: 'Personnages',
      label: 'Personnage 7',
    ),
    Avatar(
      id: 'person8',
      path: 'assets/avatars/person8.png',
      category: 'Personnages',
      label: 'Personnage 8',
    ),
    Avatar(
      id: 'person9',
      path: 'assets/avatars/person9.png',
      category: 'Personnages',
      label: 'Personnage 9',
    ),
    Avatar(
      id: 'person10',
      path: 'assets/avatars/person10.png',
      category: 'Personnages',
      label: 'Personnage 10',
    ),
    Avatar(
      id: 'person11',
      path: 'assets/avatars/person11.png',
      category: 'Personnages',
      label: 'Personnage 11',
    ),
    Avatar(
      id: 'person12',
      path: 'assets/avatars/person12.png',
      category: 'Personnages',
      label: 'Personnage 12',
    ),
    Avatar(
      id: 'person13',
      path: 'assets/avatars/person13.png',
      category: 'Personnages',
      label: 'Personnage 13',
    ),
    Avatar(
      id: 'person14',
      path: 'assets/avatars/person14.png',
      category: 'Personnages',
      label: 'Personnage 14',
    ),
    Avatar(
      id: 'person15',
      path: 'assets/avatars/person15.png',
      category: 'Personnages',
      label: 'Personnage 15',
    ),
    Avatar(
      id: 'person16',
      path: 'assets/avatars/person16.png',
      category: 'Personnages',
      label: 'Personnage 16',
    ),
    Avatar(
      id: 'person17',
      path: 'assets/avatars/person17.png',
      category: 'Personnages',
      label: 'Personnage 17',
    ),
    Avatar(
      id: 'person18',
      path: 'assets/avatars/person18.png',
      category: 'Personnages',
      label: 'Personnage 18',
    ),
    Avatar(
      id: 'person19',
      path: 'assets/avatars/person19.png',
      category: 'Personnages',
      label: 'Personnage 19',
    ),
    Avatar(
      id: 'person20',
      path: 'assets/avatars/person20.png',
      category: 'Personnages',
      label: 'Personnage 20',
    ),
  ];

  static List<Avatar> getByCategory(String category) {
    return avatars; // Toujours retourner tous les avatars, car une seule catégorie existe
  }

  static List<String> getCategories() {
    return ['Personnages'];
  }

  static Avatar? getById(String id) {
    try {
      return avatars.firstWhere((avatar) => avatar.id == id);
    } catch (e) {
      return null;
    }
  }
}
