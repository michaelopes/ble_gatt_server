package de.blitzdose.ble_gatt_server

import android.app.Activity
import android.content.Context
import android.content.Intent
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener


/** BleGattServerPlugin */
class BleGattServerPlugin: FlutterPlugin, MethodCallHandler, ActivityAware, ActivityResultListener {
  private var activity: Activity? = null
  private lateinit var context: Context

  lateinit var channel : MethodChannel
  private lateinit var gattServer: BleGattServer

  private var pendingResult: Result? = null

  private val REQUEST_ENABLE_BT = 1

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "de.blitzdose.ble_gatt_server")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
    gattServer = BleGattServer(this, context)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    val args = call.arguments as? Map<String, Any>
    try {
      when (call.method) {
        "isBluetoothEnabled" -> {
          result.success(gattServer.isBluetoothEnabled())
        }
        "enableBluetooth" -> {
          if (activity == null) {
            result.error("NO_ACTIVITY", "Plugin not attached to an activity. This is to 99% a bug. Please report to ble_gatt_server", null)
            return
          }
          pendingResult = result

          gattServer.enableBluetooth(activity!!, REQUEST_ENABLE_BT)
        }
        "startAdvertising" -> {
          val advertisement = FlutterAdapter.Advertisement.parse(args?.get("advertisement") as Map<String, Any>)
          gattServer.startAdvertising(advertisement)
          result.success(null)
        }
        "stopAdvertising" -> {
          gattServer.stopAdvertising()
          result.success(null)
        }
        "addService" -> {
          val service = FlutterAdapter.GattService.parse(args?.get("service") as Map<String, Any>)
          gattServer.addService(service)
          result.success(null)
        }
        "startServer" -> {
          gattServer.startServer()
          result.success(null)
        }
        "stopServer" -> {
          gattServer.stopServer()
          result.success(null)
        }
        "sendResponse" -> {
          val device = FlutterAdapter.Device.parse(args?.get("device") as Map<String, Any>)
          val requestId = args?.get("requestId") as Int
          val status = args?.get("status") as Int
          val offset = args?.get("offset") as Int
          val value = args?.get("value") as ByteArray?

          gattServer.sendResponse(device, requestId, status, offset, value)
          result.success(null)
        }
        "notifyCharacteristic" -> {
          val device = FlutterAdapter.Device.parse(args?.get("device") as Map<String, Any>)
          val characteristic = FlutterAdapter.GattService.GattCharacteristic.parse(args?.get("characteristic") as Map<String, Any>)
          val value = args?.get("value") as ByteArray

          gattServer.notifyCharacteristic(device, characteristic, value)
          result.success(null)
        }
        else -> result.notImplemented()
      }
    } catch (e: BleGattServerException) {
      result.error(e.errorCode.toString(), e.message, null)
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
    binding.addActivityResultListener(this)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivity() {
    activity = null
  }

  override fun onActivityResult(
    requestCode: Int,
    resultCode: Int,
    data: Intent?
  ): Boolean {
    if (requestCode == REQUEST_ENABLE_BT) {
      if (resultCode == Activity.RESULT_OK) {
        pendingResult?.success(true)
      } else {
        pendingResult?.success(false)
      }
      pendingResult = null
      return true
    }
    return false
  }
}