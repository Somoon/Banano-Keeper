import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricUtil {
  LocalAuthentication auth = LocalAuthentication();
  Future<bool> authenticate([String reason = ""]) async {
    //

    bool can = await canAuth();
    if (!can) return false;
    // if (!isBiometricsAvailable) return false;

    try {
      return await auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
          // biometricOnly: true,
        ),
      );
    } on PlatformException {
      return false;
    }
  }

  Future<bool> canAuth() async {
    try {
      final bool isDeviceSupported = await auth.isDeviceSupported();
      print("isDeviceSupported $isDeviceSupported");

      //always returns true even if user did not setup biometric on device
      // final bool canCheckBiometrics = await auth.canCheckBiometrics;
      // print("canCheckBiometrics $canCheckBiometrics");

      // final bool canAuthenticate = canCheckBiometrics || isDeviceSupported;
      return isDeviceSupported;
    } on PlatformException catch (e) {
      print("CANAUTH PLAT EXCEpt");
      print(e);
      return false;
    }
  }

  ///
  /// hasBiometrics()
  ///
  /// @returns [true] if device has fingerprint/faceID available and registered, [false] otherwise
  Future<bool> hasBiometrics() async {
    LocalAuthentication localAuth = LocalAuthentication();
    bool canCheck = await localAuth.canCheckBiometrics;
    if (canCheck) {
      List<BiometricType> availableBiometrics =
          await localAuth.getAvailableBiometrics();

      if (availableBiometrics.contains(BiometricType.face)) {
        return true;
      } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
        return true;
      }
    }
    return false;
  }

  ///
  /// authenticateWithBiometrics()
  ///
  /// @param [message] Message shown to user in FaceID/TouchID popup
  /// @returns [true] if successfully authenticated, [false] otherwise
  // Future<bool> authenticateWithBiometrics(
  //     BuildContext context, String message) async {
  //   bool hasBiometricsEnrolled = await hasBiometrics();
  //   if (hasBiometricsEnrolled) {
  //     LocalAuthentication localAuth = LocalAuthentication();
  //
  //     return await localAuth.authenticateWithBiometrics(
  //         localizedReason: message, useErrorDialogs: false);
  //   }
  //   return false;
  // }
}
