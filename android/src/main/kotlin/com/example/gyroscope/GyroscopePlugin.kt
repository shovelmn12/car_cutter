package com.example.gyroscope

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** GyroscopePlugin */
class GyroscopePlugin : FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    private var sensorManager: SensorManager? = null

    private val sensorListener = AccelerometerEventListener { azimuth, pitch, roll ->
        channel.invokeMethod(
            "data",
            hashMapOf(
                "azimuth" to azimuth,
                "pitch" to pitch,
                "roll" to roll,
            ),
        )
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "gyroscope")
        channel.setMethodCallHandler(this)
        flutterPluginBinding.applicationContext

        sensorManager =
            flutterPluginBinding.applicationContext.getSystemService(Context.SENSOR_SERVICE) as SensorManager
    }

    override fun onMethodCall(call: MethodCall, result: Result) = when (call.method) {
        "subscribe" -> {
            if (call.arguments is Double) {
                result.success(subscribe((call.arguments as Double).toInt()))
            } else {
                result.error(
                    "bad_argument",
                    "Please provider sample rate as Double in us",
                    null
                )
            }
        }

        "unsubscribe" -> result.success(unsubscribe())

        else -> result.notImplemented()
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        sensorManager = null
    }

    private fun subscribe(us: Int): Boolean = sensorManager?.run {
        getDefaultSensor(Sensor.TYPE_ACCELEROMETER)?.run {
            registerListener(sensorListener, this, us)
        }

        getDefaultSensor(Sensor.TYPE_MAGNETIC_FIELD)?.run {
            registerListener(sensorListener, this, us)
        }

        true
    } ?: false

    private fun unsubscribe(): Boolean = sensorManager?.run {
        getDefaultSensor(Sensor.TYPE_ACCELEROMETER)?.run {
            unregisterListener(sensorListener, this)
        }

        getDefaultSensor(Sensor.TYPE_MAGNETIC_FIELD)?.run {
            unregisterListener(sensorListener, this)
        }

        true
    } ?: false

    class AccelerometerEventListener(
        private val onData: (x: Double, y: Double, z: Double) -> Unit,
    ) : SensorEventListener {

        private val accelerometerReading = FloatArray(3)
        private val magnetometerReading = FloatArray(3)
        private val rotationMatrix = FloatArray(9)
        private val orientationAngles = FloatArray(3)

        override fun onSensorChanged(event: SensorEvent?) {
            when (event?.sensor?.type) {
                Sensor.TYPE_ACCELEROMETER -> System.arraycopy(
                    event.values,
                    0,
                    accelerometerReading,
                    0,
                    accelerometerReading.size
                )

                Sensor.TYPE_MAGNETIC_FIELD -> System.arraycopy(
                    event.values,
                    0,
                    magnetometerReading,
                    0,
                    magnetometerReading.size
                )
            }

            SensorManager.getRotationMatrix(
                rotationMatrix,
                null,
                accelerometerReading,
                magnetometerReading
            )

            SensorManager.getOrientation(rotationMatrix, orientationAngles)

            // Convert radians to degrees
            val azimuthDegrees = Math.toDegrees(orientationAngles[0].toDouble())
            val pitchDegrees = Math.toDegrees(orientationAngles[1].toDouble())
            val rollDegrees = Math.toDegrees(orientationAngles[2].toDouble())

            onData(azimuthDegrees, pitchDegrees, rollDegrees)
        }

        override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
        }
    }
}
