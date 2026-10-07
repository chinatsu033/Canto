package io.github.chinatsu033.canto

import android.service.notification.NotificationListenerService

/** Exists only to grant access to active media sessions; ignores notifications. */
class MediaListener : NotificationListenerService()
