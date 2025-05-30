import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:ble_gatt_server/ble_gatt_server.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _bleGattServer = BleGattServer();
  final List<String> _log = [];

  final Map<String, Uint8List?> _descriptorValueMap = {};
  final Map<String, Uint8List?> _characteristicValueMap = {};

  final List<BleDevice> notifyDevices = [];

  @override
  void initState() {
    super.initState();
    bleGattServer();
  }

  Future<void> bleGattServer() async {

    await Permission.bluetooth.request();
    await Permission.bluetoothConnect.request();
    await Permission.bluetoothAdvertise.request();

    var bluetoothEnabled = await _bleGattServer.isBluetoothEnabled();
    appendToLog("Bluetooth enabled: $bluetoothEnabled");

    if (bluetoothEnabled != true) {
      bluetoothEnabled = await _bleGattServer.enableBluetooth();
      if (bluetoothEnabled != true) {
        _log.add("User did not enable bluetooth!");
        return;
      }
    }

    var advertisement = BleAdvertisement(
      dataContainer: BleAdvertisementDataContainer(
          advertisementData: BleAdvertisementData(
            includeTxPower: false,
            localName: "BleGattServer",
            manufacturerDataList: [
              //BleManufacturerData(
              //    manufacturerId: 1,
              //    data: Uint8List.fromList([0x00, 0x01])
              //)
            ],
            serviceDataList: [
              //BleServiceData(
              //    uuid: "8558e864-7f83-49c9-bf0e-ee173915b9dd",
              //    data: Uint8List.fromList([0x00, 0x01])
              //)
            ],
          ),
          scanResponseData: BleAdvertisementData(
              serviceUUIDList: [
                "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
              ]
          )
      ),
      settings: BleAdvertisementSettings(
          advertiseMode: BleAdvertisementSettings.ADVERTISE_MODE_LOW_LATENCY,
          timeout: 0,
          connectable: true,
          discoverable: false,
          txPowerLevel: BleAdvertisementSettings.ADVERTISE_TX_POWER_HIGH
      )
    );

    await _bleGattServer.startAdvertising(advertisement);

    var gattDescriptor = BleGattDescriptor(
        uuid: "00002902-0000-1000-8000-00805f9b34fb",
        permissions: BleGattDescriptor.PERMISSION_READ | BleGattDescriptor.PERMISSION_WRITE
    );

    var gattCharacteristic = BleGattCharacteristic(
        uuid: "beb5483e-36e1-4688-b7f5-ea07361b26a8",
        properties: BleGattCharacteristic.PROPERTY_READ | BleGattCharacteristic.PROPERTY_WRITE | BleGattCharacteristic.PROPERTY_NOTIFY,
        permissions: BleGattCharacteristic.PERMISSION_READ | BleGattCharacteristic.PERMISSION_WRITE,
        descriptors: [
          gattDescriptor
        ]
    );

    _descriptorValueMap[gattDescriptor.uuid] = BleGattDescriptor.DISABLE_NOTIFICATION_VALUE;
    _characteristicValueMap[gattCharacteristic.uuid] = Uint8List.fromList([0x01, 0x02, 0x03]);

    // Important: The server must be started before you can add services
    await _bleGattServer.startServer();

    await _bleGattServer.addService(
        BleGattService(
            uuid: "4fafc201-1fb5-459e-8fcc-c5c9c331914b",
            serviceType: BleGattService.SERVICE_TYPE_PRIMARY,
            characteristics: [
              gattCharacteristic
            ]
        )
    );

    _bleGattServer.handleEvents(
      onAdvertiseStartFailure: (errorCode) {
        appendToLog("Advertising failed: $errorCode");
      },
      onAdvertiseStartSuccess: (settingsInEffect) {
        appendToLog("Advertising started: $settingsInEffect");
      },
      onConnectionStateChange: (device, status, newState) {
        appendToLog("Connection changed: ${device?.address}, $status, $newState");
      },
      onCharacteristicReadRequest: (device, requestId, offset, characteristic) async {
        appendToLog("Read request: ${device?.address}, $requestId, $offset, ${characteristic?.uuid}");
        await _bleGattServer.sendResponse(device!, requestId, BleGattServer.GATT_SUCCESS, offset, _characteristicValueMap[characteristic?.uuid]);
      },
      onCharacteristicWriteRequest: (device, requestId, characteristic, preparedWrite, responseNeeded, offset, value) async {
        appendToLog("Write request: ${device?.address}, $requestId, ${characteristic?.uuid}, $preparedWrite, $responseNeeded, $offset, $value");
        if (characteristic != null) {
          _characteristicValueMap[characteristic.uuid] = value;
        }
        await _bleGattServer.sendResponse(device!, requestId, BleGattServer.GATT_SUCCESS, offset, null);
      },
      onDescriptorReadRequest: (device, requestId, offset, descriptor) async {
        appendToLog("Descriptor read request: ${device?.address}, $requestId, $offset, ${descriptor?.uuid}");
        await _bleGattServer.sendResponse(device!, requestId, BleGattServer.GATT_SUCCESS, offset, _descriptorValueMap[descriptor?.uuid]);
      },
      onDescriptorWriteRequest: (device, requestId, descriptor, preparedWrite, responseNeeded, offset, value) async {
        appendToLog("Descriptor write request: ${device?.address}, $requestId, ${descriptor?.uuid}, $preparedWrite, $responseNeeded, $offset, $value");
        if (descriptor != null) {
          _descriptorValueMap[descriptor.uuid] = value;
        }
        await _bleGattServer.sendResponse(device!, requestId, BleGattServer.GATT_SUCCESS, offset, null);

        if (listEquals(value, BleGattDescriptor.ENABLE_NOTIFICATION_VALUE)) {
          notifyDevices.add(device);
        } else if (listEquals(value, BleGattDescriptor.DISABLE_NOTIFICATION_VALUE)) {
          notifyDevices.remove(device);
        }
      },
      onExecuteWrite: (device, requestId, execute) {
        appendToLog("Execute write: ${device?.address}, $requestId, $execute");
      },
      onNotificationSent: (device, status) {
        appendToLog("Notification sent: ${device?.address}, $status");
      },
      onMtuChanged: (device, mtu) {
        appendToLog("MTU changed: ${device?.address}, $mtu");
      },
    );

    Timer.periodic(Duration(seconds: 1), (timer) async {
      for(BleDevice device in notifyDevices) {
        await _bleGattServer.notifyCharacteristic(device, gattCharacteristic, Uint8List.fromList([DateTime.now().second]));
      }
    },);

    //await _bleGattServerPlugin.stopServer();
  }

  void appendToLog(String message) {
    setState(() {
      _log.add(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('BLE GATT Server Example'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            reverse: true,
            child: Text(_log.join("\n")),
          ),
        ),
      ),
    );
  }
}
