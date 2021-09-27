// ignore: slash_for_doc_comments
/**
 * This file is part of fluxer.
 *
 * (c) Irwin Lourtet <dev@ilourt.com>
 *
 * For the full copyright and license information, please view the LICENSE file
 * distributed with this source code
 * or visit https://github.com/ilourt/fluxer
 */

part of '../core.dart';

/// Manage the flux of actions
class ActionController {
  /// The actions waiting to be called
  final Queue<Channel> _queue = Queue<Channel>();

  /// The fact that an action is currently in progress
  bool _actionInProgress = false;

  /// Whether it waits for a `_dispatch` to be called
  bool _waitDispatch = false;

  /// Dispatch the current action and process the next one
  _dispatch() {
    _waitDispatch = false;
    _callNextAction();
  }

  /// Add action to the `_queue`.
  _addToQueue(Channel ch) {
    _queue.add(ch);

    if (_actionInProgress == false) {
      _actionInProgress = true;
      _callNextAction();
    }
  }

  /// Call next action in the queue it the `_queue``is not empty
  _callNextAction() {
    // Mark that no action is in progress if the queue is empty
    if (_queue.isEmpty) {
      _actionInProgress = false;
      return;
    }

    // Get the first element in the queue and send it to make next action
    // processed
    var ch = _queue.removeFirst();
    ch.send(null);
  }
}

/// Signature of the dispatch callback
typedef DispatchCb = Function(Function dispatch, Function notify);
