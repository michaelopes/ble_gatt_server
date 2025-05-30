import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'ble_gatt_server_exception.dart';
import 'ble_gatt_server_platform_interface.dart';
import 'callback_function_mapper.dart' as CallbackFunctionMapper;

class BleGattServer {

  static const int DEVICE_STATE_CONNECTED = 2;
  static const int DEVICE_STATE_DISCONNECTED = 0;

  static const int GATT_SUCCESS = 0;
  static const int GATT_FAILURE = 257;

  Future<bool?> enableBluetooth() async {
    return _handleExceptions<bool?>(() => BleGattServerPlatform.instance.enableBluetooth());
  }

  Future<bool?> isBluetoothEnabled() async {
    return _handleExceptions<bool?>(() => BleGattServerPlatform.instance.isBluetoothEnabled());
  }

  Future<void> startAdvertising(BleAdvertisement advertisement) async {
    return _handleExceptions<void>(() => BleGattServerPlatform.instance.startAdvertising(advertisement));
  }

  Future<void> stopAdvertising() async {
    return _handleExceptions<void>(() => BleGattServerPlatform.instance.stopAdvertising());
  }

  Future<void> addService(BleGattService gattService) async {
    return _handleExceptions<void>(() => BleGattServerPlatform.instance.addService(gattService));
  }

  Future<void> startServer() async {
    return _handleExceptions<void>(() => BleGattServerPlatform.instance.startServer());
  }

  Future<void> stopServer() async {
    return _handleExceptions<void>(() => BleGattServerPlatform.instance.stopServer());
  }

  Future<void> sendResponse(BleDevice device, int requestId, int status, int offset, Uint8List? value) async {
    return _handleExceptions<void>(() => BleGattServerPlatform.instance.sendResponse(device, requestId, status, offset, value));
  }

  Future<void> notifyCharacteristic(BleDevice device, BleGattCharacteristic characteristic, Uint8List value) async {
    return _handleExceptions<void>(() => BleGattServerPlatform.instance.notifyCharacteristic(device, characteristic, value));
  }

  Future<void> handleEvents({
    Function(int errorCode)? onAdvertiseStartFailure,
    Function(BleAdvertisementSettings? settingsInEffect)? onAdvertiseStartSuccess,
    Function(BleDevice? device, int status, int newState)? onConnectionStateChange,
    Function(BleDevice? device, int requestId, int offset, BleGattCharacteristic? characteristic)? onCharacteristicReadRequest,
    Function(BleDevice? device, int requestId, BleGattCharacteristic? characteristic, bool preparedWrite, bool responseNeeded, int offset, Uint8List? value)? onCharacteristicWriteRequest,
    Function(BleDevice? device, int requestId, int offset, BleGattDescriptor? descriptor)? onDescriptorReadRequest,
    Function(BleDevice? device, int requestId, BleGattDescriptor? descriptor, bool preparedWrite, bool responseNeeded, int offset, Uint8List? value)? onDescriptorWriteRequest,
    Function(BleDevice? device, int requestId, bool execute)? onExecuteWrite,
    Function(BleDevice? device, int status)? onNotificationSent,
    Function(BleDevice? device, int mtu)? onMtuChanged
  }) async {
    if (onAdvertiseStartFailure != null) BleGattServerPlatform.instance.callbackHandler["onAdvertiseStartFailure"] = onAdvertiseStartFailure;
    if (onAdvertiseStartSuccess != null) BleGattServerPlatform.instance.callbackHandler["onAdvertiseStartSuccess"] = CallbackFunctionMapper.onAdvertiseStartSuccess(onAdvertiseStartSuccess);
    if (onConnectionStateChange != null) BleGattServerPlatform.instance.callbackHandler["onConnectionStateChange"] = CallbackFunctionMapper.onConnectionStateChanged(onConnectionStateChange);
    if (onCharacteristicReadRequest != null) BleGattServerPlatform.instance.callbackHandler["onCharacteristicReadRequest"] = CallbackFunctionMapper.onCharacteristicReadRequest(onCharacteristicReadRequest);
    if (onCharacteristicWriteRequest != null) BleGattServerPlatform.instance.callbackHandler["onCharacteristicWriteRequest"] = CallbackFunctionMapper.onCharacteristicWriteRequest(onCharacteristicWriteRequest);
    if (onDescriptorReadRequest != null) BleGattServerPlatform.instance.callbackHandler["onDescriptorReadRequest"] = CallbackFunctionMapper.onDescriptorReadRequest(onDescriptorReadRequest);
    if (onDescriptorWriteRequest != null) BleGattServerPlatform.instance.callbackHandler["onDescriptorWriteRequest"] = CallbackFunctionMapper.onDescriptorWriteRequest(onDescriptorWriteRequest);
    if (onExecuteWrite != null) BleGattServerPlatform.instance.callbackHandler["onExecuteWrite"] = CallbackFunctionMapper.onExecuteWrite(onExecuteWrite);
    if (onNotificationSent != null) BleGattServerPlatform.instance.callbackHandler["onNotificationSent"] = CallbackFunctionMapper.onNotificationSent(onNotificationSent);
    if (onMtuChanged != null) BleGattServerPlatform.instance.callbackHandler["onMtuChanged"] = CallbackFunctionMapper.onMtuChanged(onMtuChanged);
  }

