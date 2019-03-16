part of flutter_parse_sdk;

class ParseGeoPoint extends ParseObject {

  /// Creates a Parse Object of type GeoPoint
  ParseGeoPoint(
      {double latitude = 0.0,
      double longitude = 0.0,
      bool debug,
      ParseHTTPClient client,
      bool autoSendSessionId})
      : super(keyGeoPoint) {
    _latitude = latitude;
    _longitude = longitude;

    _debug = isDebugEnabled(objectLevelDebug: debug);
    _client = client ??
        ParseHTTPClient(
            sendSessionId:
                autoSendSessionId ?? ParseCoreData().autoSendSessionId,
            securityContext: ParseCoreData().securityContext);
  }

  double _latitude;
  double _longitude;

  double get latitude => _latitude;

  double get longitude => _longitude;

  set latitude(double value) {
    _latitude = value;
  }

  set longitude(double value) {
    _longitude = value;
  }

  @override
  Map<String, dynamic> toJson({bool full = false, bool forApiRQ = false}) => <String, dynamic>{
        '__type': 'GeoPoint',
        'latitude': _latitude,
        'longitude': _longitude
      };
}
