import 'package:cine_club/core/error/failures.dart';
import 'package:cine_club/core/network/error_mapper.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const mapper = ErrorMapper();
  final options = RequestOptions(path: '/movies');

  DioException badResponse(int status, Object? body) => DioException(
        requestOptions: options,
        type: DioExceptionType.badResponse,
        response: Response<dynamic>(
          requestOptions: options,
          statusCode: status,
          data: body,
        ),
      );

  test('timeout -> NetworkFailure', () {
    final failure = mapper.fromDio(
      DioException(
        requestOptions: options,
        type: DioExceptionType.connectionTimeout,
      ),
    );
    expect(failure, isA<NetworkFailure>());
    expect(failure.message, isNotEmpty);
  });

  test('connectionError -> NetworkFailure', () {
    final failure = mapper.fromDio(
      DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
      ),
    );
    expect(failure, isA<NetworkFailure>());
  });

  test('401 -> AuthFailure avec le message GoTrue (clé "msg")', () {
    final failure =
        mapper.fromDio(badResponse(401, {'msg': 'Invalid login credentials'}));
    expect(failure, isA<AuthFailure>());
    expect(failure.message, 'Invalid login credentials');
  });

  test('400 PostgREST -> ServerFailure avec le message (clé "message")', () {
    final failure = mapper.fromDio(
      badResponse(400, {'message': 'column does not exist', 'code': '42703'}),
    );
    expect(failure, isA<ServerFailure>());
    expect((failure as ServerFailure).statusCode, 400);
    expect(failure.message, 'column does not exist');
  });

  test('500 -> message générique, jamais le détail technique', () {
    final failure = mapper.fromDio(
      badResponse(500, {'message': 'stack trace interne'}),
    );
    expect(failure, isA<ServerFailure>());
    expect(failure.message, isNot(contains('stack trace')));
  });

  test('429 -> ServerFailure explicite sur le débit', () {
    final failure = mapper.fromDio(badResponse(429, null));
    expect((failure as ServerFailure).statusCode, 429);
  });

  group('extractServerMessage', () {
    test('lit les clés dans l\'ordre msg > message > error_description', () {
      expect(
        ErrorMapper.extractServerMessage({
          'error_description': 'B',
          'msg': 'A',
        }),
        'A',
      );
    });

    test('renvoie null pour un corps sans message exploitable', () {
      expect(ErrorMapper.extractServerMessage({'code': 42}), isNull);
      expect(ErrorMapper.extractServerMessage(null), isNull);
      expect(ErrorMapper.extractServerMessage([1, 2, 3]), isNull);
    });
  });
}
