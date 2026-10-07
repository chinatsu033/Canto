# Source of truth for UI strings. Run: python3 tool/l10n_source.py  (writes lib/l10n/*.arb)
# Keys (order matters for the tables below).
KEYS = ["appTitle","nothingPlaying","nothingPlayingHint","loadingLyrics","noLyrics","plainLyricsNote","lyricsError","retry",
"play","pause","favorite","favoriteSent","favoriteUnsupported","favoriteFailed","controlUnsupported","upNext","alwaysOnTop",
"minimize","close","back","permissionTitle","permissionBody","grantPermission","sourceUnavailable","resumeFollow","lyricsFrom",
"seekUnsupported","commandFailed","instrumental","translation","romanization","noTranslationHint","noRomanizationHint",
"autoLabel","language","followSystem","playerActions","playerActionsNone"]

T = {}
T["en"] = ["Canto","Nothing is playing","Play something in any music app. Canto only reads the system's now-playing info.",
"Looking up lyrics…","No lyrics yet","Unsynced lyrics (no timing)","Couldn't reach the lyrics services","Retry",
"Play","Pause","Favorite","Sent to {app}","This player doesn't let other apps favorite tracks","The player rejected the request",
"This player doesn't accept remote control","Up next","Always on top","Minimize","Close","Back","Notification access needed",
"Android only shares other apps' media sessions with apps that have notification access. Canto reads only media info, never notification content.",
"Open settings","Now-playing info isn't available on this system","Back to current line","Lyrics from {source}",
"This player doesn't allow seeking","The player didn't accept the request","Instrumental","Translation","Romanization",
"No translation for this song yet","No romanization for this song yet","auto","Language","Follow system",
"Player actions","This player exposes no extra actions"]
T["zh"] = ["Canto","当前没有正在播放的内容","在任意音乐 App 中播放音乐。Canto 只读取系统的正在播放信息。",
"正在查找歌词…","暂无歌词","非同步歌词（无时间轴）","无法连接歌词服务","重试",
"播放","暂停","收藏","已发送到 {app}","该播放器不支持由其他 App 收藏","播放器拒绝了请求",
"该播放器不接受远程控制","播放队列","窗口置顶","最小化","关闭","返回","需要通知使用权",
"Android 只向拥有通知使用权的 App 提供其他 App 的媒体会话。Canto 只读取媒体信息，不读取通知内容。",
"打开设置","此系统无法提供正在播放信息","回到当前行","歌词来自 {source}",
"该播放器不支持跳转进度","播放器未接受该操作","纯音乐","翻译","罗马音",
"此歌暂无翻译","此歌暂无罗马音","自动","语言","跟随系统","播放器操作","该播放器没有提供额外操作"]
T["zh_Hant"] = ["Canto","目前沒有正在播放的內容","在任何音樂 App 中播放音樂。Canto 只讀取系統的正在播放資訊。",
"正在查詢歌詞…","暫無歌詞","非同步歌詞（無時間軸）","無法連線至歌詞服務","重試",
"播放","暫停","收藏","已傳送至 {app}","此播放器不支援由其他 App 收藏","播放器拒絕了請求",
"此播放器不接受遠端控制","播放佇列","視窗置頂","最小化","關閉","返回","需要通知存取權",
"Android 只會將其他 App 的媒體工作階段提供給擁有通知存取權的 App。Canto 只讀取媒體資訊，不會讀取通知內容。",
"開啟設定","此系統無法提供正在播放資訊","回到目前這一行","歌詞來自 {source}",
"此播放器不支援跳轉進度","播放器未接受此操作","純音樂","翻譯","羅馬拼音",
"這首歌暫無翻譯","這首歌暫無羅馬拼音","自動","語言","跟隨系統","播放器操作","此播放器沒有提供額外操作"]
T["zh_Hant_HK"] = ["Canto","目前沒有正在播放的內容","在任何音樂 App 播放音樂。Canto 只會讀取系統的正在播放資料。",
"正在搜尋歌詞…","暫時未有歌詞","非同步歌詞（沒有時間軸）","無法連接歌詞服務","重試",
"播放","暫停","收藏","已傳送至 {app}","此播放器不支援由其他 App 收藏","播放器拒絕了要求",
"此播放器不接受遙距控制","播放隊列","視窗置頂","最小化","關閉","返回","需要通知存取權",
"Android 只會將其他 App 的媒體工作階段提供給擁有通知存取權的 App。Canto 只讀取媒體資料，不會讀取通知內容。",
"開啟設定","此系統無法提供正在播放資料","回到目前一句","歌詞來自 {source}",
"此播放器不支援跳轉進度","播放器未接受此操作","純音樂","翻譯","拼音／羅馬字",
"這首歌暫時未有翻譯","這首歌暫時未有拼音","自動","語言","跟隨系統","播放器操作","此播放器沒有提供額外操作"]
T["ja"] = ["Canto","再生中のメディアはありません","音楽アプリで何か再生してください。Canto はシステムの再生中情報を読み取るだけです。",
"歌詞を検索中…","歌詞はまだありません","同期なしの歌詞（タイミングなし）","歌詞サービスに接続できません","再試行",
"再生","一時停止","お気に入り","{app} に送信しました","このプレーヤーは他のアプリからのお気に入り登録に対応していません","プレーヤーがリクエストを拒否しました",
"このプレーヤーはリモート操作に対応していません","次に再生","常に手前に表示","最小化","閉じる","戻る","通知へのアクセスが必要です",
"Android は通知へのアクセス権を持つアプリにのみ他アプリのメディアセッションを公開します。Canto はメディア情報のみを読み取り、通知の内容は読み取りません。",
"設定を開く","このシステムでは再生中情報を取得できません","現在の行に戻る","歌詞提供：{source}",
"このプレーヤーはシークに対応していません","プレーヤーが操作を受け付けませんでした","インストゥルメンタル","翻訳","ローマ字",
"この曲の翻訳はまだありません","この曲のローマ字はまだありません","自動","言語","システムに従う","プレーヤーの操作","このプレーヤーには追加の操作がありません"]
T["ko"] = ["Canto","재생 중인 항목이 없습니다","아무 음악 앱에서나 재생해 보세요. Canto는 시스템의 재생 정보만 읽습니다.",
"가사를 찾는 중…","아직 가사가 없습니다","싱크 없는 가사(타이밍 없음)","가사 서비스에 연결할 수 없습니다","다시 시도",
"재생","일시정지","즐겨찾기","{app}(으)로 보냈습니다","이 플레이어는 다른 앱에서 즐겨찾기를 추가할 수 없습니다","플레이어가 요청을 거부했습니다",
"이 플레이어는 원격 제어를 지원하지 않습니다","다음 곡","항상 위에 표시","최소화","닫기","뒤로","알림 접근 권한이 필요합니다",
"Android는 알림 접근 권한이 있는 앱에만 다른 앱의 미디어 세션을 공유합니다. Canto는 미디어 정보만 읽으며 알림 내용은 읽지 않습니다.",
"설정 열기","이 시스템에서는 재생 정보를 가져올 수 없습니다","현재 줄로 돌아가기","가사 제공: {source}",
"이 플레이어는 탐색을 지원하지 않습니다","플레이어가 요청을 받아들이지 않았습니다","연주곡","번역","로마자",
"이 곡은 아직 번역이 없습니다","이 곡은 아직 로마자 표기가 없습니다","자동","언어","시스템 설정 따르기","플레이어 동작","이 플레이어는 추가 동작을 제공하지 않습니다"]
T["fr"] = ["Canto","Aucune lecture en cours","Lancez un morceau dans n'importe quelle appli musicale. Canto lit seulement les infos de lecture du système.",
"Recherche des paroles…","Pas encore de paroles","Paroles non synchronisées (sans minutage)","Impossible de joindre les services de paroles","Réessayer",
"Lecture","Pause","Favori","Envoyé à {app}","Ce lecteur ne permet pas aux autres applis d'ajouter des favoris","Le lecteur a refusé la demande",
"Ce lecteur n'accepte pas la commande à distance","À suivre","Toujours au premier plan","Réduire","Fermer","Retour","Accès aux notifications requis",
"Android ne partage les sessions multimédias des autres applis qu'avec les applis ayant accès aux notifications. Canto lit uniquement les infos multimédias, jamais le contenu des notifications.",
"Ouvrir les réglages","Les infos de lecture ne sont pas disponibles sur ce système","Revenir à la ligne en cours","Paroles : {source}",
"Ce lecteur ne permet pas de changer la position","Le lecteur n'a pas accepté la demande","Instrumental","Traduction","Romanisation",
"Pas encore de traduction pour ce titre","Pas encore de romanisation pour ce titre","auto","Langue","Suivre le système","Actions du lecteur","Ce lecteur ne propose aucune action supplémentaire"]
T["de"] = ["Canto","Es wird nichts abgespielt","Spiele etwas in einer beliebigen Musik-App ab. Canto liest nur die Wiedergabeinfos des Systems.",
"Songtext wird gesucht…","Noch kein Songtext","Nicht synchronisierter Songtext (ohne Zeitangaben)","Songtext-Dienste nicht erreichbar","Erneut versuchen",
"Abspielen","Pause","Favorit","An {app} gesendet","Dieser Player erlaubt anderen Apps keine Favoriten","Der Player hat die Anfrage abgelehnt",
"Dieser Player lässt sich nicht fernsteuern","Als Nächstes","Immer im Vordergrund","Minimieren","Schließen","Zurück","Zugriff auf Benachrichtigungen nötig",
"Android teilt Mediensitzungen anderer Apps nur mit Apps, die Zugriff auf Benachrichtigungen haben. Canto liest nur Medieninfos, nie Benachrichtigungsinhalte.",
"Einstellungen öffnen","Wiedergabeinfos sind auf diesem System nicht verfügbar","Zur aktuellen Zeile","Songtext von {source}",
"Dieser Player unterstützt kein Spulen","Der Player hat die Anfrage nicht angenommen","Instrumental","Übersetzung","Umschrift",
"Für diesen Song gibt es noch keine Übersetzung","Für diesen Song gibt es noch keine Umschrift","auto","Sprache","Wie System","Player-Aktionen","Dieser Player bietet keine zusätzlichen Aktionen"]
T["es"] = ["Canto","No se está reproduciendo nada","Reproduce algo en cualquier app de música. Canto solo lee la información de reproducción del sistema.",
"Buscando la letra…","Aún no hay letra","Letra sin sincronizar (sin tiempos)","No se pudo conectar con los servicios de letras","Reintentar",
"Reproducir","Pausa","Favorito","Enviado a {app}","Este reproductor no permite que otras apps marquen favoritos","El reproductor rechazó la solicitud",
"Este reproductor no acepta control remoto","A continuación","Siempre visible","Minimizar","Cerrar","Atrás","Se necesita acceso a las notificaciones",
"Android solo comparte las sesiones multimedia de otras apps con las apps que tienen acceso a las notificaciones. Canto solo lee la información multimedia, nunca el contenido de las notificaciones.",
"Abrir ajustes","La información de reproducción no está disponible en este sistema","Volver a la línea actual","Letra de {source}",
"Este reproductor no permite cambiar la posición","El reproductor no aceptó la solicitud","Instrumental","Traducción","Romanización",
"Esta canción aún no tiene traducción","Esta canción aún no tiene romanización","auto","Idioma","Igual que el sistema","Acciones del reproductor","Este reproductor no ofrece acciones adicionales"]
T["pt"] = ["Canto","Nada tocando agora","Toque algo em qualquer app de música. O Canto só lê as informações de reprodução do sistema.",
"Procurando a letra…","Ainda sem letra","Letra não sincronizada (sem tempos)","Não foi possível acessar os serviços de letras","Tentar de novo",
"Tocar","Pausar","Favoritar","Enviado para {app}","Este player não permite que outros apps favoritem músicas","O player recusou o pedido",
"Este player não aceita controle remoto","A seguir","Sempre no topo","Minimizar","Fechar","Voltar","É preciso acesso às notificações",
"O Android só compartilha as sessões de mídia de outros apps com apps que têm acesso às notificações. O Canto lê apenas as informações de mídia, nunca o conteúdo das notificações.",
"Abrir configurações","As informações de reprodução não estão disponíveis neste sistema","Voltar à linha atual","Letra de {source}",
"Este player não permite avançar ou voltar","O player não aceitou o pedido","Instrumental","Tradução","Romanização",
"Esta música ainda não tem tradução","Esta música ainda não tem romanização","auto","Idioma","Seguir o sistema","Ações do player","Este player não oferece ações extras"]
T["it"] = ["Canto","Nessuna riproduzione in corso","Riproduci qualcosa in qualsiasi app musicale. Canto legge solo le informazioni di riproduzione del sistema.",
"Ricerca del testo…","Ancora nessun testo","Testo non sincronizzato (senza tempi)","Impossibile raggiungere i servizi dei testi","Riprova",
"Riproduci","Pausa","Preferito","Inviato a {app}","Questo player non consente ad altre app di aggiungere preferiti","Il player ha rifiutato la richiesta",
"Questo player non accetta il controllo remoto","In coda","Sempre in primo piano","Riduci a icona","Chiudi","Indietro","Serve l'accesso alle notifiche",
"Android condivide le sessioni multimediali delle altre app solo con le app che hanno accesso alle notifiche. Canto legge solo le informazioni multimediali, mai il contenuto delle notifiche.",
"Apri impostazioni","Le informazioni di riproduzione non sono disponibili su questo sistema","Torna alla riga corrente","Testo da {source}",
"Questo player non consente di spostarsi nel brano","Il player non ha accettato la richiesta","Strumentale","Traduzione","Traslitterazione",
"Nessuna traduzione per questo brano","Nessuna traslitterazione per questo brano","auto","Lingua","Come il sistema","Azioni del player","Questo player non offre azioni aggiuntive"]
T["ru"] = ["Canto","Сейчас ничего не играет","Включите музыку в любом приложении. Canto только читает системные данные о воспроизведении.",
"Ищем текст песни…","Текста пока нет","Несинхронизированный текст (без таймкодов)","Не удаётся связаться с сервисами текстов","Повторить",
"Воспроизвести","Пауза","В избранное","Отправлено в {app}","Этот плеер не разрешает другим приложениям добавлять в избранное","Плеер отклонил запрос",
"Этот плеер не поддерживает удалённое управление","Далее в очереди","Поверх всех окон","Свернуть","Закрыть","Назад","Нужен доступ к уведомлениям",
"Android передаёт медиасессии других приложений только тем, у кого есть доступ к уведомлениям. Canto читает только данные о медиа и никогда — содержимое уведомлений.",
"Открыть настройки","Данные о воспроизведении в этой системе недоступны","К текущей строке","Текст: {source}",
"Этот плеер не поддерживает перемотку","Плеер не принял запрос","Инструментал","Перевод","Транслитерация",
"Для этой песни пока нет перевода","Для этой песни пока нет транслитерации","авто","Язык","Как в системе","Действия плеера","Этот плеер не предоставляет дополнительных действий"]
T["ar"] = ["Canto","لا يوجد تشغيل حاليًا","شغّل أي شيء في أي تطبيق موسيقى. يقرأ Canto معلومات التشغيل من النظام فقط.",
"جارٍ البحث عن الكلمات…","لا توجد كلمات بعد","كلمات غير متزامنة (بدون توقيت)","تعذّر الوصول إلى خدمات الكلمات","إعادة المحاولة",
"تشغيل","إيقاف مؤقت","المفضلة","تم الإرسال إلى {app}","لا يسمح هذا المشغّل للتطبيقات الأخرى بإضافة المفضلة","رفض المشغّل الطلب",
"لا يقبل هذا المشغّل التحكم عن بُعد","التالي","فوق كل النوافذ","تصغير","إغلاق","رجوع","يلزم الوصول إلى الإشعارات",
"لا يشارك Android جلسات الوسائط الخاصة بالتطبيقات الأخرى إلا مع التطبيقات التي لديها إذن الوصول إلى الإشعارات. يقرأ Canto معلومات الوسائط فقط ولا يقرأ محتوى الإشعارات أبدًا.",
"فتح الإعدادات","معلومات التشغيل غير متاحة على هذا النظام","العودة إلى السطر الحالي","الكلمات من {source}",
"لا يدعم هذا المشغّل تغيير موضع التشغيل","لم يقبل المشغّل الطلب","موسيقى بدون غناء","الترجمة","الكتابة بالحروف اللاتينية",
"لا توجد ترجمة لهذه الأغنية بعد","لا توجد كتابة لاتينية لهذه الأغنية بعد","تلقائي","اللغة","حسب النظام","إجراءات المشغّل","لا يوفّر هذا المشغّل إجراءات إضافية"]
T["th"] = ["Canto","ไม่มีเพลงที่กำลังเล่น","เปิดเพลงในแอปเพลงใดก็ได้ Canto อ่านเฉพาะข้อมูลการเล่นของระบบเท่านั้น",
"กำลังค้นหาเนื้อเพลง…","ยังไม่มีเนื้อเพลง","เนื้อเพลงแบบไม่ซิงก์ (ไม่มีเวลา)","เชื่อมต่อบริการเนื้อเพลงไม่ได้","ลองอีกครั้ง",
"เล่น","หยุดชั่วคราว","รายการโปรด","ส่งไปยัง {app} แล้ว","เพลเยอร์นี้ไม่อนุญาตให้แอปอื่นเพิ่มรายการโปรด","เพลเยอร์ปฏิเสธคำขอ",
"เพลเยอร์นี้ไม่รองรับการควบคุมจากระยะไกล","ถัดไป","อยู่บนสุดเสมอ","ย่อหน้าต่าง","ปิด","กลับ","ต้องการสิทธิ์เข้าถึงการแจ้งเตือน",
"Android จะแชร์เซสชันสื่อของแอปอื่นเฉพาะกับแอปที่มีสิทธิ์เข้าถึงการแจ้งเตือน Canto อ่านเฉพาะข้อมูลสื่อ ไม่อ่านเนื้อหาการแจ้งเตือน",
"เปิดการตั้งค่า","ระบบนี้ไม่มีข้อมูลการเล่น","กลับไปบรรทัดปัจจุบัน","เนื้อเพลงจาก {source}",
"เพลเยอร์นี้ไม่รองรับการเลื่อนตำแหน่ง","เพลเยอร์ไม่ยอมรับคำขอ","บรรเลง","คำแปล","คำอ่านอักษรโรมัน",
"เพลงนี้ยังไม่มีคำแปล","เพลงนี้ยังไม่มีคำอ่านอักษรโรมัน","อัตโนมัติ","ภาษา","ตามระบบ","การทำงานของเพลเยอร์","เพลเยอร์นี้ไม่มีการทำงานเพิ่มเติม"]
T["vi"] = ["Canto","Không có gì đang phát","Hãy phát nhạc trong bất kỳ ứng dụng nào. Canto chỉ đọc thông tin đang phát của hệ thống.",
"Đang tìm lời bài hát…","Chưa có lời bài hát","Lời không đồng bộ (không có thời gian)","Không kết nối được dịch vụ lời bài hát","Thử lại",
"Phát","Tạm dừng","Yêu thích","Đã gửi tới {app}","Trình phát này không cho ứng dụng khác thêm yêu thích","Trình phát đã từ chối yêu cầu",
"Trình phát này không hỗ trợ điều khiển từ xa","Tiếp theo","Luôn ở trên cùng","Thu nhỏ","Đóng","Quay lại","Cần quyền truy cập thông báo",
"Android chỉ chia sẻ phiên phát media của ứng dụng khác với các ứng dụng có quyền truy cập thông báo. Canto chỉ đọc thông tin media, không bao giờ đọc nội dung thông báo.",
"Mở cài đặt","Hệ thống này không cung cấp thông tin đang phát","Về dòng hiện tại","Lời từ {source}",
"Trình phát này không hỗ trợ tua","Trình phát không chấp nhận yêu cầu","Nhạc không lời","Bản dịch","Phiên âm Latinh",
"Bài này chưa có bản dịch","Bài này chưa có phiên âm","tự động","Ngôn ngữ","Theo hệ thống","Thao tác của trình phát","Trình phát này không có thao tác bổ sung"]
T["id"] = ["Canto","Tidak ada yang diputar","Putar sesuatu di aplikasi musik apa pun. Canto hanya membaca info pemutaran dari sistem.",
"Mencari lirik…","Belum ada lirik","Lirik tidak sinkron (tanpa waktu)","Tidak dapat menghubungi layanan lirik","Coba lagi",
"Putar","Jeda","Favorit","Terkirim ke {app}","Pemutar ini tidak mengizinkan aplikasi lain menambah favorit","Pemutar menolak permintaan",
"Pemutar ini tidak menerima kontrol jarak jauh","Berikutnya","Selalu di atas","Perkecil","Tutup","Kembali","Perlu akses notifikasi",
"Android hanya membagikan sesi media aplikasi lain kepada aplikasi yang punya akses notifikasi. Canto hanya membaca info media, tidak pernah isi notifikasi.",
"Buka setelan","Info pemutaran tidak tersedia di sistem ini","Kembali ke baris saat ini","Lirik dari {source}",
"Pemutar ini tidak mendukung penggeseran posisi","Pemutar tidak menerima permintaan","Instrumental","Terjemahan","Romanisasi",
"Lagu ini belum punya terjemahan","Lagu ini belum punya romanisasi","otomatis","Bahasa","Ikuti sistem","Aksi pemutar","Pemutar ini tidak menyediakan aksi tambahan"]
T["ms"] = ["Canto","Tiada apa-apa dimainkan","Mainkan sesuatu dalam mana-mana aplikasi muzik. Canto hanya membaca maklumat main semasa daripada sistem.",
"Mencari lirik…","Belum ada lirik","Lirik tidak segerak (tanpa masa)","Tidak dapat menghubungi perkhidmatan lirik","Cuba lagi",
"Main","Jeda","Kegemaran","Dihantar ke {app}","Pemain ini tidak membenarkan aplikasi lain menambah kegemaran","Pemain menolak permintaan",
"Pemain ini tidak menerima kawalan jauh","Seterusnya","Sentiasa di atas","Kecilkan","Tutup","Kembali","Akses pemberitahuan diperlukan",
"Android hanya berkongsi sesi media aplikasi lain dengan aplikasi yang mempunyai akses pemberitahuan. Canto hanya membaca maklumat media, bukan kandungan pemberitahuan.",
"Buka tetapan","Maklumat main semasa tiada pada sistem ini","Kembali ke baris semasa","Lirik daripada {source}",
"Pemain ini tidak menyokong anjakan kedudukan","Pemain tidak menerima permintaan","Instrumental","Terjemahan","Rumi",
"Lagu ini belum ada terjemahan","Lagu ini belum ada ejaan rumi","auto","Bahasa","Ikut sistem","Tindakan pemain","Pemain ini tidak menyediakan tindakan tambahan"]
T["tr"] = ["Canto","Şu anda bir şey çalmıyor","Herhangi bir müzik uygulamasında bir şey çalın. Canto yalnızca sistemin çalma bilgilerini okur.",
"Şarkı sözü aranıyor…","Henüz şarkı sözü yok","Senkronize olmayan söz (zamanlama yok)","Şarkı sözü servislerine ulaşılamadı","Tekrar dene",
"Oynat","Duraklat","Favori","{app} uygulamasına gönderildi","Bu oynatıcı diğer uygulamaların favori eklemesine izin vermiyor","Oynatıcı isteği reddetti",
"Bu oynatıcı uzaktan kontrolü kabul etmiyor","Sıradaki","Her zaman üstte","Küçült","Kapat","Geri","Bildirim erişimi gerekli",
"Android, diğer uygulamaların medya oturumlarını yalnızca bildirim erişimi olan uygulamalarla paylaşır. Canto yalnızca medya bilgilerini okur, bildirim içeriğini asla okumaz.",
"Ayarları aç","Bu sistemde çalma bilgisi alınamıyor","Geçerli satıra dön","Sözler: {source}",
"Bu oynatıcı ileri/geri sarmayı desteklemiyor","Oynatıcı isteği kabul etmedi","Enstrümantal","Çeviri","Latin harfli okunuş",
"Bu şarkının henüz çevirisi yok","Bu şarkının henüz Latin harfli okunuşu yok","otomatik","Dil","Sistemi izle","Oynatıcı eylemleri","Bu oynatıcı ek eylem sunmuyor"]
T["hi"] = ["Canto","अभी कुछ नहीं चल रहा","किसी भी म्यूज़िक ऐप में कुछ चलाएँ। Canto सिर्फ़ सिस्टम की ‘अभी चल रहा है’ जानकारी पढ़ता है।",
"बोल खोजे जा रहे हैं…","अभी बोल उपलब्ध नहीं","असिंक्रनाइज़्ड बोल (समय के बिना)","बोल सेवाओं से कनेक्ट नहीं हो सका","फिर से कोशिश करें",
"चलाएँ","रोकें","पसंदीदा","{app} को भेजा गया","यह प्लेयर दूसरे ऐप्स को पसंदीदा जोड़ने नहीं देता","प्लेयर ने अनुरोध अस्वीकार किया",
"यह प्लेयर रिमोट कंट्रोल स्वीकार नहीं करता","आगे","हमेशा ऊपर","छोटा करें","बंद करें","वापस","सूचना ऐक्सेस ज़रूरी है",
"Android दूसरे ऐप्स के मीडिया सेशन सिर्फ़ उन्हीं ऐप्स से साझा करता है जिनके पास सूचना ऐक्सेस है। Canto सिर्फ़ मीडिया जानकारी पढ़ता है, सूचनाओं की सामग्री कभी नहीं।",
"सेटिंग खोलें","इस सिस्टम पर ‘अभी चल रहा है’ जानकारी उपलब्ध नहीं","मौजूदा पंक्ति पर लौटें","बोल स्रोत: {source}",
"यह प्लेयर आगे-पीछे करने की सुविधा नहीं देता","प्लेयर ने अनुरोध स्वीकार नहीं किया","वाद्य संगीत","अनुवाद","रोमन लिपि",
"इस गाने का अभी अनुवाद नहीं है","इस गाने का अभी रोमन लिप्यंतरण नहीं है","ऑटो","भाषा","सिस्टम के अनुसार","प्लेयर की कार्रवाइयाँ","यह प्लेयर कोई अतिरिक्त कार्रवाई नहीं देता"]

