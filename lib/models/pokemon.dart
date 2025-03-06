import '../extensions/string_extensions.dart';

class Pokemon {
  final String name;
  final String url;
  String? imageUrl;
  List<String>? types;
  int? id;

  Pokemon({
    required this.name,
    required this.url,
    this.imageUrl,
    this.types,
    this.id,
  });

  // Para a lista inicial
  factory Pokemon.fromListJson(Map<String, dynamic> json) {
    return Pokemon(
      name: (json['name'] as String).capitalize(),
      url: json['url'] as String,
      id: _extractIdFromUrl(json['url']),
    );
  }

  // Para os detalhes
  factory Pokemon.fromDetailJson(Map<String, dynamic> json) {
    return Pokemon(
      name: (json['name'] as String).capitalize(),
      url: '',
      id: json['id'] as int,
      imageUrl: (json['sprites']?['other']?['official-artwork']?['front_default'] ?? 
                json['sprites']?['front_default']) as String?,
      types: (json['types'] as List?)?.map((t) => (t['type']['name'] as String).capitalize()).toList(),
    );
  }

  // Método de extração de ID
  static int _extractIdFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
      return int.parse(segments.lastWhere((s) => s.isNotEmpty));
    } catch (e) {
      print('‼️ Erro ao extrair ID da URL: $url | $e');
      return 0;
    }
  }

  // Serialização para SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'types': types,
      'url': url,
    };
  }

  // Desserialização do JSON salvo
  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      id: json['id'] as int,
      name: json['name'] as String,
      url: json['url'] as String,
      imageUrl: json['imageUrl'] as String?,
      types: (json['types'] as List?)?.cast<String>(),
    );
  }
}