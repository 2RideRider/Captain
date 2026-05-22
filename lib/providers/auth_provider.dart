import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:captain_app_flutter/models/user_model.dart';
import 'package:captain_app_flutter/services/graphql_service.dart';
import 'package:captain_app_flutter/services/storage_service.dart';

class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final UserModel? user;
  final String? token;

  AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.user,
    this.token,
  });

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    UserModel? user,
    String? token,
    bool clearError = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      user: user ?? this.user,
      token: token ?? this.token,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  final GraphQLService _graphQLService = GraphQLService();
  final StorageService _storageService = StorageService();

  @override
  AuthState build() {
    return AuthState();
  }

  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true);
    try {
      final token = await _storageService.getToken();
      final userDataStr = await _storageService.getUserData();

      if (token != null && userDataStr != null) {
        final userData = jsonDecode(userDataStr) as Map<String, dynamic>;
        state = AuthState(
          token: token,
          user: UserModel.fromJson(userData),
          isLoading: false,
        );
        // Refresh profile in background to get latest server values
        refreshProfile();
      } else {
        state = AuthState(isLoading: false);
      }
    } catch (e) {
      state = AuthState(errorMessage: e.toString(), isLoading: false);
    }
  }

  Future<void> refreshProfile() async {
    try {
      const String meQuery = r'''
        query Me {
          me {
            id
            name
            email
            phone
            role
            profileImage
            walletBalance
            ratings
            isVerified
            isOnline
            vehicle {
              type
              model
              plateNumber
              color
            }
          }
        }
      ''';

      final response = await _graphQLService.performQuery(meQuery);
      if (!response.hasException && response.data?['me'] != null) {
        final userJson = response.data?['me'] as Map<String, dynamic>;
        final updatedUser = UserModel.fromJson(userJson);
        await _storageService.saveUserData(jsonEncode(userJson));
        state = state.copyWith(user: updatedUser);
      }
    } catch (e) {
      // Ignore background refresh errors
    }
  }

  Future<bool> registerDriver({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String vehicleType,
    required String vehicleModel,
    required String plateNumber,
    required String vehicleColor,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      const String registerMutation = r'''
        mutation RegisterDriver(
          $name: String!, 
          $email: String!, 
          $phone: String!, 
          $password: String!, 
          $role: String!,
          $vehicleType: String,
          $vehicleModel: String,
          $plateNumber: String,
          $vehicleColor: String
        ) {
          register(
            name: $name, 
            email: $email, 
            phone: $phone, 
            password: $password, 
            role: $role,
            vehicleType: $vehicleType,
            vehicleModel: $vehicleModel,
            plateNumber: $plateNumber,
            vehicleColor: $vehicleColor
          ) {
            token
            refreshToken
            user {
              id
              name
              email
              phone
              role
              profileImage
              walletBalance
              ratings
              isVerified
              isOnline
              vehicle {
                type
                model
                plateNumber
                color
              }
            }
          }
        }
      ''';

      final response = await _graphQLService.performMutation(
        registerMutation,
        variables: {
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
          'role': 'driver',
          'vehicleType': vehicleType,
          'vehicleModel': vehicleModel,
          'plateNumber': plateNumber,
          'vehicleColor': vehicleColor,
        },
      );

      if (response.hasException) {
        final errorMsg = response.exception?.graphqlErrors.isNotEmpty == true
            ? response.exception!.graphqlErrors.first.message
            : 'Registration failed. Please try again.';
        state = state.copyWith(isLoading: false, errorMessage: errorMsg);
        return false;
      }

      final data = response.data?['register'];
      if (data != null) {
        final token = data['token'] as String;
        final userJson = data['user'] as Map<String, dynamic>;
        final user = UserModel.fromJson(userJson);

        // Save token and user details to secure storage
        await _storageService.saveToken(token);
        await _storageService.saveUserData(jsonEncode(userJson));

        state = AuthState(
          token: token,
          user: user,
          isLoading: false,
        );
        return true;
      }

      state = state.copyWith(isLoading: false, errorMessage: 'Unexpected response from server');
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      const String loginMutation = r'''
        mutation Login($email: String!, $password: String!) {
          login(email: $email, password: $password) {
            token
            refreshToken
            user {
              id
              name
              email
              phone
              role
              profileImage
              walletBalance
              ratings
              isVerified
              isOnline
              vehicle {
                type
                model
                plateNumber
                color
              }
            }
          }
        }
      ''';

      final response = await _graphQLService.performMutation(
        loginMutation,
        variables: {
          'email': username,
          'password': password,
        },
      );

      if (response.hasException) {
        final errorMsg = response.exception?.graphqlErrors.isNotEmpty == true
            ? response.exception!.graphqlErrors.first.message
            : 'Login failed. Please check your credentials.';
        state = state.copyWith(isLoading: false, errorMessage: errorMsg);
        return false;
      }

      final data = response.data?['login'];
      if (data != null) {
        final token = data['token'] as String;
        final userJson = data['user'] as Map<String, dynamic>;
        final user = UserModel.fromJson(userJson);

        // Save token and user details to secure storage
        await _storageService.saveToken(token);
        await _storageService.saveUserData(jsonEncode(userJson));

        state = AuthState(
          token: token,
          user: user,
          isLoading: false,
        );
        return true;
      }

      state = state.copyWith(isLoading: false, errorMessage: 'Unexpected response from server');
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> toggleOnlineStatus(bool online) async {
    if (state.user == null) return false;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      const String toggleMutation = r'''
        mutation ToggleOnline($isOnline: Boolean!) {
          toggleOnline(isOnline: $isOnline) {
            id
            name
            email
            phone
            role
            profileImage
            walletBalance
            ratings
            isVerified
            isOnline
            vehicle {
              type
              model
              plateNumber
              color
            }
          }
        }
      ''';

      final response = await _graphQLService.performMutation(
        toggleMutation,
        variables: {
          'isOnline': online,
        },
      );

      if (response.hasException) {
        // Fallback to local state toggle if GraphQL mutation fails (e.g. mock token, backend down)
        final updatedUser = state.user!.copyWith(isOnline: online);
        await _storageService.saveUserData(jsonEncode(updatedUser.toJson()));
        state = state.copyWith(
          user: updatedUser,
          isLoading: false,
        );
        return true;
      }

      final userJson = response.data?['toggleOnline'] as Map<String, dynamic>?;
      if (userJson != null) {
        final updatedUser = UserModel.fromJson(userJson);
        await _storageService.saveUserData(jsonEncode(userJson));
        state = state.copyWith(
          user: updatedUser,
          isLoading: false,
        );
        return true;
      }

      // Fallback to local state toggle if response data is null
      final updatedUser = state.user!.copyWith(isOnline: online);
      await _storageService.saveUserData(jsonEncode(updatedUser.toJson()));
      state = state.copyWith(
        user: updatedUser,
        isLoading: false,
      );
      return true;
    } catch (e) {
      // Fallback to local state toggle on exceptions
      final updatedUser = state.user!.copyWith(isOnline: online);
      await _storageService.saveUserData(jsonEncode(updatedUser.toJson()));
      state = state.copyWith(
        user: updatedUser,
        isLoading: false,
      );
      return true;
    }
  }

  Future<bool> loginWithPhoneMock(String phone) async {
    state = state.copyWith(isLoading: true, clearError: true);
    await Future.delayed(const Duration(seconds: 1));
    state = state.copyWith(isLoading: false);
    return true;
  }

  Future<bool> verifyOtpMock(String phone, String otp) async {
    state = state.copyWith(isLoading: true, clearError: true);
    await Future.delayed(const Duration(seconds: 1));

    if (otp == '1234' || otp.length == 4) {
      final userDataStr = await _storageService.getUserData();
      if (userDataStr != null) {
        final userData = jsonDecode(userDataStr) as Map<String, dynamic>;
        final user = UserModel.fromJson(userData);
        if (user.phone == phone) {
          final token = await _storageService.getToken();
          state = AuthState(
            token: token,
            user: user,
            isLoading: false,
          );
          return true;
        }
      }

      final mockUser = UserModel(
        id: 'mock_driver_id',
        name: 'John Doe',
        email: 'driver@test.com',
        phone: phone,
        role: 'driver',
        walletBalance: 450.00,
        ratings: 4.8,
        isVerified: true,
      );

      final token = 'mock_jwt_token_12345';
      await _storageService.saveToken(token);
      await _storageService.saveUserData(jsonEncode(mockUser.toJson()));

      state = AuthState(
        token: token,
        user: mockUser,
        isLoading: false,
      );
      return true;
    } else {
      state = state.copyWith(isLoading: false, errorMessage: 'Invalid OTP code. Use 1234 to verify.');
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await _storageService.clearAll();
    state = AuthState(isLoading: false);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