# Native names for the language picker (not translated per UI language).

# v0.1.3 keys: autoTranslateLabel, translatingHint, modelDownloadingHint, translateQuotaHint, translateFailedHint
KEYS += ["autoTranslateLabel","translatingHint","modelDownloadingHint","translateQuotaHint","translateFailedHint"]
EXTRA = {
"en":["Auto-translated","Translating…","Downloading the translation model (about 30 MB, first time only)…","Today's free translation quota is used up — try again tomorrow","Automatic translation failed"],
"zh":["自动翻译","正在翻译…","首次使用，正在下载翻译模型（约 30 MB）…","今日免费翻译额度已用完，请明天再试","自动翻译失败"],
"zh_Hant":["自動翻譯","正在翻譯…","首次使用，正在下載翻譯模型（約 30 MB）…","今日免費翻譯額度已用完，請明天再試","自動翻譯失敗"],
"zh_Hant_HK":["自動翻譯","正在翻譯…","首次使用，正在下載翻譯模型（約 30 MB）…","今日免費翻譯額度已用完，請明天再試","自動翻譯失敗"],
"ja":["自動翻訳","翻訳中…","翻訳モデルをダウンロード中（約 30 MB、初回のみ）…","本日の無料翻訳の上限に達しました。明日もう一度お試しください","自動翻訳に失敗しました"],
"ko":["자동 번역","번역 중…","번역 모델 다운로드 중(약 30MB, 최초 1회)…","오늘의 무료 번역 한도를 모두 사용했습니다. 내일 다시 시도하세요","자동 번역에 실패했습니다"],
"fr":["Traduction automatique","Traduction…","Téléchargement du modèle de traduction (env. 30 Mo, une seule fois)…","Quota de traduction gratuit du jour épuisé — réessayez demain","La traduction automatique a échoué"],
"de":["Automatisch übersetzt","Wird übersetzt…","Übersetzungsmodell wird geladen (ca. 30 MB, nur beim ersten Mal)…","Das heutige kostenlose Übersetzungskontingent ist aufgebraucht – morgen erneut versuchen","Automatische Übersetzung fehlgeschlagen"],
"es":["Traducción automática","Traduciendo…","Descargando el modelo de traducción (unos 30 MB, solo la primera vez)…","Se agotó la cuota gratuita de traducción de hoy; inténtalo mañana","Falló la traducción automática"],
"pt":["Tradução automática","Traduzindo…","Baixando o modelo de tradução (cerca de 30 MB, só na primeira vez)…","A cota gratuita de tradução de hoje acabou — tente amanhã","A tradução automática falhou"],
"it":["Traduzione automatica","Traduzione in corso…","Download del modello di traduzione (circa 30 MB, solo la prima volta)…","Quota di traduzione gratuita di oggi esaurita: riprova domani","Traduzione automatica non riuscita"],
"ru":["Автоперевод","Перевод…","Загрузка модели перевода (около 30 МБ, только в первый раз)…","Бесплатный лимит перевода на сегодня исчерпан — попробуйте завтра","Не удалось выполнить автоперевод"],
"ar":["ترجمة تلقائية","جارٍ الترجمة…","جارٍ تنزيل نموذج الترجمة (حوالي 30 ميغابايت، للمرة الأولى فقط)…","نفدت حصة الترجمة المجانية لليوم — حاول غدًا","فشلت الترجمة التلقائية"],
"th":["แปลอัตโนมัติ","กำลังแปล…","กำลังดาวน์โหลดโมเดลแปลภาษา (ประมาณ 30 MB ครั้งแรกเท่านั้น)…","โควตาการแปลฟรีของวันนี้หมดแล้ว ลองใหม่พรุ่งนี้","การแปลอัตโนมัติล้มเหลว"],
"vi":["Dịch tự động","Đang dịch…","Đang tải mô hình dịch (khoảng 30 MB, chỉ lần đầu)…","Đã hết hạn mức dịch miễn phí hôm nay — hãy thử lại vào ngày mai","Dịch tự động thất bại"],
"id":["Terjemahan otomatis","Menerjemahkan…","Mengunduh model terjemahan (sekitar 30 MB, hanya pertama kali)…","Kuota terjemahan gratis hari ini habis — coba lagi besok","Terjemahan otomatis gagal"],
"ms":["Terjemahan automatik","Menterjemah…","Memuat turun model terjemahan (kira-kira 30 MB, kali pertama sahaja)…","Kuota terjemahan percuma hari ini telah habis — cuba lagi esok","Terjemahan automatik gagal"],
"tr":["Otomatik çeviri","Çevriliyor…","Çeviri modeli indiriliyor (yaklaşık 30 MB, yalnızca ilk sefer)…","Bugünkü ücretsiz çeviri kotası doldu — yarın tekrar deneyin","Otomatik çeviri başarısız oldu"],
"hi":["स्वचालित अनुवाद","अनुवाद हो रहा है…","अनुवाद मॉडल डाउनलोड हो रहा है (लगभग 30 MB, केवल पहली बार)…","आज का मुफ़्त अनुवाद कोटा समाप्त हो गया — कल फिर कोशिश करें","स्वचालित अनुवाद विफल रहा"],
}
for _k, _v in EXTRA.items():
    T[_k] = T[_k] + _v
