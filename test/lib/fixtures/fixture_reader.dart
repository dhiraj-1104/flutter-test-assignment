import 'dart:io';

String fixture(String name) =>
    File('test/lib/fixtures/$name').readAsStringSync();
