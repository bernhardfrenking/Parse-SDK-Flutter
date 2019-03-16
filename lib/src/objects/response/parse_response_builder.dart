part of flutter_parse_sdk;

/// Handles all the ParseObject responses
///
/// There are 4 probable outcomes from a Parse API call,
/// 1. Fail - [ParseResponse()] will be returned with further details
/// 2. Success but no results. [ParseResponse()] is returned.
/// 3. Success with simple OK.
/// 4. Success with results. Again [ParseResponse()] is returned
class _ParseResponseBuilder {
  ParseResponse handleResponse<T>(dynamic object, Response apiResponse,
      {bool returnAsResult = false}) {
    final ParseResponse parseResponse = ParseResponse();

    if (apiResponse != null) {
      parseResponse.statusCode = apiResponse.statusCode;

      if (apiResponse.statusCode != 200 && apiResponse.statusCode != 201) {
        return buildErrorResponse(parseResponse, apiResponse);
      } else if (apiResponse.body == '{\"results\":[]}') {
        return buildSuccessResponseWithNoResults(
            parseResponse, 1, 'Successful request, but no results found');
      } else if (returnAsResult) {
        return _handleSuccessWithoutParseObject(
            parseResponse, object, apiResponse.body);
      } else {
        return _handleSuccess<T>(parseResponse, object, apiResponse.body);
      }
    } else {
      parseResponse.error = ParseError(
          message: 'Error reaching server, or server response was null');
      return parseResponse;
    }
  }

  /// Handles successful response without creating a ParseObject
  ParseResponse _handleSuccessWithoutParseObject(
      ParseResponse response, dynamic object, String responseBody) {
    response.success = true;

    if (responseBody == 'OK') {
      response.result = responseBody;
      return response;
    }

    final Map<String, dynamic> decodedJson = json.decode(responseBody);

    if (decodedJson.containsKey('params')) {
      response.result = decodedJson['params'];
    } else if (decodedJson.containsKey('result')) {
      response.result = decodedJson['result'];
    } else {
      response.result = decodedJson;
    }

    return response;
  }

  /// Handles successful response with results
  ParseResponse _handleSuccess<T>(
      ParseResponse response, dynamic object, String responseBody) {
    response.success = true;

    final Map<String, dynamic> map = json.decode(responseBody);

    if (object is Parse) {
      response.result = map;
    } else if (map != null && map.length == 1 && map.containsKey('results')) {
      final List<dynamic> results = map['results'];
      response.result = _handleMultipleResults<T>(object, results);
    } else {
      response.result = _handleSingleResult<T>(object, map);
    }

    return response;
  }

  /// Handles a response with a multiple result object
  List<T> _handleMultipleResults<T>(dynamic object, List<dynamic> data) {
    final List<T> resultsList = List<T>();

    for (dynamic value in data) {
      resultsList.add(_handleSingleResult<T>(object, value));
    }

    return resultsList;
  }

  /// Handles a response with a single result object
  T _handleSingleResult<T>(T object, Map<String, dynamic> map) {
    if (object is ParseCloneable) {
      return object.clone(map);
    } else {
      return null;
    }
  }
}

/// Handles an API response and logs data if [bool] debug is enabled
@protected
ParseResponse handleResponse<T>(ParseCloneable object, Response response,
    ParseApiRQ type, bool debug, String className) {
  final ParseResponse parseResponse = _ParseResponseBuilder().handleResponse<T>(
      object, response,
      returnAsResult: shouldReturnAsABaseResult(type));

  if (debug) {
    logger(ParseCoreData().appName, className, type.toString(), parseResponse);
  }

  return parseResponse;
}

/// Handles an API response and logs data if [bool] debug is enabled
@protected
ParseResponse handleException(
    Exception exception, ParseApiRQ type, bool debug, String className) {
  final ParseResponse parseResponse =
      buildParseResponseWithException(exception);

  if (debug) {
    logger(ParseCoreData().appName, className, type.toString(), parseResponse);
  }

  return parseResponse;
}

bool shouldReturnAsABaseResult(ParseApiRQ type) {
  if (type == ParseApiRQ.healthCheck ||
      type == ParseApiRQ.execute ||
      type == ParseApiRQ.add ||
      type == ParseApiRQ.addAll ||
      type == ParseApiRQ.addUnique ||
      type == ParseApiRQ.remove ||
      type == ParseApiRQ.removeAll ||
      type == ParseApiRQ.increment ||
      type == ParseApiRQ.decrement ||
      type == ParseApiRQ.getConfigs ||
      type == ParseApiRQ.addConfig) {
    return true;
  } else {
    return false;
  }
}
