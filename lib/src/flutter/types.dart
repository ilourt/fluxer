// This file is part of fluxer.
//
// (c) Irwin Lourtet <dev@ilourt.com>
//
// For the full copyright and license information, please view the LICENSE file
// distributed with this source code
// or visit https://github.com/ilourt/fluxer

part of '../flutter.dart';

typedef BuildWhen<State> = bool Function(State prevState, State state);

typedef BuildWithState<State> = Widget Function(
    BuildContext context, State state);

typedef Build = Widget Function(BuildContext context);
