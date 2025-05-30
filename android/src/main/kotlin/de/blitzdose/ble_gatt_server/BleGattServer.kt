package de.blitzdose.ble_gatt_server

import android.Manifest
import android.app.Activity
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothGattCharacteristic
import android.bluetooth.BluetoothGattDescriptor
import android.bluetooth.BluetoothGattServer
import android.bluetooth.BluetoothGattServerCallback
import android.bluetooth.BluetoothGattService
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothProfile
import android.bluetooth.BluetoothStatusCodes
import android.bluetooth.le.AdvertiseCallback
import android.bluetooth.le.AdvertiseData
import android.bluetooth.le.AdvertiseSettings
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.ParcelUuid
import androidx.annotation.RequiresApi
import androidx.annotation.RequiresPermission
import io.flutter.plugin.common.MethodChannel
import java.util.UUID
import kotlin.jvm.Throws

class BleGattServer {
    private var context: Context

    private var bluetoothManager: BluetoothManager
    private var bluetoothAdapter: BluetoothAdapter

    private var gattServer: BluetoothGattServer? = null

    private lateinit var channel : MethodChannel

    private var advertiseCallback = object : AdvertiseCallback() {
        override fun onStartSuccess(settingsInEffect: AdvertiseSettings?) {
            super.onStartSuccess(settingsInEffect)
            Handler(Looper.getMainLooper()).post {
                channel.invokeMethod("onAdvertiseStartSuccess", arrayListOf(FlutterAdapter.Advertisement.Settings.serialize(
                    Advertisement.Settings.parse(settingsInEffect))))
            }
        }

        override fun onStartFailure(errorCode: Int) {
            super.onStartFailure(errorCode)
            Handler(Looper.getMainLooper()).post {
                channel.invokeMethod("onAdvertiseStartFailure", arrayListOf(errorCode))
            }
        }
    }

    private var bluetoothGattServerCallback = object : BluetoothGattServerCallback() {
        override fun onConnectionStateChange(
            bleDevice: BluetoothDevice?,
            status: Int,
            newState: Int
        ) {
            super.onConnectionStateChange(bleDevice, status, newState)
            var device = Device.parse(bleDevice)
            Handler(Looper.getMainLooper()).post {
                channel.invokeMethod("onConnectionStateChange", arrayListOf(FlutterAdapter.Device.serialize(device), status, newState))
            }
        }

        @RequiresPermission(Manifest.permission.BLUETOOTH_CONNECT)
        override fun onCharacteristicReadRequest(
            bleDevice: BluetoothDevice?,
            requestId: Int,
            offset: Int,
            bleCharacteristic: BluetoothGattCharacteristic?
        ) {
            super.onCharacteristicReadRequest(bleDevice, requestId, offset, bleCharacteristic)
            var characteristic = GattService.GattCharacteristic.parse(bleCharacteristic)
            var device = Device.parse(bleDevice)

            Handler(Looper.getMainLooper()).post {
                channel.invokeMethod("onCharacteristicReadRequest", arrayListOf(FlutterAdapter.Device.serialize(device), requestId, offset,
                    FlutterAdapter.GattService.GattCharacteristic.serialize(characteristic)))
            }
        }

        @RequiresPermission(Manifest.permission.BLUETOOTH_CONNECT)
        override fun onCharacteristicWriteRequest(
            bleDevice: BluetoothDevice?,
            requestId: Int,
            bleCharacteristic: BluetoothGattCharacteristic?,
            preparedWrite: Boolean,
            responseNeeded: Boolean,
            offset: Int,
            value: ByteArray?
        ) {
            super.onCharacteristicWriteRequest(
                bleDevice,
                requestId,
                bleCharacteristic,
                preparedWrite,
                responseNeeded,
                offset,
                value
            )
            var characteristic = GattService.GattCharacteristic.parse(bleCharacteristic)
            var device = Device.parse(bleDevice)

            Handler(Looper.getMainLooper()).post {
                channel.invokeMethod("onCharacteristicWriteRequest", arrayListOf(
                    FlutterAdapter.Device.serialize(device),
                    requestId,
                    FlutterAdapter.GattService.GattCharacteristic.serialize(characteristic),
                    preparedWrite,
                    responseNeeded,
                    offset,
                    value
                ))
            }
        }

        override fun onDescriptorReadRequest(
            bleDevice: BluetoothDevice?,
            requestId: Int,
            offset: Int,
            bleDescriptor: BluetoothGattDescriptor?
        ) {
            super.onDescriptorReadRequest(bleDevice, requestId, offset, bleDescriptor)
            var device = Device.parse(bleDevice)
            var descriptor = GattService.GattCharacteristic.GattDescriptor.parse(bleDescriptor)

            Handler(Looper.getMainLooper()).post {
                channel.invokeMethod("onDescriptorReadRequest", arrayListOf(
                    FlutterAdapter.Device.serialize(device),
                    requestId,
                    offset,
                    FlutterAdapter.GattService.GattCharacteristic.GattDescriptor.serialize(descriptor)
                ))
            }
        }

        override fun onDescriptorWriteRequest(
            bleDevice: BluetoothDevice?,
            requestId: Int,
            bleDescriptor: BluetoothGattDescriptor?,
            preparedWrite: Boolean,
            responseNeeded: Boolean,
            offset: Int,
            value: ByteArray?
        ) {
            super.onDescriptorWriteRequest(
                bleDevice,
                requestId,
                bleDescriptor,
                preparedWrite,
                responseNeeded,
                offset,
                value
            )
            var device = Device.parse(bleDevice)
            var descriptor = GattService.GattCharacteristic.GattDescriptor.parse(bleDescriptor)

            Handler(Looper.getMainLooper()).post {
                channel.invokeMethod("onDescriptorWriteRequest", arrayListOf(
                    FlutterAdapter.Device.serialize(device),
                    requestId,
                    FlutterAdapter.GattService.GattCharacteristic.GattDescriptor.serialize(descriptor),
                    preparedWrite,
                    responseNeeded,
                    offset,
                    value
                ))
            }
        }

        override fun onExecuteWrite(
            bleDevice: BluetoothDevice?,
            requestId: Int,
            execute: Boolean
        ) {
            super.onExecuteWrite(bleDevice, requestId, execute)
            var device = Device.parse(bleDevice)

            Handler(Looper.getMainLooper()).post {
                channel.invokeMethod("onExecuteWrite", arrayListOf(
                    FlutterAdapter.Device.serialize(device),
                    requestId,
                    execute
                ))
            }
        }

        override fun onNotificationSent(
            bleDevice: BluetoothDevice?,
            status: Int
        ) {
            super.onNotificationSent(bleDevice, status)
            var device = Device.parse(bleDevice)

            Handler(Looper.getMainLooper()).post {
                channel.invokeMethod("onNotificationSent", arrayListOf(
                    FlutterAdapter.Device.serialize(device),
                    status
                ))
            }
        }

        override fun onMtuChanged(
            bleDevice: BluetoothDevice?,
            mtu: Int
        ) {
            super.onMtuChanged(bleDevice, mtu)
            var device = Device.parse(bleDevice)

            Handler(Looper.getMainLooper()).post {
                channel.invokeMethod("onMtuChanged", arrayListOf(
                    FlutterAdapter.Device.serialize(device),
                    mtu
                ))
            }
        }
    }

