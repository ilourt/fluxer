import 'package:fluxer/fluxer.dart';

const authRef = Symbol('auth');

class AuthStore extends Store<AuthState> {
  AuthStore() : super(AuthState());

  loading([bool isLoading = true]) {
    return addAction((emit) {
      emit(
        state: AuthState(
          isLogged: state.isLogged,
          isLoading: isLoading,
        ),
      );
    });
  }

  /// Log the user into the api
  Future<bool> login(String email, String password) async {
    loading();
    try {
      // Make login request
      //await request to log user

      // Manage token
      return addAction((emit) async {
        emit(state: AuthState(isLogged: true));

        return true;
      });
    } catch (error) {
      loading(false);
      return false;
    }
  }

  Future logout() async {
    return addAction((emit) {
      emit(state: AuthState(isLogged: false));
    });
  }
}

class AuthState {
  AuthState({this.isLogged = false, this.isLoading = false});

  final bool isLogged;
  final bool isLoading;
}
