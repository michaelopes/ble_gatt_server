import 'ble_gatt_server.dart';

class Serializer {

  static Map<String, dynamic> device(BleDevice device) {
    return {
      'address': device.address
    };
  }

  static Map<String, dynamic> advertisement(BleAdvertisement advertisement) {
    return {
      'dataContainer': advertisementContainer(advertisement.dataContainer),
      'settings': advertisementSettings(advertisement.settings)
    };
  }

  static Map<String, dynamic> advertisementContainer(BleAdvertisementDataContainer container) {
    return {
      'advertisementData': advertisementData(container.advertisementData),
      'scanResponseData': advertisementData(container.scanResponseData)
    };
  }

  static Map<String, dynamic>? advertisementData(BleAdvertisementData? data) {
    if (data == null) {
      return null;
    }
    return {
      'localName': data.localName,
      'includeTxPower': data.includeTxPower,
      'manufacturerDataList': data.manufacturerDataList.map((e) => manufacturerData(e),).toList(),
      'serviceUUIDList': data.serviceUUIDList,
      'serviceDataList': data.serviceDataList.map((e) => serviceData(e)).toList()
    };
  }

  static Map<String, dynamic> manufacturerData(BleManufacturerData data) {
    return {
      'manufacturerId': data.manufacturerId,
      'data': data.data
    };
  }

  static Map<String, dynamic> serviceData(BleServiceData serviceData) {
    return {
      'uuid': serviceData.uuid,
      'data': serviceData.data
    };
  }

  static Map<String, dynamic> advertisementSettings(BleAdvertisementSettings settings) {
    return {
      'advertiseMode': settings.advertiseMode,
      'timeout': settings.timeout,
      'connectable': settings.connectable,
      'discoverable': settings.discoverable,
      'txPowerLevel': settings.txPowerLevel
    };
  }

  static Map<String, dynamic> gattService(BleGattService service) {
    return {
      'uuid': service.uuid,
      'serviceType': service.serviceType,
      'characteristics': service.characteristics.map((e) => gattCharacteristic(e)).toList(),
      'services': service.services.map((e) => gattService(e)).toList()
    };
  }

  static Map<String, dynamic> gattCharacteristic(BleGattCharacteristic characteristic) {
    return {
      'uuid': characteristic.uuid,
      'properties': characteristic.properties,
      'permissions': characteristic.permissions,
      'descriptors': characteristic.descriptors.map((e) => gattDescriptors(e)).toList()
    };
  }

  static Map<String, dynamic> gattDescriptors(BleGattDescriptor descriptor) {
    return {
      'uuid': descriptor.uuid,
      'permissions': descriptor.permissions
    };
  }
}

class DeSerializer {
  static BleDevice? device(Map<String, dynamic>? device) {
    if (device == null) return null;
    return BleDevice(
      address: device["address"]
    );
  }

  static BleGattCharacteristic? gattCharacteristic(Map<String, dynamic>? characteristic) {
    if (characteristic == null) return null;
    var gattCharacteristic = BleGattCharacteristic(
        uuid: characteristic["uuid"],
        properties: characteristic["properties"],
        permissions: characteristic["permissions"]
    );

    for(Object? descriptor in characteristic["descriptors"] as List<Object?>) {
      if (descriptor != null) {
        descriptor = descriptor as Map<Object?, Object?>;
        BleGattDescriptor? gattDescriptor = DeSerializer.gattDescriptor(descriptor.cast<String, dynamic>());
        if (gattDescriptor != null) gattCharacteristic.addDescriptor(gattDescriptor);
      }
    }

    return gattCharacteristic;
  }

  static BleGattDescriptor? gattDescriptor(Map<String, dynamic>? descriptor) {
    if (descriptor == null) return null;
    return BleGattDescriptor(
        uuid: descriptor["uuid"],
        permissions: descriptor["permissions"]
    );
  }

  static BleAdvertisementSettings? advertisementSettings(Map<String, dynamic>? settings) {
    if (settings == null) return null;
    return BleAdvertisementSettings(
      advertiseMode: settings["advertiseMode"],
      timeout: settings["timeout"],
      connectable: settings["connectable"],
      discoverable: settings["discoverable"],
      txPowerLevel: settings["txPowerLevel"]
    );
  }
}