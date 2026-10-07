package io.github.chinatsu033.canto

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.media.MediaMetadata
import android.media.Rating
import android.media.session.MediaController
import android.media.session.MediaSessionManager
import android.media.session.PlaybackState
import android.os.SystemClock
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream

class MainActivity : FlutterActivity() {
    private var artKey: String? = null
    private var artBytes: ByteArray? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "canto/now_playing")
            .setMethodCallHandler { call, result ->
                try {
                    when (call.method) {
                        "hasPermission" -> result.success(hasAccess())
                        "requestPermission" -> {
                            startActivity(Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)
                                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
                            result.success(null)
                        }
                        "get" -> result.success(snapshot())
                        "playPause" -> result.success(playPause())
                        "favorite" -> result.success(favorite())
                        else -> result.notImplemented()
                    }
                } catch (e: SecurityException) {
                    result.success(null)
                }
            }
    }

    private fun hasAccess(): Boolean =
        (Settings.Secure.getString(contentResolver, "enabled_notification_listeners") ?: "")
            .split(":").any { ComponentName.unflattenFromString(it)?.packageName == packageName }

    private fun controller(): MediaController? {
        if (!hasAccess()) return null
        val msm = getSystemService(Context.MEDIA_SESSION_SERVICE) as MediaSessionManager
        val list = msm.getActiveSessions(ComponentName(this, MediaListener::class.java))
        return list.firstOrNull { it.playbackState?.state == PlaybackState.STATE_PLAYING }
            ?: list.firstOrNull { it.metadata != null }
    }

    private fun favoriteAction(c: MediaController): PlaybackState.CustomAction? {
        val words = listOf("favorite", "favourite", "like", "love", "heart", "collect",
            "save", "library", "star", "收藏", "喜欢", "喜歡", "红心")
        return c.playbackState?.customActions?.firstOrNull { a ->
            val s = (a.action + " " + a.name).lowercase()
            words.any { s.contains(it) } && !s.contains("dislike") && !s.contains("unlike")
        }
    }

    private fun canRate(c: MediaController): Boolean {
        val actions = c.playbackState?.actions ?: 0L
        return actions and PlaybackState.ACTION_SET_RATING != 0L &&
            (c.ratingType == Rating.RATING_HEART || c.ratingType == Rating.RATING_THUMB_UP_DOWN)
    }

    private fun snapshot(): Map<String, Any?>? {
        val c = controller() ?: return null
        val md = c.metadata ?: return null
        val st = c.playbackState
        val title = md.getString(MediaMetadata.METADATA_KEY_TITLE)
            ?: md.getString(MediaMetadata.METADATA_KEY_DISPLAY_TITLE) ?: return null
        val artist = md.getString(MediaMetadata.METADATA_KEY_ARTIST)
            ?: md.getString(MediaMetadata.METADATA_KEY_ALBUM_ARTIST) ?: ""
        val album = md.getString(MediaMetadata.METADATA_KEY_ALBUM) ?: ""
        val pkg = c.packageName
        val key = "$pkg|$title|$artist|$album"
        if (key != artKey) {
            artKey = key
            val bmp = md.getBitmap(MediaMetadata.METADATA_KEY_ALBUM_ART)
                ?: md.getBitmap(MediaMetadata.METADATA_KEY_ART)
                ?: md.getBitmap(MediaMetadata.METADATA_KEY_DISPLAY_ICON)
            artBytes = bmp?.let { encode(it) }
        }
        val now = System.currentTimeMillis()
        val posAt = if (st != null && st.lastPositionUpdateTime > 0)
            now - (SystemClock.elapsedRealtime() - st.lastPositionUpdateTime) else now
        val label = try {
            packageManager.getApplicationLabel(packageManager.getApplicationInfo(pkg, 0)).toString()
        } catch (e: Exception) { pkg }
        val queue = try { c.queue } catch (e: Exception) { null }
        val activeId = st?.activeQueueItemId ?: -1L
        val actions = st?.actions ?: 0L
        return mapOf(
            "title" to title,
            "artist" to artist,
            "album" to album,
            "durationMs" to md.getLong(MediaMetadata.METADATA_KEY_DURATION),
            "positionMs" to (st?.position ?: 0L),
            "positionAtMs" to posAt,
            "playing" to (st?.state == PlaybackState.STATE_PLAYING),
            "rate" to (st?.playbackSpeed?.toDouble() ?: 1.0),
            "artwork" to artBytes,
            "sourceApp" to pkg,
            "sourceName" to label,
            "canPlayPause" to (actions and (PlaybackState.ACTION_PLAY_PAUSE or
                PlaybackState.ACTION_PLAY or PlaybackState.ACTION_PAUSE) != 0L),
            "canFavorite" to (favoriteAction(c) != null || canRate(c)),
            "queue" to queue?.takeIf { it.isNotEmpty() }?.map { q ->
                mapOf(
                    "title" to (q.description.title?.toString() ?: ""),
                    "artist" to q.description.subtitle?.toString(),
                    "current" to (q.queueId == activeId),
                )
            },
        )
    }

    private fun encode(b: Bitmap): ByteArray {
        val max = 512
        val s = if (b.width > max || b.height > max) {
            val f = max.toFloat() / maxOf(b.width, b.height)
            Bitmap.createScaledBitmap(b, (b.width * f).toInt(), (b.height * f).toInt(), true)
        } else b
        val out = ByteArrayOutputStream()
        s.compress(Bitmap.CompressFormat.JPEG, 90, out)
        return out.toByteArray()
    }

    private fun playPause(): String {
        val c = controller() ?: return "unsupported"
        val playing = c.playbackState?.state == PlaybackState.STATE_PLAYING
        if (playing) c.transportControls.pause() else c.transportControls.play()
        return "ok"
    }

    private fun favorite(): String {
        val c = controller() ?: return "unsupported"
        favoriteAction(c)?.let {
            c.transportControls.sendCustomAction(it, it.extras)
            return "ok"
        }
        if (canRate(c)) {
            val r = if (c.ratingType == Rating.RATING_HEART) Rating.newHeartRating(true)
                else Rating.newThumbRating(true)
            c.transportControls.setRating(r)
            return "ok"
        }
        return "unsupported"
    }
}