  Future<T> _handleExceptions<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on PlatformException catch (e) {
      throw BleGattServerException.parse(e);
    }
  }
}

class BleGattService {
  static const int SERVICE_TYPE_PRIMARY = 0;
  static const int SERVICE_TYPE_SECONDARY = 1;

  String uuid;
  int serviceType;
  List<BleGattCharacteristic> characteristics;
  List<BleGattService> services;

  BleGattService({
    required this.uuid,
    required this.serviceType,
    this.characteristics = const [],
    this.services = const []
  });

  void addService(BleGattService service) {
    services.add(service);
  }

  void addCharacteristic(BleGattCharacteristic characteristic) {
    characteristics.add(characteristic);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is BleGattService &&
              uuid == other.uuid &&
              serviceType == other.serviceType &&
              listEquals(characteristics, other.characteristics) &&
              listEquals(services, other.services);

  @override
  int get hashCode => Object.hash(
      uuid,
      serviceType,
      Object.hashAll(characteristics),
      Object.hashAll(services)
  );
}

class BleGattCharacteristic {

  static const int PERMISSION_READ = 1;
  static const int PERMISSION_READ_ENCRYPTED = 2;
  static const int PERMISSION_READ_ENCRYPTED_MITM = 4;
  static const int PERMISSION_WRITE = 16;
  static const int PERMISSION_WRITE_ENCRYPTED = 32;
  static const int PERMISSION_WRITE_ENCRYPTED_MITM = 64;
  static const int PERMISSION_WRITE_SIGNED = 128;
  static const int PERMISSION_WRITE_SIGNED_MITM = 256;
  static const int PROPERTY_BROADCAST = 1;
  static const int PROPERTY_EXTENDED_PROPS = 128;
  static const int PROPERTY_INDICATE = 32;
  static const int PROPERTY_NOTIFY = 16;
  static const int PROPERTY_READ = 2;
  static const int PROPERTY_SIGNED_WRITE = 64;
  static const int PROPERTY_WRITE = 8;
  static const int PROPERTY_WRITE_NO_RESPONSE = 4;

  String uuid;
  int properties;
  int permissions;
  List<BleGattDescriptor> descriptors = [];

  BleGattCharacteristic({
    required this.uuid,
    required this.properties,
    required this.permissions,
    List<BleGattDescriptor>? descriptors
  }) {
    if (descriptors != null) {
      this.descriptors.addAll(descriptors);
    }
  }

  void addDescriptor(BleGattDescriptor descriptor) {
    descriptors.add(descriptor);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is BleGattCharacteristic &&
              uuid == other.uuid &&
              properties == other.properties &&
              permissions == other.permissions &&
              listEquals(descriptors, other.descriptors);

  @override
  int get hashCode => Object.hash(
      uuid,
      properties,
      permissions,
      Object.hashAll(descriptors)
  );
}

class BleGattDescriptor {

  static const int PERMISSION_READ = 1;
  static const int PERMISSION_READ_ENCRYPTED = 2;
  static const int PERMISSION_READ_ENCRYPTED_MITM = 4;
  static const int PERMISSION_WRITE = 16;
  static const int PERMISSION_WRITE_ENCRYPTED = 32;
  static const int PERMISSION_WRITE_ENCRYPTED_MITM = 64;
  static const int PERMISSION_WRITE_SIGNED = 128;
  static const int PERMISSION_WRITE_SIGNED_MITM = 256;

  static Uint8List ENABLE_NOTIFICATION_VALUE = Uint8List.fromList([0x01, 0x00]);
  static Uint8List ENABLE_INDICATION_VALUE = Uint8List.fromList([0x02, 0x00]);
  static Uint8List DISABLE_NOTIFICATION_VALUE = Uint8List.fromList([0x00, 0x00]);

  String uuid;
  int permissions;

