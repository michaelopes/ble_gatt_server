import 'dart:typed_data';

import 'package:ble_gatt_server/ble_gatt_server.dart';
import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'ble_gatt_server_method_channel.dart';

abstract class BleGattServerPlatform extends PlatformInterface {
  final Map<String, Function?> callbackHandler = {};

  BleGattServerPlatform() : super(token: _token);

  static final Object _token = Object();

  static BleGattServerPlatform _instance = MethodChannelBleGattServer();

  static BleGattServerPlatform get instance => _instance;

  static set instance(BleGattServerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<bool?> enableBluetooth() {
    throw UnimplementedError('enableBluetooth() has not been implemented.');
  }

  Future<bool?> isBluetoothEnabled() {
    throw UnimplementedError('isBluetoothEnabled() has not been implemented.');
  }

  Future<void> startAdvertising(BleAdvertisement advertisement) {
    throw UnimplementedError('startAdvertising() has not been implemented.');
  }

  Future<void> stopAdvertising() {
    throw UnimplementedError('stopAdvertising() has not been implemented.');
  }

  Future<void> addService(BleGattService gattService) {
    throw UnimplementedError('addService() has not been implemented.');
  }

  Future<void> startServer() {
    throw UnimplementedError('startServer() has not been implemented.');
  }

  Future<void> stopServer() {
    throw UnimplementedError('stopServer() has not been implemented.');
  }

  Future<void> sendResponse(BleDevice device, int requestId, int status, int offset, Uint8List? value) {
    throw UnimplementedError('sendResponse() has not been implemented.');
  }

  Future<void> notifyCharacteristic(BleDevice device, BleGattCharacteristic characteristic, Uint8List value) {
    throw UnimplementedError('notifyCharacteristic() has not been implemented.');
  }
}
