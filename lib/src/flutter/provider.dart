// This file is part of fluxer.
//
// (c) Irwin Lourtet <dev@ilourt.com>
//
// For the full copyright and license information, please view the LICENSE file
// distributed with this source code
// or visit https://github.com/ilourt/fluxer

part of '../flutter.dart';

class Provider extends StatefulWidget {
  const Provider({
    Key? key,
    required this.create,
    required this.child,
    required this.ref,
    this.autodispose = true,
  }) : super(key: key);
  final dynamic ref;
  final core.Store Function() create;
  final Widget child;
  final bool autodispose;

  @override
  _ProviderState createState() => _ProviderState();
}

class _ProviderState extends State<Provider> {
  @override
  void initState() {
    fluxer.addRef(widget.ref, widget.create());
    super.initState();
  }

  @override
  void didUpdateWidget(covariant Provider oldWidget) {
    if (oldWidget.ref != widget.ref) {
      if (oldWidget.autodispose) fluxer.removeRef(oldWidget.ref);

      fluxer.addRef(widget.ref, widget.create());
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    if (widget.autodispose) fluxer.removeRef(widget.ref);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
