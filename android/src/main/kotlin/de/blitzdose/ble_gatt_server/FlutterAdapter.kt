package de.blitzdose.ble_gatt_server

import android.Manifest
import android.bluetooth.BluetoothGattDescriptor
import android.os.Build
import androidx.annotation.RequiresPermission
import java.util.UUID

class FlutterAdapter {

    class Device {
        companion object {
            fun serialize(device: BleGattServer.Device?): Map<String, Any>? {
                if (device == null) return null
                return mapOf(
                    "address" to device.address
                )
            }

            fun parse(serialized: Map<String, Any>): BleGattServer.Device {
                return BleGattServer.Device(serialized["address"] as String)
            }
        }
    }

    class GattService {
        companion object {
            fun parse(serialized: Map<String, Any>): BleGattServer.GattService {
                var service = BleGattServer.GattService(
                    uuid = UUID.fromString(serialized["uuid"] as String),
                    serviceType = serialized["serviceType"] as Int
                )
                for (characteristic: Map<String, Any> in serialized["characteristics"] as List<Map<String, Any>>) {
                    service.addCharacteristic(GattCharacteristic.parse(characteristic))
                }
                for (subservice: Map<String, Any> in serialized["services"] as List<Map<String, Any>>) {
                    service.addService(parse(subservice))
                }
                return service
            }
        }

        class GattCharacteristic {
            companion object {
                fun serialize(gattCharacteristic: BleGattServer.GattService.GattCharacteristic?): Map<String, Any>? {
                    if (gattCharacteristic == null) return null
                    return mapOf(
                        "uuid" to gattCharacteristic.gattCharacteristic.uuid.toString(),
                        "properties" to gattCharacteristic.gattCharacteristic.permissions,
                        "permissions" to gattCharacteristic.gattCharacteristic.permissions,
                        "descriptors" to gattCharacteristic.gattCharacteristic.descriptors.map { GattDescriptor.serialize(
                            BleGattServer.GattService.GattCharacteristic.GattDescriptor.parse(it)) }.toList()
                    )
                }

                fun parse(serialized: Map<String, Any>): BleGattServer.GattService.GattCharacteristic {
                    var characteristic = BleGattServer.GattService.GattCharacteristic(
                        uuid = UUID.fromString(serialized["uuid"] as String),
                        properties = serialized["properties"] as Int,
                        permissions = serialized["permissions"] as Int
                    )
                    for (descriptor: Map<String, Any> in serialized["descriptors"] as List<Map<String, Any>>) {
                        characteristic.addDescriptor(GattDescriptor.parse(descriptor))
                    }
                    return characteristic
                }
            }

            class GattDescriptor {
                companion object {
                    fun serialize(gattDescriptor: BleGattServer.GattService.GattCharacteristic.GattDescriptor?): Map<String, Any>? {
                        if (gattDescriptor == null) return null
                        return mapOf(
                            "uuid" to gattDescriptor.gattDescriptor.uuid.toString(),
                            "permissions" to gattDescriptor.gattDescriptor.permissions
                        )
                    }

                    fun parse(serialized: Map<String, Any>): BleGattServer.GattService.GattCharacteristic.GattDescriptor {
                        return BleGattServer.GattService.GattCharacteristic.GattDescriptor(
                            uuid = UUID.fromString(serialized["uuid"] as String),
                            permissions = serialized["permissions"] as Int
                        )
                    }
                }
            }
        }
    }

    class Advertisement {
        companion object {
            @RequiresPermission(Manifest.permission.BLUETOOTH_CONNECT)
            fun parse(serialized: Map<String, Any>): BleGattServer.Advertisement {
                var serializedDataContainer: Map<String, Any> = serialized["dataContainer"] as Map<String, Any>
                var serializedSettings: Map<String, Any> = serialized["settings"] as Map<String, Any>

                return BleGattServer.Advertisement(
                    data = DataContainer.parse(serializedDataContainer),
                    settings = Settings.parse(serializedSettings)
                )
            }
        }

        class DataContainer {
            companion object {
                @RequiresPermission(Manifest.permission.BLUETOOTH_CONNECT)
                fun parse(serialized: Map<String, Any>): BleGattServer.Advertisement.Data {
                    var data = BleGattServer.Advertisement.Data()
                    if (serialized["advertisementData"] != null) {
                        var serializedAdvertiseData = serialized["advertisementData"] as Map<String, Any>
                        data.setAdvertiseData(
                            localName = serializedAdvertiseData["localName"] as String?,
                            includeTxPower = serializedAdvertiseData["includeTxPower"] as Boolean,
                            manufacturerDataList = (serializedAdvertiseData["manufacturerDataList"] as List<Map<String, Any>>).map { ManufacturerData.parse(it) },
                            serviceUUIDList = (serializedAdvertiseData["serviceUUIDList"] as List<String>).map { UUID.fromString(it) },
                            serviceDataList = (serializedAdvertiseData["serviceDataList"] as List<Map<String, Any>>).map { ServiceData.parse(it) }
                        )
                    }
                    if (serialized["scanResponseData"] != null) {
                        var serializedScanResponseData = serialized["scanResponseData"] as Map<String, Any>
                        data.setScanResponseData(
                            localName = serializedScanResponseData["localName"] as String?,
                            includeTxPower = serializedScanResponseData["includeTxPower"] as Boolean,
                            manufacturerDataList = (serializedScanResponseData["manufacturerDataList"] as List<Map<String, Any>>).map { ManufacturerData.parse(it) },
                            serviceUUIDList = (serializedScanResponseData["serviceUUIDList"] as List<String>).map { UUID.fromString(it) },
                            serviceDataList = (serializedScanResponseData["serviceDataList"] as List<Map<String, Any>>).map { ServiceData.parse(it) }
                        )
                    }
                    return data
                }
            }

            class ManufacturerData {
                companion object {
                    fun parse(serialized: Map<String, Any>): BleGattServer.Advertisement.Data.ManufacturerData {
                        return BleGattServer.Advertisement.Data.ManufacturerData(
                            manufacturerId = serialized["manufacturerId"] as Int,
                            data = serialized["data"] as ByteArray
                        )
                    }
                }
            }

            class ServiceData {
                companion object {
                    fun parse(serialized: Map<String, Any>): BleGattServer.Advertisement.Data.ServiceData {
                        return BleGattServer.Advertisement.Data.ServiceData(
                            uuid = UUID.fromString(serialized["uuid"] as String),
                            data = serialized["data"] as ByteArray
                        )
                    }
                }
            }
        }

        class Settings {
            companion object {
                fun parse(serialized: Map<String, Any>): BleGattServer.Advertisement.Settings {
                    return BleGattServer.Advertisement.Settings(
                        advertiseMode = serialized["advertiseMode"] as Int,
                        timeout = serialized["timeout"] as Int,
                        connectable = serialized["connectable"] as Boolean,
                        discoverable = serialized["discoverable"] as Boolean,
                        txPowerLevel = serialized["txPowerLevel"] as Int
                    )
                }

                fun serialize(settings: BleGattServer.Advertisement.Settings?): Map<String, Any>? {
                    if (settings == null) return null
                    var map: MutableMap<String, Any> = mutableMapOf(
                        "advertiseMode" to settings.advertiseSettings.mode,
                        "timeout" to settings.advertiseSettings.timeout,
                        "connectable" to settings.advertiseSettings.isConnectable,
                        "discoverable" to false,
                        "txPowerLevel" to settings.advertiseSettings.txPowerLevel
                    )
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                        map["discoverable"] = settings.advertiseSettings.isDiscoverable
                    }
                    return map
                }
            }
        }
    }
}