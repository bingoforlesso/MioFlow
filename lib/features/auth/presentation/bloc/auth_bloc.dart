import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/services/auth_service.dart';
import '../providers/auth_provider.dart';
import 'auth_event.dart';
import 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  final AuthProvider _authProvider;

  AuthBloc(@preResolve this._authService, @preResolve this._authProvider)
      : super(AuthInitialState()) {
    on<AuthEvent>((event, emit) async {
      if (event is LoginEvent) {
        await _onLogin(event, emit);
      } else if (event is RegisterEvent) {
        await _onRegister(event, emit);
      } else if (event is LogoutEvent) {
        await _onLogout(emit);
      }
    });
  }

  Future<void> _onLogin(
    LoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoadingState());

      // 验证手机号格式
      if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(event.phone)) {
        emit(AuthErrorState(message: '请输入正确的手机号'));
        return;
      }

      // 验证密码长度
      if (event.password.length < 6) {
        emit(AuthErrorState(message: '密码长度不能少于6位'));
        return;
      }

      // 调用登录接口
      final response = await _authService.login(event.phone, event.password);
      final userData = response['user'] as Map<String, dynamic>;
      final token = response['token'] as String;

      // 更新 AuthProvider 状态
      _authProvider.setAuthenticated(true);
      _authProvider.setToken(token);
      _authProvider.setUsername(userData['username'] as String);
      _authProvider.setCompanyName(userData['company_name'] as String?);

      emit(AuthenticatedState(
        companyName: userData['company_name'] as String? ?? '未设置单位名称',
        phone: event.phone,
      ));
    } catch (e) {
      emit(AuthErrorState(message: e.toString()));
    }
  }

  Future<void> _onRegister(
    RegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoadingState());

      // 验证手机号格式
      if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(event.username)) {
        emit(AuthErrorState(message: '请输入正确的手机号'));
        return;
      }

      // 验证密码长度
      if (event.password.length < 6) {
        emit(AuthErrorState(message: '密码长度不能少于6位'));
        return;
      }

      // 检查手机号是否已注册
      final isRegistered = await _authService.isPhoneRegistered(event.username);
      if (isRegistered) {
        emit(AuthErrorState(message: '该手机号已注册'));
        return;
      }

      // TODO: 实现注册逻辑
      emit(AuthenticatedState(
        companyName: '新注册用户',
        phone: event.username,
      ));
    } catch (e) {
      emit(AuthErrorState(message: e.toString()));
    }
  }

  Future<void> _onLogout(Emitter<AuthState> emit) async {
    try {
      emit(AuthLoadingState());
      await _authService.logout();
      _authProvider.clear();
      emit(UnauthenticatedState());
    } catch (e) {
      emit(AuthErrorState(message: e.toString()));
    }
  }
}
