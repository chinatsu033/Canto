package io.github.chinatsu033.canto

import android.os.Handler
import android.os.Looper
import com.google.android.gms.tasks.Tasks
import com.google.mlkit.common.model.DownloadConditions
import com.google.mlkit.common.model.RemoteModelManager
import com.google.mlkit.nl.languageid.LanguageIdentification
import com.google.mlkit.nl.translate.TranslateLanguage
import com.google.mlkit.nl.translate.TranslateRemoteModel
import com.google.mlkit.nl.translate.Translation
import com.google.mlkit.nl.translate.TranslatorOptions
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

/** On-device lyric translation with Google ML Kit. Lyric text never leaves the device
 *  (only the language model is downloaded once from Google). Nothing is logged. */
class LyricTranslation(messenger: BinaryMessenger) {
    private val ch = MethodChannel(messenger, "canto/translate")
    private val exec = Executors.newSingleThreadExecutor()
    private val main = Handler(Looper.getMainLooper())

    init {
        ch.setMethodCallHandler { call, result ->
            if (call.method != "translate") { result.notImplemented(); return@setMethodCallHandler }
            val lines = call.argument<List<String>>("lines") ?: emptyList()
            val srcHint = call.argument<String>("src") ?: "und"
            val tgtCode = call.argument<String>("tgt") ?: "en"
            exec.execute {
                try {
                    val out = run(lines, srcHint, tgtCode)
                    main.post { result.success(out) }
                } catch (e: UnsupportedOperationException) {
                    main.post { result.error("unsupported", e.message, null) }
                } catch (e: Exception) {
                    main.post { result.error("failed", e.javaClass.simpleName, null) }
                }
            }
        }
    }

    private fun run(lines: List<String>, srcHint: String, tgtCode: String): List<String?> {
        // Language ID (on-device); Dart's script guess is only a hint (latin => "en").
        var src = srcHint
        val sample = lines.filter { it.isNotBlank() }.take(20).joinToString("\n")
        try {
            val id = Tasks.await(LanguageIdentification.getClient().identifyLanguage(sample))
            if (id != "und") src = id.substringBefore('-')
        } catch (_: Exception) {}
        val s = TranslateLanguage.fromLanguageTag(src) ?: throw UnsupportedOperationException("src")
        var t = TranslateLanguage.fromLanguageTag(tgtCode) ?: throw UnsupportedOperationException("tgt")
        if (s == t) t = if (s == TranslateLanguage.ENGLISH) TranslateLanguage.CHINESE else TranslateLanguage.ENGLISH
        val mm = RemoteModelManager.getInstance()
        val needed = listOf(s, t).filter { it != TranslateLanguage.ENGLISH }.map { TranslateRemoteModel.Builder(it).build() }
        val missing = needed.any { !Tasks.await(mm.isModelDownloaded(it)) }
        if (missing) main.post { ch.invokeMethod("downloading", null) }
        val tr = Translation.getClient(TranslatorOptions.Builder().setSourceLanguage(s).setTargetLanguage(t).build())
        try {
            Tasks.await(tr.downloadModelIfNeeded(DownloadConditions.Builder().build()))
            return lines.map { l -> if (l.isBlank()) null else Tasks.await(tr.translate(l)) }
        } finally {
            tr.close()
        }
    }
}