  BleGattDescriptor({
    required this.uuid,
    required this.permissions
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is BleGattDescriptor &&
              uuid == other.uuid &&
              permissions == other.permissions;

  @override
  int get hashCode => Object.hash(
      uuid,
      permissions
  );
}

class BleAdvertisement {

  static const int ADVERTISE_FAILED_ALREADY_STARTED = 3;
  static const int ADVERTISE_FAILED_DATA_TOO_LARGE = 1;
  static const int ADVERTISE_FAILED_FEATURE_UNSUPPORTED = 5;
  static const int ADVERTISE_FAILED_INTERNAL_ERROR = 4;
  static const int ADVERTISE_FAILED_TOO_MANY_ADVERTISERS = 2;

  BleAdvertisementDataContainer dataContainer;
  BleAdvertisementSettings settings;

  BleAdvertisement({
    required this.dataContainer,
    required this.settings
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is BleAdvertisement &&
              dataContainer == other.dataContainer &&
              settings == other.settings;

  @override
  int get hashCode => Object.hash(
      dataContainer,
      settings
  );
}

class BleDevice {
  String address;

  BleDevice({
    required this.address
  });

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is BleDevice &&
        address == other.address;

  @override
  int get hashCode => Object.hash(address, true);
}

class BleAdvertisementDataContainer {

  BleAdvertisementData? advertisementData;
  BleAdvertisementData? scanResponseData;

  BleAdvertisementDataContainer({
    this.advertisementData,
    this.scanResponseData
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is BleAdvertisementDataContainer &&
              advertisementData == other.advertisementData &&
              scanResponseData == other.scanResponseData;

  @override
  int get hashCode => Object.hash(
      advertisementData,
      scanResponseData
  );
}

class BleAdvertisementData {
  String? localName;
  bool includeTxPower;
  List<BleManufacturerData> manufacturerDataList;
  List<String> serviceUUIDList;
  List<BleServiceData> serviceDataList;

  BleAdvertisementData({
    this.localName,
    this.includeTxPower = false,
    this.manufacturerDataList = const [],
    this.serviceUUIDList = const [],
    this.serviceDataList = const []
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is BleAdvertisementData &&
              localName == other.localName &&
              includeTxPower == other.includeTxPower &&
              listEquals(manufacturerDataList, other.manufacturerDataList) &&
              listEquals(serviceUUIDList, other.serviceUUIDList) &&
              listEquals(serviceDataList, other.serviceDataList);

  @override
  int get hashCode => Object.hash(
      localName,
      includeTxPower,
      Object.hashAll(manufacturerDataList),
      Object.hashAll(serviceUUIDList),
      Object.hashAll(serviceDataList)
  );
}

class BleManufacturerData {
  int manufacturerId;
  Uint8List data;

  BleManufacturerData({
    required this.manufacturerId,
    required this.data
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is BleManufacturerData &&
              manufacturerId == other.manufacturerId &&
              listEquals(data, other.data);

  @override
  int get hashCode => Object.hash(
      manufacturerId,
      Object.hashAll(data)
  );
}

class BleServiceData {
  String uuid;
  Uint8List data;

  BleServiceData({
    required this.uuid,
    required this.data
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is BleServiceData &&
              uuid == other.uuid &&
              listEquals(data, other.data);

  @override
  int get hashCode => Object.hash(
      uuid,
      Object.hashAll(data)
  );
}

class BleAdvertisementSettings {

  static const int ADVERTISE_MODE_BALANCED = 1;
  static const int ADVERTISE_MODE_LOW_LATENCY = 2;
  static const int ADVERTISE_MODE_LOW_POWER = 0;
  static const int ADVERTISE_TX_POWER_HIGH = 3;
  static const int ADVERTISE_TX_POWER_LOW = 1;
  static const int ADVERTISE_TX_POWER_MEDIUM = 2;
  static const int ADVERTISE_TX_POWER_ULTRA_LOW = 0;

  int advertiseMode;
  int timeout;
  bool connectable;
  bool discoverable;
  int txPowerLevel;

  BleAdvertisementSettings({
    this.advertiseMode = ADVERTISE_MODE_BALANCED,
    this.timeout = 0,
    this.connectable = true,
    this.discoverable = true,
    this.txPowerLevel = ADVERTISE_TX_POWER_HIGH
  });

  @override
  String toString() {
    return "$advertiseMode, $timeout, $connectable, $discoverable, $txPowerLevel";
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is BleAdvertisementSettings &&
              advertiseMode == other.advertiseMode &&
              timeout == other.timeout &&
              connectable == other.connectable &&
              discoverable == other.discoverable &&
              txPowerLevel == other.txPowerLevel;

  @override
  int get hashCode => Object.hash(
      advertiseMode,
      timeout,
      connectable,
      discoverable,
      txPowerLevel,
  );
}
