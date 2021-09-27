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

/// Manage the state and the actions
abstract class Store<State> {
    Store(this._state);

  //----------------------------------------------------------------------------
  // State
  //----------------------------------------------------------------------------

  State? _prevState;
  // ignore: prefer_final_fields
  State _state;

  /// Previous state.
  /// It is null when the store is just created and the state has not been modified
  State? get prevState => _prevState;
  // Current state
  State get state => _state;

  //----------------------------------------------------------------------------
  // Lifecycle
  //----------------------------------------------------------------------------

  // @mustCallSuper
  void dispose() {
    fluxer.removeStore(this);
  }

  //----------------------------------------------------------------------------
  // Listeners
  //----------------------------------------------------------------------------

  final Set<Listener<State>> _listeners = {};

  /// Add listener which will be notified when state changed
  void listen(Listener<State> fn) {
    _listeners.add(fn);
  }

  /// Remove listener
  void unlisten(Listener<State> fn) {
    _listeners.remove(fn);
  }

  /// Notify listeners that an update has occured
  void _notify() {
    for (var listener in _listeners) {
      listener(prevState, state);
    }
  }

  //----------------------------------------------------------------------------
  // Actions
  //----------------------------------------------------------------------------

  /// The controller of the actions which must be called sequentially
  final ActionController _actionController = ActionController();

  /// Add an action to the queue and execute it when it is its turn.
  Future<T> addAction<T>(DispatchCb cb) async {
    // Add an action to the queue and wait its turn to be executed.
    Channel actionStart = Channel();
    _actionController._addToQueue(actionStart);
    await actionStart.receive();
    _actionController._waitDispatch = true;

    // Create the dispatch function
    bool hasBeenDispatched = false;
    dispatch() {
      if (!hasBeenDispatched) {
        hasBeenDispatched = true;
        _actionController._dispatch();
        return;
      }
      throw "$runtimeType action can not dispatch more than once per action";
    }

    notify(State state) {
      if (hasBeenDispatched) throw "$runtimeType can not notify after dispatch";
      _prevState = _state;
      _state = state;
      _notify();
    }

    try {
      // Execute the callback and return its result
      return cb(dispatch, notify);
    } catch (error) {
      // Call the dispatch method if it has not been called
      if (_actionController._waitDispatch) _actionController._dispatch();
      rethrow;
    }
  }
}

typedef Listener<State> = Function(State? prevState, State state);
