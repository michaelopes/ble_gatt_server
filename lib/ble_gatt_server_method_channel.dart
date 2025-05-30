import 'package:ble_gatt_server/ble_gatt_server.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'ble_gatt_server_platform_interface.dart';
import 'data_serializer.dart';

class MethodChannelBleGattServer extends BleGattServerPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('de.blitzdose.ble_gatt_server');

  MethodChannelBleGattServer() {
    methodChannel.setMethodCallHandler((call) async {
      try {
        Function.apply(callbackHandler[call.method]!, call.arguments as List<dynamic>);
      } catch (e) {
        //
      }
      return true;
    },);
  }

  @override
  Future<bool?> enableBluetooth() {
    return methodChannel.invokeMethod<bool>("enableBluetooth");
  }

  @override
  Future<bool?> isBluetoothEnabled() async {
    return methodChannel.invokeMethod<bool>('isBluetoothEnabled');
  }

  @override
  Future<void> startAdvertising(BleAdvertisement advertisement) async {
    return methodChannel.invokeMethod('startAdvertising', {"advertisement": Serializer.advertisement(advertisement)});
  }

  @override
  Future<void> stopAdvertising() async {
    return methodChannel.invokeMethod("stopAdvertising");
  }

  @override
  Future<void> addService(BleGattService gattService) async {
    return methodChannel.invokeMethod("addService", {"service": Serializer.gattService(gattService)});
  }

  @override
  Future<void> startServer() async {
    return methodChannel.invokeMethod("startServer");
  }

  @override
  Future<void> stopServer() {
    return methodChannel.invokeMethod("stopServer");
  }

  @override
  Future<void> sendResponse(BleDevice device, int requestId, int status, int offset, Uint8List? value) async {
    return methodChannel.invokeMethod("sendResponse", {
      "device": Serializer.device(device),
      "requestId": requestId,
      "status": status,
      "offset": offset,
      "value": value
    });
  }

  @override
  Future<void> notifyCharacteristic(BleDevice device, BleGattCharacteristic characteristic, Uint8List value) async {
    return methodChannel.invokeMethod("notifyCharacteristic", {
      "device": Serializer.device(device),
      "characteristic": Serializer.gattCharacteristic(characteristic),
      "value": value
    });
  }
}
