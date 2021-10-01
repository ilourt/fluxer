// This file is part of fluxer.
//
// (c) Irwin Lourtet <dev@ilourt.com>
//
// For the full copyright and license information, please view the LICENSE file
// distributed with this source code
// or visit https://github.com/ilourt/fluxer

part of '../core.dart';

class Channel<T> {
  Channel();

  final Completer<T> _completer = Completer<T>();

  send([T? t]) {
    _completer.complete(t);
  }

  Future<T> receive() async {
    return await _completer.future;
  }
}
