package com.example.mobile_app

import android.Manifest
import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
	private val channelId = "plantlens_alerts"
	private val channelName = "PlantLens alerts"
	private val methodChannelName = "plantlens_notifications"

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, methodChannelName).setMethodCallHandler { call, result ->
			when (call.method) {
				"initialize" -> {
					ensureNotificationChannel()
					requestNotificationPermissionIfNeeded()
					result.success(canPostNotifications())
				}
				"showPrediction" -> {
					val title = call.argument<String>("title") ?: "PlantLens alert"
					val body = call.argument<String>("body") ?: ""
					showNotification(title, body)
					result.success(null)
				}
				"scheduleFollowUp" -> {
					val title = call.argument<String>("title") ?: "PlantLens follow-up"
					val body = call.argument<String>("body") ?: "Check your plant and capture a new scan."
					val timestampMs = call.argument<Long>("timestampMs")

					if (timestampMs == null) {
						result.error("invalid_args", "timestampMs is required", null)
					} else {
						scheduleNotification(title, body, timestampMs)
						result.success(null)
					}
				}
				else -> result.notImplemented()
			}
		}
	}

	private fun ensureNotificationChannel() {
		if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
			return
		}

		val channel = NotificationChannel(
			channelId,
			channelName,
			NotificationManager.IMPORTANCE_HIGH,
		).apply {
			description = "Scan results, warnings, and app alerts"
		}

		val manager = getSystemService(NotificationManager::class.java)
		manager.createNotificationChannel(channel)
	}

	private fun requestNotificationPermissionIfNeeded() {
		if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
			return
		}

		if (ContextCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED) {
			ActivityCompat.requestPermissions(
				this,
				arrayOf(Manifest.permission.POST_NOTIFICATIONS),
				1001,
			)
		}
	}

	private fun canPostNotifications(): Boolean {
		return Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU ||
			ContextCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED
	}

	private fun showNotification(title: String, body: String) {
		if (!canPostNotifications()) {
			return
		}

		ensureNotificationChannel()

		val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
			?.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)

		val pendingIntent = PendingIntent.getActivity(
			this,
			0,
			launchIntent,
			PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
		)

		val notification = NotificationCompat.Builder(this, channelId)
			.setSmallIcon(R.mipmap.ic_launcher)
			.setContentTitle(title)
			.setContentText(body)
			.setStyle(NotificationCompat.BigTextStyle().bigText(body))
			.setPriority(NotificationCompat.PRIORITY_HIGH)
			.setAutoCancel(true)
			.setContentIntent(pendingIntent)
			.build()

		NotificationManagerCompat.from(this).notify(System.currentTimeMillis().toInt(), notification)
	}

	private fun scheduleNotification(title: String, body: String, timestampMs: Long) {
		val alarmManager = getSystemService(AlarmManager::class.java)
		val intent = Intent(this, ReminderReceiver::class.java).apply {
			putExtra("title", title)
			putExtra("body", body)
		}

		val requestCode = (System.currentTimeMillis() % Int.MAX_VALUE).toInt()
		val pendingIntent = PendingIntent.getBroadcast(
			this,
			requestCode,
			intent,
			PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
		)

		when {
			Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && !alarmManager.canScheduleExactAlarms() -> {
				alarmManager.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, timestampMs, pendingIntent)
			}
			Build.VERSION.SDK_INT >= Build.VERSION_CODES.M -> {
				alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, timestampMs, pendingIntent)
			}
			else -> {
				alarmManager.setExact(AlarmManager.RTC_WAKEUP, timestampMs, pendingIntent)
			}
		}
	}
}
