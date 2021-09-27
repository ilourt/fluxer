import 'core.dart';

late Fluxer fluxer;

void initFluxer() {
  fluxer = Fluxer();
}

class Fluxer {
  final Map<dynamic, Store> _refs = {};

  stateOfRef(dynamic ref) {
    if (!_refs.containsKey(ref)) throw "There is no store with ref : $ref";
    return _refs[ref]!.state;
  }

  S of<S extends Store>(dynamic ref) {
    if (!_refs.containsKey(ref)) throw "There is no store with ref : $ref";
    var store = _refs[ref]!;
    assert(store is S, "Store associated to ref is of type ${store.runtimeType} no $S");
    return _refs[ref]! as S;
  }

  addRef(Store store, dynamic ref) {
    assert(
        !_refs.containsKey(ref), "A store whith the ref '$ref' already exists");
    _refs[ref] = store;
  }

  removeRef(dynamic ref) {
    assert(
        !_refs.containsKey(ref), "A store whith the ref '$ref' already exists");
    _refs[ref]?.dispose();
  }

  removeStore(Store s) {
    _refs.removeWhere((key, value) => value == s);
  }
}