    constructor(pluginInstance: BleGattServerPlugin, context: Context) {
        this.channel = pluginInstance.channel
        this.context = context
        bluetoothManager = context.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
        bluetoothAdapter = bluetoothManager.adapter
    }

    @RequiresPermission(Manifest.permission.BLUETOOTH_CONNECT)
    fun enableBluetooth(activity: Activity, REQUEST_ENABLE_BT: Int) {
        val intent = Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE)
        activity.startActivityForResult(intent, REQUEST_ENABLE_BT)
    }

    fun isBluetoothEnabled(): Boolean {
        return bluetoothAdapter.isEnabled
    }

    @RequiresPermission(Manifest.permission.BLUETOOTH_CONNECT)
    fun addService(gattService: GattService) {
        if (gattServer == null) throw BleGattServerException.ServerNotRunningException()
        gattServer?.addService(gattService.gattService)
    }

    @Suppress("DEPRECATION")
    @RequiresPermission(Manifest.permission.BLUETOOTH_CONNECT)
    @Throws(BleGattServerException::class)
    fun notifyCharacteristic(device: Device, gattCharacteristic: GattService.GattCharacteristic, value: ByteArray) {
        var bleDevice: BluetoothDevice? = bluetoothManager.getConnectedDevices(BluetoothProfile.GATT).find { it.address == device.address }
        if (bleDevice == null) {
            throw BleGattServerException.DeviceNotConnectedException("Device with address \"${device.address}\" is not connected!")
        }

        if (gattServer == null) throw BleGattServerException.ServerNotRunningException()

        val bleCharacteristic = gattServer?.services
            ?.flatMap { it.characteristics }
            ?.firstOrNull { it.uuid == gattCharacteristic.gattCharacteristic.uuid }

        if (bleCharacteristic == null) {
            throw BleGattServerException.CharacteristicNotDefinedException("Characteristic with UUID \"${gattCharacteristic.gattCharacteristic.uuid}\" is unknown to the server")
        }
        var notificationSent = true
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            notificationSent = notifyCharacteristicTiramisu(bleDevice, bleCharacteristic, value)
        } else {
            bleCharacteristic.value = value
            notificationSent = gattServer?.notifyCharacteristicChanged(bleDevice, bleCharacteristic, false) == true
        }
        if (!notificationSent) {
            throw BleGattServerException.NotificationNotSentException()
        }
    }

    @RequiresApi(Build.VERSION_CODES.TIRAMISU)
    @RequiresPermission(Manifest.permission.BLUETOOTH_CONNECT)
    fun notifyCharacteristicTiramisu(device: BluetoothDevice, bleCharacteristic: BluetoothGattCharacteristic, value: ByteArray): Boolean {
        return gattServer?.notifyCharacteristicChanged(device, bleCharacteristic, false, value) == BluetoothStatusCodes.SUCCESS
    }

    @RequiresPermission(Manifest.permission.BLUETOOTH_CONNECT)
    fun startServer() {
        gattServer = bluetoothManager.openGattServer(context, bluetoothGattServerCallback)
    }

    @RequiresPermission(Manifest.permission.BLUETOOTH_CONNECT)
    fun stopServer() {
        if (gattServer == null) throw BleGattServerException.ServerNotRunningException()
        gattServer?.close()
    }

    @RequiresPermission(Manifest.permission.BLUETOOTH_CONNECT)
    @Throws(BleGattServerException::class)
    fun sendResponse(device: Device, requestId: Int, status: Int, offset: Int, value: ByteArray?) {
        var bleDevice = bluetoothManager.getConnectedDevices(BluetoothProfile.GATT).find { it.address == device.address }
        if (bleDevice == null) {
            throw BleGattServerException.DeviceNotConnectedException("Device with address \"${device.address}\" is not connected!")
        }
        if (gattServer == null) throw BleGattServerException.ServerNotRunningException()
        var responseSent: Boolean = gattServer?.sendResponse(bleDevice, requestId, status, offset, value) == true
        if (!responseSent) {
            throw BleGattServerException.ResponseNotSentException("Response to request ID \"$requestId\" could not be sent")
        }
    }

    @RequiresPermission(allOf = [Manifest.permission.BLUETOOTH_ADVERTISE, Manifest.permission.BLUETOOTH_CONNECT])
    fun startAdvertising(advertisement: Advertisement) {
        for (i in 1..5) { // Necessary when just turning on Bluetooth, because it does not like to grab the name right away
            if (advertisement.data.name != null && advertisement.data.name != bluetoothAdapter.name) {
                bluetoothAdapter.name = advertisement.data.name
                Thread.sleep(1000L)
            } else {
                break
            }
        }
        bluetoothAdapter.bluetoothLeAdvertiser.startAdvertising(
            advertisement.settings.advertiseSettings,
            advertisement.data.advertiseData,
            advertisement.data.scanResponseData,
            advertiseCallback
        )
    }

    @RequiresPermission(Manifest.permission.BLUETOOTH_ADVERTISE)
    fun stopAdvertising() {
        bluetoothAdapter.bluetoothLeAdvertiser.stopAdvertising(advertiseCallback)
    }

    class Device {
        val address: String

        constructor(
            address: String
        ) {
            this.address = address
        }

        companion object {
            fun parse(device: BluetoothDevice?): Device? {
                if (device == null) return null
                return Device(device.address)
            }
        }
    }

    class GattService {

        var gattService: BluetoothGattService
        var gattCharacteristics: ArrayList<GattCharacteristic> = ArrayList()

        val uuid: UUID get() = gattService.uuid
        val type: Int get() = gattService.type

        constructor(
            uuid: UUID,
            serviceType: Int
        ) {
            gattService = BluetoothGattService(uuid, serviceType)
        }

        fun addCharacteristic(gattCharacteristic: GattCharacteristic) {
            gattService.addCharacteristic(gattCharacteristic.gattCharacteristic)
            gattCharacteristics.add(gattCharacteristic)
        }

        fun addService(gattService: GattService) {
            this.gattService.addService(BluetoothGattService(gattService.uuid, gattService.type))
        }

        class GattCharacteristic {

            var gattCharacteristic: BluetoothGattCharacteristic

            constructor(
                uuid: UUID,
                properties: Int,
                permissions: Int
            ) {
                gattCharacteristic = BluetoothGattCharacteristic(uuid, properties, permissions)
            }

            fun addDescriptor(gattDescriptor: GattDescriptor) {
                gattCharacteristic.addDescriptor(gattDescriptor.gattDescriptor)
            }

            companion object {
                fun parse(characteristic: BluetoothGattCharacteristic?): GattCharacteristic? {
                    if (characteristic == null) return null
                    var gattCharacteristic =  GattCharacteristic(
                        uuid = characteristic.uuid,
                        properties = characteristic.properties,
                        permissions = characteristic.permissions
                    )
                    for (descriptor: BluetoothGattDescriptor in characteristic.descriptors) {
                        var descriptor = GattDescriptor.parse(descriptor)
                        if (descriptor != null) gattCharacteristic.addDescriptor(descriptor)
                    }
                    return gattCharacteristic
                }
            }

            class GattDescriptor {
                var gattDescriptor: BluetoothGattDescriptor

                constructor(
                    uuid: UUID,
                    permissions: Int
                ) {
                    gattDescriptor = BluetoothGattDescriptor(uuid, permissions)
                }

                companion object {
                    fun parse(descriptor: BluetoothGattDescriptor?): GattDescriptor? {
                        if (descriptor == null) return null
                        return GattDescriptor(
                            uuid = descriptor.uuid,
                            permissions = descriptor.permissions
                        )
                    }
                }
            }
        }
    }

    class Advertisement(val data: Data, val settings: Settings) {

        class Data {
            internal var advertiseData: AdvertiseData? = null
            internal var scanResponseData: AdvertiseData? = null
            internal var name: String? = null

            @RequiresPermission(Manifest.permission.BLUETOOTH_CONNECT)
            fun setAdvertiseData(
                localName: String? = null,
                includeTxPower: Boolean = false,
                manufacturerDataList: List<ManufacturerData> = ArrayList(),
                serviceUUIDList: List<UUID> = ArrayList(),
                serviceDataList: List<ServiceData> = ArrayList(),
            ) {
                addData(localName, includeTxPower, manufacturerDataList, serviceUUIDList, serviceDataList, false)
            }

            fun setScanResponseData(
                localName: String? = null,
                includeTxPower: Boolean = false,
                manufacturerDataList: List<ManufacturerData> = ArrayList(),
                serviceUUIDList: List<UUID> = ArrayList(),
                serviceDataList: List<ServiceData> = ArrayList(),
            ) {
                addData(localName, includeTxPower, manufacturerDataList, serviceUUIDList, serviceDataList, true)
            }

            private fun addData(
                localName: String? = null,
                includeTxPower: Boolean = false,
                manufacturerDataList: List<ManufacturerData> = ArrayList(),
                serviceUUIDList: List<UUID> = ArrayList(),
                serviceDataList: List<ServiceData> = ArrayList(),
                isScanResponseData: Boolean
            ) {
                if (localName != null) {
                    name = localName
                }
                var builder = AdvertiseData.Builder()
                builder.setIncludeDeviceName(localName != null)
                builder.setIncludeTxPowerLevel(includeTxPower == true)
                for (manufacturerData: ManufacturerData in manufacturerDataList) {
                    builder.addManufacturerData(manufacturerData.manufacturerId, manufacturerData.data)
                }
                for (serviceUUID: UUID in serviceUUIDList) {
                    builder.addServiceUuid(ParcelUuid(serviceUUID))
                }
                for (serviceData: ServiceData in serviceDataList) {
                    builder.addServiceData(ParcelUuid(serviceData.uuid), serviceData.data)
                }
                if (isScanResponseData) {
                    scanResponseData = builder.build()
                } else {
                    advertiseData = builder.build()
                }
            }

            class ManufacturerData(var manufacturerId: Int, var data: ByteArray)
            class ServiceData(var uuid: UUID, var data: ByteArray)
        }

        class Settings {
            var advertiseSettings: AdvertiseSettings

            constructor(
                advertiseMode: Int = AdvertiseSettings.ADVERTISE_MODE_BALANCED,
                timeout: Int = 0,
                connectable: Boolean = true,
                discoverable: Boolean = true,
                txPowerLevel: Int = AdvertiseSettings.ADVERTISE_TX_POWER_HIGH
            ) {
                var builder = AdvertiseSettings.Builder()
                builder.setAdvertiseMode(advertiseMode)
                builder.setTimeout(timeout)
                builder.setConnectable(connectable)
                if (Build.VERSION.SDK_INT >= 34) {
                    builder.setDiscoverable(discoverable)
                }
                builder.setTxPowerLevel(txPowerLevel)

                advertiseSettings = builder.build()
            }

            companion object {
                fun parse(advertiseSettings: AdvertiseSettings?): Settings? {
                    if (advertiseSettings == null) return null
                    var settings = Settings()
                    settings.advertiseSettings = advertiseSettings
                    return settings
                }
            }
        }
    }

}