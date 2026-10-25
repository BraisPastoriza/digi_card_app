import 'dart:convert';
import 'dart:typed_data';

import 'package:digi_card_app/core/app_info.dart';
import 'package:digi_card_app/core/providers.dart';
import 'package:digi_card_app/data/api/github_api.dart';
import 'package:digi_card_app/features/update/app_update_providers.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Answers the latest-release request with [tag], or fails when it is null.
class _GitHub implements HttpClientAdapter {
  String? tag = 'v1.4.0';
  int requests = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests++;
    final tag = this.tag;
    if (tag == null) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'offline',
      );
    }
    return ResponseBody.fromString(
      jsonEncode({
        'tag_name': tag,
        'name': '$tag — Something new',
        'body': 'Notes',
        'html_url': 'https://github.com/x/y/releases/tag/$tag',
        'assets': <Object>[],
      }),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late _GitHub github;

  setUp(() async {
    PackageInfo.setMockInitialValues(
      appName: 'DigiCard App',
      packageName: 'io.github.braispastoriza.digicard',
      version: '1.3.0',
      buildNumber: '3',
      buildSignature: '',
    );
    await AppInfo.load();
    SharedPreferences.setMockInitialValues({});
    github = _GitHub();
  });

  ProviderContainer container() {
    final container = ProviderContainer(
      overrides: [
        gitHubApiProvider.overrideWithValue(
          GitHubApi(dio: Dio()..httpClientAdapter = github),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('offers a release newer than the installed version', () async {
    final app = container();

    await app.read(appUpdateProvider.notifier).check();

    expect(app.read(appUpdateProvider).offered?.tag, 'v1.4.0');
  });

  test('offers nothing when the installed version is the latest', () async {
    github.tag = 'v1.3.0';
    final app = container();

    await app.read(appUpdateProvider.notifier).check();

    expect(app.read(appUpdateProvider).offered, isNull);
  });

  test('stops offering a release the user turned down', () async {
    final app = container();
    final update = app.read(appUpdateProvider.notifier);
    await update.check();

    await update.dismiss();

    expect(app.read(appUpdateProvider).offered, isNull);
  });

  test('offers the next release after one turned down', () async {
    final app = container();
    final update = app.read(appUpdateProvider.notifier);
    await update.check();
    await update.dismiss();

    github.tag = 'v1.5.0';
    await update.check();

    expect(app.read(appUpdateProvider).offered?.tag, 'v1.5.0');
  });

  test('remembers the offer across launches without asking again', () async {
    await container().read(appUpdateProvider.notifier).check();
    expect(github.requests, 1);

    final relaunched = container();
    await relaunched.read(appUpdateProvider.notifier).checkIfStale();

    expect(relaunched.read(appUpdateProvider).offered?.tag, 'v1.4.0');
    expect(github.requests, 1, reason: 'checked less than a day ago');
  });

  test('drops a remembered offer once that version is installed', () async {
    await container().read(appUpdateProvider.notifier).check();

    PackageInfo.setMockInitialValues(
      appName: 'DigiCard App',
      packageName: 'io.github.braispastoriza.digicard',
      version: '1.4.0',
      buildNumber: '4',
      buildSignature: '',
    );
    await AppInfo.load();
    final relaunched = container();
    await relaunched.read(appUpdateProvider.notifier).checkIfStale();

    expect(relaunched.read(appUpdateProvider).offered, isNull);
  });

  test('keeps what it knew when GitHub cannot be reached', () async {
    final app = container();
    final update = app.read(appUpdateProvider.notifier);
    await update.check();

    github.tag = null;
    await update.check();

    expect(app.read(appUpdateProvider).offered?.tag, 'v1.4.0');
  });
}
