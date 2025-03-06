class TypeRelation {
  final String name;
  final List<String> doubleDamageTo;
  final List<String> halfDamageTo;
  final List<String> noDamageTo;

  TypeRelation({
    required this.name,
    required this.doubleDamageTo,
    required this.halfDamageTo,
    required this.noDamageTo,
  });

  factory TypeRelation.fromJson(Map<String, dynamic> json) {
    return TypeRelation(
      name: json['name'],
      doubleDamageTo: (json['damage_relations']['double_damage_to'] as List)
          .map((e) => e['name'] as String)
          .toList(),
      halfDamageTo: (json['damage_relations']['half_damage_to'] as List)
          .map((e) => e['name'] as String)
          .toList(),
      noDamageTo: (json['damage_relations']['no_damage_to'] as List)
          .map((e) => e['name'] as String)
          .toList(),
    );
  }
}