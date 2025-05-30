import 'package:flutter/services.dart';

class BleGattServerException implements Exception {
  final int errorCode;
  final String message;

  BleGattServerException(this.errorCode, this.message);

  static Exception parse(PlatformException e) {
    switch (int.tryParse(e.code)) {
      case 1:
        return DeviceNotConnectedException(message: e.message ?? "");
      case 2:
        return CharacteristicNotDefinedException(message: e.message ?? "");
      case 3:
        return ResponseNotSentException(message: e.message ?? "");
      case 4:
        return NotificationNotSentException(message: e.message ?? "");
      case 5:
        return ServerNotRunningException(message: e.message ?? "");
      default:
        return e;
    }
  }
}

class DeviceNotConnectedException extends BleGattServerException {
  DeviceNotConnectedException({String message = "Device is not connected"}) : super(1, message);

  @override
  String toString() {
    return "DeviceNotConnectedException: $message";
  }
}

class CharacteristicNotDefinedException extends BleGattServerException {
  CharacteristicNotDefinedException({String message = "Characteristic is unknown to the server"}) : super(2, message);

  @override
  String toString() {
    return "CharacteristicNotDefinedException: $message";
  }
}

class ResponseNotSentException extends BleGattServerException {
  ResponseNotSentException({String message = "Response could not be sent"}) : super(3, message);

  @override
  String toString() {
    return "ResponseNotSentException: $message";
  }
}

class NotificationNotSentException extends BleGattServerException {
  NotificationNotSentException({String message = "Notification could not be sent"}) : super(4, message);

  @override
  String toString() {
    return "NotificationNotSentException: $message";
  }
}

class ServerNotRunningException extends BleGattServerException {
  ServerNotRunningException({String message = "GATT Server is not running"}) : super(5, message);

  @override
  String toString() {
    return "ServerNotRunningException: $message";
  }
}