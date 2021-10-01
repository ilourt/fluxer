// This file is part of fluxer.
//
// (c) Irwin Lourtet <dev@ilourt.com>
//
// For the full copyright and license information, please view the LICENSE file
// distributed with this source code
// or visit https://github.com/ilourt/fluxer

import 'core.dart';

late Fluxer fluxer;

void initFluxer() {
  fluxer = Fluxer();
}

class Fluxer {
  final Map<dynamic, Store> _refs = {};

  stateOfRef(dynamic ref) {
    if (!_refs.containsKey(ref)) {
      throw Exception("There is no store with ref : $ref");
    }
    return _refs[ref]!.state;
  }

  S of<S extends Store>(dynamic ref) {
    if (!_refs.containsKey(ref)) {
      throw Exception("There is no store with ref : $ref");
    }
    var store = _refs[ref]!;
    assert(store is S,
        "Store associated to ref is of type ${store.runtimeType} no $S");
    return store as S;
  }

  addRef(Store store, dynamic ref) {
    assert(
        !_refs.containsKey(ref), "A store whith the ref '$ref' already exists");
    _refs[ref] = store;
  }

  removeRef(dynamic ref) {
    _refs[ref]?.dispose();
  }

  removeStore(Store s) {
    _refs.removeWhere((key, value) => value == s);
  }
}
