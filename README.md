# ble_gatt_server

A BLE GATT Server implementation to create a custom GATT Server as well as a custom advertisement,
because none of the other implementations (which are definitely awesome btw) worked for my project :)

This is designed to be pretty low-level, meaning it is basically just a direct map to the native
(Android) methods and classes. If you don't know what a parameter does, have a look at the Android
documentation (e.g. [here](https://developer.android.com/reference/android/bluetooth/BluetoothGattServer)).

For now, only Android is supported. I am planning to add support for at least IOS too.

## Features

| Functionality        |      Android       | iOS | Description                                                  |
|----------------------|:------------------:|:---:|--------------------------------------------------------------|
| Enable Bluetooth     | :white_check_mark: | :x: | Enable Bluetooth on the device                               |
| Create Advertisement | :white_check_mark: | :x: | Create a custom advertisement including all its features     |
| Create GATT Services | :white_check_mark: | :x: | Create custom GATT services, characteristics and descriptors |
| Event Handling       | :white_check_mark: | :x: | React to reads, writes and other events                      |
| Send notifications   | :white_check_mark: | :x: | Send notifications to subscribed clients                     |

Although all this functionality is implemented, testing all this on many different Android versions is
not that simple. If you notice strange behavior: [Report a Bug](https://github.com/blitzdose/ble_gatt_server/issues/new)

## Setup

In order to use any bluetooth functionality, you need to request the corresponding permissions.

<details>
<summary>Android (click to expand)</summary>

Required permissions that needed to be added to your AndroidManifest.xml file:
```XML
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.BLUETOOTH_ADVERTISE" />
```

Additionally, you need to request the permissions, e.g. using [permission_handler](https://pub.dev/packages/permission_handler)

</details>

## Usage

Definitely have a look at the [example](https://github.com/blitzdose/ble_gatt_server/blob/master/example/lib/main.dart), 
it uses pretty much every function this package offers. But here is a detailed list of all functions:

### Initialize Plugin
Just to create an instance of it for using the other methods.
```dart
final _bleGattServer = BleGattServer();
```

### Power methods
#### Check if Bluetooth is enabled
Check if Bluetooth is enabled on the device, returns null if an error to the native code happens,
which should not, but can happen due to bugs in my code
```dart
bool? bluetoothEnabled = await _bleGattServer.isBluetoothEnabled();
```

#### Enable Bluetooth
Sends a request to the user to enable Bluetooth. A little message appears with the option to allow
and deny the enabling of Bluetooth. The boolean represents the choice of the user.
```dart
bool? bluetoothEnabled = await _bleGattServer.enableBluetooth();
```

### Advertisement
#### Create advertisement
Please not that this code below is not functional, because the advertisement is too large, it just
demonstrates all the possible features.
```dart
var advertisement = BleAdvertisement(
      dataContainer: BleAdvertisementDataContainer(
          advertisementData: BleAdvertisementData(
            includeTxPower: false,
            localName: "BleGattServer",
            manufacturerDataList: [
              BleManufacturerData(
                  manufacturerId: 1,
                  data: Uint8List.fromList([0x00, 0x01])
              )
            ],
            serviceDataList: [
              BleServiceData(
                  uuid: "8558e864-7f83-49c9-bf0e-ee173915b9dd",
                  data: Uint8List.fromList([0x00, 0x01])
              )
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
```

#### Start advertising
Start advertising the created advertisement.
```dart
await _bleGattServer.startAdvertising(advertisement);
```

#### Stop advertising
Stops advertising.
```dart
await _bleGattServer.stopAdvertising();
```

### GATT 
#### Start Server
This is required before adding the services to it! This starts the actual GATT server.

```dart
await _bleGattServer.startServer();
```

#### Stop Server
Stops the GATT server (But not the advertisement).
```dart
await _bleGattServer.stopServer();
```

#### GATT Descriptor
Creates a GATT Descriptor to be used with a Characteristic. The UUID below enables the possibility
for clients to subscribe to notifications.
```dart
var gattDescriptor = BleGattDescriptor(
        uuid: "00002902-0000-1000-8000-00805f9b34fb",
        permissions: BleGattDescriptor.PERMISSION_READ | BleGattDescriptor.PERMISSION_WRITE
    );
```

#### GATT Characteristic
Creates a GATT Characteristic to be used with a Service.
```dart
var gattCharacteristic = BleGattCharacteristic(
        uuid: "beb5483e-36e1-4688-b7f5-ea07361b26a8",
        properties: BleGattCharacteristic.PROPERTY_READ | BleGattCharacteristic.PROPERTY_WRITE | BleGattCharacteristic.PROPERTY_NOTIFY,
        permissions: BleGattCharacteristic.PERMISSION_READ | BleGattCharacteristic.PERMISSION_WRITE,
        descriptors: [
          gattDescriptor
        ]
    );
```

#### GATT Service
Creates a Service to be added to the server.
```dart
var gattService = BleGattService(
    uuid: "4fafc201-1fb5-459e-8fcc-c5c9c331914b",
    serviceType: BleGattService.SERVICE_TYPE_PRIMARY,
    characteristics: [
      gattCharacteristic
    ]
);
```

#### Add GATT Service to Server
Adds the created service to the server so clients can actually see it.
```dart
await _bleGattServer.addService(gattService);
```

#### Send notification
The below example sends the seconds of the current time as a single byte as a notification.
```dart
await _bleGattServer.notifyCharacteristic(device, gattCharacteristic, Uint8List.fromList([DateTime.now().second]));
```

### Event handling
Events are handled by the `handleEvents()` method, to which you can add your custom code.
```dart
_bleGattServer.handleEvents(
      onAdvertiseStartFailure: (errorCode) { }, // 
      onAdvertiseStartSuccess: (settingsInEffect) { },
      onConnectionStateChange: (device, status, newState) { },
      onCharacteristicReadRequest: (device, requestId, offset, characteristic) async { },
      onCharacteristicWriteRequest: (device, requestId, characteristic, preparedWrite, responseNeeded, offset, value) async { },
      onDescriptorReadRequest: (device, requestId, offset, descriptor) async { },
      onDescriptorWriteRequest: (device, requestId, descriptor, preparedWrite, responseNeeded, offset, value) async { },
      onExecuteWrite: (device, requestId, execute) { },
      onNotificationSent: (device, status) { },
      onMtuChanged: (device, mtu) { },
    );
```

### Constants
The package defines some constants to check errors or as basic enum replacements.
```dart
// Used as `advertiseMode` in `BleAdvertisementSettings()`
BleAdvertisementSettings.ADVERTISE_MODE_BALANCED
BleAdvertisementSettings.ADVERTISE_MODE_LOW_LATENCY
BleAdvertisementSettings.ADVERTISE_MODE_LOW_POWER

// Used as `txPowerLevel` in `BleAdvertisementSettings()`
BleAdvertisementSettings.ADVERTISE_TX_POWER_HIGH
BleAdvertisementSettings.ADVERTISE_TX_POWER_LOW
BleAdvertisementSettings.ADVERTISE_TX_POWER_MEDIUM
BleAdvertisementSettings.ADVERTISE_TX_POWER_ULTRA_LOW

// Used as `errorCode` in `onAdvertiseStartFailure()`
BleAdvertisement.ADVERTISE_FAILED_ALREADY_STARTED
BleAdvertisement.ADVERTISE_FAILED_DATA_TOO_LARGE
BleAdvertisement.ADVERTISE_FAILED_FEATURE_UNSUPPORTED
BleAdvertisement.ADVERTISE_FAILED_INTERNAL_ERROR
BleAdvertisement.ADVERTISE_FAILED_TOO_MANY_ADVERTISERS

// Used as `newState` in `onConnectionStateChange()`
BleGattServer.DEVICE_STATE_CONNECTED
BleGattServer.DEVICE_STATE_DISCONNECTED

// Used as `status` e.g. in `onConnectionStateChange()` and `sendResponse()`
BleGattServer.GATT_SUCCESS
BleGattServer.GATT_FAILURE

// Used as `serviceType` in `BleGattService()`
BleGattService.SERVICE_TYPE_PRIMARY
BleGattService.SERVICE_TYPE_SECONDARY

// Used as `permissions` in `BleGattCharacteristic()`
BleGattCharacteristic.PERMISSION_READ
BleGattCharacteristic.PERMISSION_READ_ENCRYPTED
BleGattCharacteristic.PERMISSION_READ_ENCRYPTED_MITM
BleGattCharacteristic.PERMISSION_WRITE
BleGattCharacteristic.PERMISSION_WRITE_ENCRYPTED
BleGattCharacteristic.PERMISSION_WRITE_ENCRYPTED_MITM
BleGattCharacteristic.PERMISSION_WRITE_SIGNED
BleGattCharacteristic.PERMISSION_WRITE_SIGNED_MITM

// Used as `properties` in `BleGattCharacteristic()`
BleGattCharacteristic.PROPERTY_BROADCAST
BleGattCharacteristic.PROPERTY_EXTENDED_PROPS
BleGattCharacteristic.PROPERTY_INDICATE
BleGattCharacteristic.PROPERTY_NOTIFY
BleGattCharacteristic.PROPERTY_READ
BleGattCharacteristic.PROPERTY_SIGNED_WRITE
BleGattCharacteristic.PROPERTY_WRITE
BleGattCharacteristic.PROPERTY_WRITE_NO_RESPONSE

// Used as `permissions` in `BleGattDescriptor()`
BleGattDescriptor.PERMISSION_READ
BleGattDescriptor.PERMISSION_READ_ENCRYPTED
BleGattDescriptor.PERMISSION_READ_ENCRYPTED_MITM
BleGattDescriptor.PERMISSION_WRITE
BleGattDescriptor.PERMISSION_WRITE_ENCRYPTED
BleGattDescriptor.PERMISSION_WRITE_ENCRYPTED_MITM
BleGattDescriptor.PERMISSION_WRITE_SIGNED
BleGattDescriptor.PERMISSION_WRITE_SIGNED_MITM

// Can be used to check inside `onDescriptorWriteRequest()` against `value` 
// to see if the client subscribed to notifications
BleGattDescriptor.ENABLE_NOTIFICATION_VALUE
BleGattDescriptor.ENABLE_INDICATION_VALUE
BleGattDescriptor.DISABLE_NOTIFICATION_VALUE
```