NATIVE = {"zh":"简体中文","zh_Hant":"繁體中文（台灣）","zh_Hant_HK":"繁體中文（香港）","en":"English","ja":"日本語","ko":"한국어",
"fr":"Français","de":"Deutsch","es":"Español","pt":"Português (Brasil)","it":"Italiano","ru":"Русский","ar":"العربية",
"th":"ไทย","vi":"Tiếng Việt","id":"Bahasa Indonesia","ms":"Bahasa Melayu","tr":"Türkçe","hi":"हिन्दी"}

if __name__ == "__main__":
    import json, os, glob
    os.chdir(os.path.join(os.path.dirname(__file__), ".."))
    for f in glob.glob("lib/l10n/app_*.arb"): os.remove(f)
    for loc, vals in T.items():
        assert len(vals) == len(KEYS), (loc, len(vals), len(KEYS))
        d = {"@@locale": loc}
        for k, v in zip(KEYS, vals):
            d[k] = v
        if loc == "en":
            d["@favoriteSent"] = {"placeholders": {"app": {"type": "String"}}}
            d["@lyricsFrom"] = {"placeholders": {"source": {"type": "String"}}}
        json.dump(d, open(f"lib/l10n/app_{loc}.arb", "w"), ensure_ascii=False, indent=2)
    print(len(T), "locales")
