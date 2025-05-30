package de.blitzdose.ble_gatt_server

abstract class BleGattServerException(
    val errorCode: Int,
    message: String
) : Exception(message) {

    class DeviceNotConnectedException(
        message: String = "Device is not connected"
    ) : BleGattServerException(1, message)

    class CharacteristicNotDefinedException(
        message: String = "Characteristic is unknown to the server"
    ) : BleGattServerException(2, message)

    class ResponseNotSentException(
        message: String = "Response could not be sent"
    ) : BleGattServerException(3, message)

    class NotificationNotSentException(
        message: String = "Notification could not be sent"
    ) : BleGattServerException(4, message)

    class ServerNotRunningException(
        message: String = "GATT Server is not running"
    ) : BleGattServerException(5, message)
}