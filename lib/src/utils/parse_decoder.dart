part of flutter_parse_sdk;

List<dynamic> _convertJSONArrayToList(List<dynamic> array) {
  final List<dynamic> list = <dynamic>[];
  for (final dynamic item in array){
    list.add(parseDecode(item));
  }
  return list;
}

Map<String, dynamic> _convertJSONObjectToMap(Map<String, dynamic> object) {
  final Map<String, dynamic> map = Map<String, dynamic>();
  object.forEach((String key, dynamic value) {
    map.putIfAbsent(key, () => parseDecode(value));
  });
  return map;
}

/// Decode any type value
dynamic parseDecode(dynamic value) {
  if (value is List) {
    return _convertJSONArrayToList(value);
  }

  if (value is bool) {
    return value;
  }

  if (value is int) {
    return value.toInt();
  }

  if (value is double) {
    return value.toDouble();
  }

  if (value is num) {
    return value;
  }

  if (!(value is Map)) {
    return value;
  }

  final Map<String, dynamic> map = value;

  if (!map.containsKey('__type')) {
    return _convertJSONObjectToMap(map);
  }

  switch (map['__type']) {
    case 'Date':
      final String iso = map['iso'];
      return DateTime.parse(iso);
    case 'Bytes':
      final String val = map['base64'];
      return base64.decode(val);
    case 'Pointer':
      final String className = map['className'];
      return ParseObject(className).fromJson(map);
    case 'Object':
      final String className = map['className'];
      if (className == '_User') {
        return ParseUser(null, null, null).fromJson(map);
      }
      return ParseObject(className).fromJson(map);
    case 'File':
      return ParseFile(null, url: map['url'], name: map['name']).fromJson(map);
    case 'GeoPoint':
      final num latitude = map['latitude'] ?? 0.0;
      final num longitude = map['longitude'] ?? 0.0;
      return ParseGeoPoint(
          latitude: latitude.toDouble(), longitude: longitude.toDouble());
  }

  return null;
}
