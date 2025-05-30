import 'dart:typed_data';

import 'package:ble_gatt_server/data_serializer.dart';

import 'ble_gatt_server.dart';

Function(Map<Object?, Object?>?) onAdvertiseStartSuccess(Function(BleAdvertisementSettings? settingsInEffect) onAdvertiseStartSuccess) {
  return (serialized) {
    onAdvertiseStartSuccess(DeSerializer.advertisementSettings(serialized?.cast<String, dynamic>()));
  };
}

Function(Map<Object?, Object?>?, int, int) onConnectionStateChanged(Function(BleDevice? device, int status, int newState) onConnectionStateChanged) {
  return (serializedDevice, status, newState) {
    onConnectionStateChanged(
        DeSerializer.device(serializedDevice?.cast<String, dynamic>()),
        status,
        newState
    );
  };
}

Function(Map<Object?, Object?>?, int, int, Map<Object?, Object?>?) onCharacteristicReadRequest(Function(BleDevice? device, int requestId, int offset, BleGattCharacteristic? characteristic) onCharacteristicReadRequest) {
  return (serializedDevice, requestId, offset, serializedCharacteristic) {
    onCharacteristicReadRequest(
        DeSerializer.device(serializedDevice?.cast<String, dynamic>()),
        requestId,
        offset,
        DeSerializer.gattCharacteristic(serializedCharacteristic?.cast<String, dynamic>())
    );
  };
}

Function(Map<Object?, Object?>?, int, Map<Object?, Object?>?, bool, bool, int, Uint8List?) onCharacteristicWriteRequest(Function(BleDevice? device, int requestId, BleGattCharacteristic? characteristic, bool preparedWrite, bool responseNeeded, int offset, Uint8List? value) onCharacteristicWriteRequest) {
  return (serializedDevice, requestId, serializedCharacteristic, preparedWrite, responseNeeded, offset, value) {
    onCharacteristicWriteRequest(
      DeSerializer.device(serializedDevice?.cast<String, dynamic>()),
      requestId,
      DeSerializer.gattCharacteristic(serializedCharacteristic?.cast<String, dynamic>()),
      preparedWrite,
      responseNeeded,
      offset,
      value
    );
  };
}

Function(Map<Object?, Object?>?, int, int, Map<Object?, Object?>?) onDescriptorReadRequest(Function(BleDevice? device, int requestId, int offset, BleGattDescriptor? descriptor) onDescriptorReadRequest) {
  return (serializedDevice, requestId, offset, serializedDescriptor) {
    onDescriptorReadRequest(
      DeSerializer.device(serializedDevice?.cast<String, dynamic>()),
      requestId,
      offset,
      DeSerializer.gattDescriptor(serializedDescriptor?.cast<String, dynamic>())
    );
  };
}

Function(Map<Object?, Object?>?, int, Map<Object?, Object?>?, bool, bool, int, Uint8List?) onDescriptorWriteRequest(Function(BleDevice? device, int requestId, BleGattDescriptor? descriptor, bool preparedWrite, bool responseNeeded, int offset, Uint8List? value) onDescriptorWriteRequest) {
  return (serializedDevice, requestId, serializedDescriptor, preparedWrite, responseNeeded, offset, value) {
    onDescriptorWriteRequest(
      DeSerializer.device(serializedDevice?.cast<String, dynamic>()),
      requestId,
      DeSerializer.gattDescriptor(serializedDescriptor?.cast<String, dynamic>()),
      preparedWrite,
      responseNeeded,
      offset,
      value
    );
  };
}

Function(Map<Object?, Object?>?, int, bool) onExecuteWrite(Function(BleDevice? device, int requestId, bool execute) onExecuteWrite) {
  return (serializedDevice, requestId, execute) {
    onExecuteWrite(
      DeSerializer.device(serializedDevice?.cast<String, dynamic>()),
      requestId,
      execute
    );
  };
}

Function(Map<Object?, Object?>?, int) onNotificationSent(Function(BleDevice? device, int status) onNotificationSent) {
  return (serializedDevice, status) {
    onNotificationSent(
        DeSerializer.device(serializedDevice?.cast<String, dynamic>()),
        status
    );
  };
}

Function(Map<Object?, Object?>?, int) onMtuChanged(Function(BleDevice? device, int mtu) onMtuChanged) {
  return (serializedDevice, mtu) {
    onMtuChanged(
      DeSerializer.device(serializedDevice?.cast<String, dynamic>()),
      mtu
    );
  };
}