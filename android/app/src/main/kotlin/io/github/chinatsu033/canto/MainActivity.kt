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
                        "seek" -> result.success(seek((call.argument<Number>("positionMs") ?: 0).toLong()))
                        "goToQueueItem" -> result.success(goTo(call.argument<String>("id")?.toLongOrNull(),
                            (call.argument<Number>("offset") ?: 0).toInt()))
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

    // Heuristic match on custom action id + label. Covers e.g. Spotify
    // ("Add to Liked Songs"/ADD_TO_COLLECTION), NetEase/QQ/Kugou/Kuwo
    // ("收藏", "喜欢", "我喜欢", "红心"), YouTube Music ("Like", thumbs up).
    private val favWords = listOf("favorite", "favourite", "like", "love", "heart", "collect",
        "save", "library", "add_to", "add to", "addto", "thumb_up", "thumbs_up", "thumbup", "star",
        "收藏", "喜欢", "喜歡", "红心", "紅心", "我喜", "加心")
    private val favExclude = listOf("dislike", "unlike", "remove", "unfav", "unsave", "un_like", "thumb_down",
        "thumbs_down", "shuffle", "repeat", "取消", "移除", "不喜欢", "speed", "playlist_add", "queue")

    private fun favoriteAction(c: MediaController): PlaybackState.CustomAction? {
        return c.playbackState?.customActions?.firstOrNull { a ->
            val s = (a.action + " " + a.name).lowercase()
            favWords.any { s.contains(it) } && favExclude.none { s.contains(it) }
        }
    }

    private fun canRate(c: MediaController): Boolean =
        c.ratingType == Rating.RATING_HEART || c.ratingType == Rating.RATING_THUMB_UP_DOWN ||
            c.ratingType == Rating.RATING_5_STARS || c.ratingType == Rating.RATING_3_STARS ||
            c.ratingType == Rating.RATING_4_STARS

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
            "canSeek" to (actions and PlaybackState.ACTION_SEEK_TO != 0L),
            "canGoToQueueItem" to (!queue.isNullOrEmpty() && (actions and (PlaybackState.ACTION_SKIP_TO_QUEUE_ITEM or
                PlaybackState.ACTION_SKIP_TO_NEXT or PlaybackState.ACTION_SKIP_TO_PREVIOUS) != 0L)),
            "customActions" to (st?.customActions?.map { "${it.name} [${it.action}]" } ?: emptyList<String>()),
            "ratingType" to c.ratingType,
            "queue" to queue?.takeIf { it.isNotEmpty() }?.map { q ->
                mapOf(
                    "title" to (q.description.title?.toString() ?: ""),
                    "artist" to q.description.subtitle?.toString(),
                    "current" to (q.queueId == activeId),
                    "id" to q.queueId.toString(),
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

    private fun seek(ms: Long): String {
        val c = controller() ?: return "unsupported"
        if ((c.playbackState?.actions ?: 0L) and PlaybackState.ACTION_SEEK_TO == 0L) return "unsupported"
        c.transportControls.seekTo(ms)
        return "ok"
    }

    private val main = android.os.Handler(android.os.Looper.getMainLooper())

    /** skipToQueueItem(queueId); if the app ignores it, step Next/Previous. */
    private fun goTo(id: Long?, offset: Int): String {
        val c = controller() ?: return "unsupported"
        val actions = c.playbackState?.actions ?: 0L
        val canSkipTo = actions and PlaybackState.ACTION_SKIP_TO_QUEUE_ITEM != 0L
        val canStep = actions and (PlaybackState.ACTION_SKIP_TO_NEXT or PlaybackState.ACTION_SKIP_TO_PREVIOUS) != 0L
        fun step() {
            for (i in 0 until kotlin.math.abs(offset)) {
                main.postDelayed({
                    if (offset > 0) c.transportControls.skipToNext() else c.transportControls.skipToPrevious()
                }, 350L * i)
            }
        }
        if (id != null && canSkipTo) {
            c.transportControls.skipToQueueItem(id)
            main.postDelayed({
                if (c.playbackState?.activeQueueItemId != id && offset != 0 && canStep) step()
            }, 1200)
            return "ok"
        }
        if (offset != 0 && canStep) { step(); return "ok" }
        return "unsupported"
    }

    private fun favorite(): String {
        val c = controller() ?: return "unsupported"
        favoriteAction(c)?.let {
            c.transportControls.sendCustomAction(it, it.extras)
            return "ok"
        }
        if (canRate(c)) {
            val r = when (c.ratingType) {
                Rating.RATING_HEART -> Rating.newHeartRating(true)
                Rating.RATING_THUMB_UP_DOWN -> Rating.newThumbRating(true)
                Rating.RATING_3_STARS -> Rating.newStarRating(Rating.RATING_3_STARS, 3f)
                Rating.RATING_4_STARS -> Rating.newStarRating(Rating.RATING_4_STARS, 4f)
                else -> Rating.newStarRating(Rating.RATING_5_STARS, 5f)
            }
            c.transportControls.setRating(r)
            return "ok"
        }
        return "unsupported"
    }
}
