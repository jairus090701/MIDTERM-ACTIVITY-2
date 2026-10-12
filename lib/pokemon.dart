class PokemonSummary {
  final String name;
  final String url;

  const PokemonSummary({
    required this.name,
    required this.url,
  });

  factory PokemonSummary.fromJson(Map<String, dynamic> json) {
    return PokemonSummary(
      name: json['name'] as String? ?? 'Unknown Pokémon',
      url: json['url'] as String? ?? '',
    );
  }

  int? get id {
    final match = RegExp(r'/pokemon/(\d+)/?$').firstMatch(url);
    return match == null ? null : int.tryParse(match.group(1)!);
  }

  String get formattedName {
    if (name.isEmpty) return name;
    return name
        .split('-')
        .map((part) => part.isEmpty
            ? part
            : '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}

class PokemonDetails {
  final int id;
  final String name;
  final int height;
  final int weight;
  final List<String> types;
  final String? imageUrl;

  const PokemonDetails({
    required this.id,
    required this.name,
    required this.height,
    required this.weight,
    required this.types,
    required this.imageUrl,
  });

  factory PokemonDetails.fromJson(Map<String, dynamic> json) {
    final typeList = (json['types'] as List<dynamic>? ?? [])
        .map((item) {
          final type = item as Map<String, dynamic>;
          final typeInfo = type['type'] as Map<String, dynamic>? ?? {};
          return typeInfo['name'] as String? ?? 'unknown';
        })
        .toList();

    final sprites = json['sprites'] as Map<String, dynamic>? ?? {};
    final officialArtwork =
        sprites['other'] as Map<String, dynamic>? ?? {};
    final artwork =
        officialArtwork['official-artwork'] as Map<String, dynamic>? ?? {};

    return PokemonDetails(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Unknown Pokémon',
      height: json['height'] as int? ?? 0,
      weight: json['weight'] as int? ?? 0,
      types: typeList,
      imageUrl: artwork['front_default'] as String?,
    );
  }

  String get formattedName {
    if (name.isEmpty) return name;
    return name
        .split('-')
        .map((part) => part.isEmpty
            ? part
            : '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}
