# Voice Converter Tool (SplitAndConvert.ps1)

ده سكربت PowerShell تفاعلي (Menu) لتحويل وتقسيم ملفات الصوت/الفيديو باستخدام FFmpeg، وكمان يقدر يطلع نص مكتوب من الصوت باستخدام MarkItDown.

## السكربت بيعمل إيه؟

- تحويل أي ملف فيه صوت إلى MP3
- تقسيم الملف لنصين + حفظهم MP3
- تقسيم الملف لعدد أجزاء تختاره + حفظ كل جزء MP3
- استخراج الصوت بدون إعادة ترميز (copy codec)
- تحويل الصوت لنص Markdown باستخدام MarkItDown
- ضغط الفيديو لإخراج نسخة أخف بجودة كويسة (H.264)
- إزالة الضوضاء (Noise) من الصوت مع تصغير حجم الملف والحفاظ على وضوح الكلام
- كل الملفات الناتجة بتتخزن في فولدر ثابت: `C:\Users\DELL\Music`

## المتطلبات

- Windows PowerShell أو PowerShell Core
- FFmpeg + FFprobe متضافين في PATH
- Python + pip في PATH (مطلوبين لو هتستخدم تحويل الصوت لنص)

## التشغيل

شغّل السكربت:

```powershell
.\SplitAndConvert.ps1
```

بعد التشغيل هتظهر القائمة، اختار رقم من 1 لـ 9.

## خيارات القائمة

| الاختيار | الوظيفة                               | الوصف                                                           |
| -------- | ------------------------------------- | --------------------------------------------------------------- |
| 1        | Convert to MP3                        | بيحوّل الملف إلى MP3 بجودة عالية (`-q:a 2`)                     |
| 2        | Split in half + MP3                   | بيقسم الملف لنصين متساويين ويحفظهم MP3                          |
| 3        | Split into multiple parts + MP3       | بيطلب منك عدد الأجزاء (لازم 2 أو أكتر) ويحفظ كل جزء MP3         |
| 4        | Extract audio (no re-encode)          | بيستخرج الصوت كما هو بدون re-encode باستخدام `-acodec copy`     |
| 5        | Transcribe audio to text (MarkItDown) | بيحوّل الصوت إلى ملف نصي Markdown                               |
| 6        | Compress Video (Fast H.264)           | بيضغط الفيديو باستخدام H.264 بجودة كويسة وحجم أقل               |
| 7        | Change Video/Audio Speed              | بيغيّر سرعة الفيديو والصوت مع بعض بنفس النسبة (setpts + atempo) |
| 8        | Remove Noise + Compress               | بيشيل الضوضاء من الصوت وبيصغّر الحجم مع الحفاظ على وضوح الكلام  |
| 9        | Exit                                  | خروج من البرنامج                                                |

## مكان الإخراج

- السكربت بيحفظ كل النواتج في:

```text
C:\Users\DELL\Music
```

- لو الفولدر مش موجود، السكربت بيعمله تلقائي.

## تفاصيل مهمة حسب كل وظيفة

### 1) Convert to MP3

- بياخد مسار ملف الإدخال منك
- بيطلع ملف باسم نفس اسم الملف الأصلي لكن بامتداد `.mp3`

### 2) Split in half + MP3

- بيحسب مدة الملف بـ `ffprobe`
- بيقسم عند نقطة النص بالثواني
- بيطلع:
  - `FileName_Part1.mp3`
  - `FileName_Part2.mp3`

### 3) Split into multiple parts + MP3

- بيطلب منك عدد الأجزاء
- لو الرقم أقل من 2 هيظهر خطأ
- كل جزء بيتسمى بالشكل:
  - `FileName_Part1.mp3`
  - `FileName_Part2.mp3`
  - ...

### 4) Extract audio (no re-encode)

- بيكتشف codec الصوت من الملف الأصلي
- بيختار امتداد الإخراج تلقائيًا حسب الـcodec:

| codec   | extension |
| ------- | --------- |
| aac     | m4a       |
| mp3     | mp3       |
| opus    | opus      |
| vorbis  | ogg       |
| flac    | flac      |
| غير كده | mka       |

- بعد الاستخراج، بيسألك لو عايز تعمل transcription مباشرة

### 5) Transcribe audio to text (MarkItDown)

- لو `markitdown` مش متسطب، السكربت بيسألك يسطبه تلقائيًا:

```powershell
python -m pip install "markitdown[audio-transcription]"
```

- الناتج بيكون ملف Markdown باسم:
  - `FileName_transcript.md`

### 6) Compress Video (Fast H.264)

- بيضغط الفيديو باستخدام `libx264` بقيمة `crf 23` و`preset veryfast`
- الصوت بيتحوّل لـ AAC بمعدل `128k`
- الناتج بيكون ملف باسم:
  - `FileName_compressed.mp4`

### 7) Change Video/Audio Speed

- بتدخل مسار ملف الإدخال (فيديو/صوت)
- بتكتب معامل السرعة (Speed Multiplier) زي: `1.1` أو `1.25` أو `1.5` أو `0.5`
- لو كتبت السرعة بكوما زي `1,5` السكربت بيحوّلها تلقائيًا لـ `1.5` قبل ما يحولها لرقم (علشان اختلاف الـlocale)
- الفيديو بيتظبط بفلتر `setpts` علشان يسرّع/يبطّأ التايم ستامبز:
  - `setpts=PTS/<speed>`
  - مثال: لو السرعة `1.5` يبقى الفيديو أسرع، ولو `0.5` يبقى أبطأ
- الصوت بيتظبط بفلتر `atempo` بنفس النسبة علشان يفضلوا متزامنين (Sync):
  - `atempo=<speed>`
  - ملاحظة: `atempo` بيقبل من `0.5` لحد `2.0` لكل فلتر، فلو السرعة أكبر من `2.0` بيتعمل كـ chain زي:
    - `atempo=2.0,atempo=2.0,atempo=1.25`
- الناتج بيتحفظ في فولدر الإخراج باسم:
  - `FileName_speed1.5.mp4`

### 8) Remove Noise + Compress

- بتدخل مسار الملف (صوت أو فيديو)، والسكربت بيكتشف لوحده لو فيه فيديو حقيقي ولا لأ
  - ملاحظة: صورة الغلاف (Cover Art) جوه ملفات MP3/M4A مش بتتحسب فيديو
- بيسألك على مستوى إزالة الضوضاء (لو سيبتها فاضية بياخد Medium):

| المستوى    | الفلتر                                                  |
| ---------- | ------------------------------------------------------- |
| 1 Light    | `highpass=f=80,afftdn=nr=6:nf=-30:tn=1`                 |
| 2 Medium   | `highpass=f=80,afftdn=nr=12:nf=-25:tn=1`                |
| 3 Strong   | `highpass=f=90,afftdn=nr=24:nf=-20:tn=1,anlmdn=s=0.0002` |

- لو الملف **صوت بس**: الناتج بيكون Opus مونو 16 kHz بـ 32 kbps (حجم صغير جدًا والكلام واضح)
  - `FileName_clean.opus`
- لو الملف **فيديو**: الصورة بتفضل موجودة والصوت بيتنضّف، والفيديو بيتضغط بـ `libx264 -crf 26` والصوت AAC 96k
  - `FileName_clean.mp4`
- في الآخر السكربت بيطبع حجم الملف قبل وبعد ونسبة التوفير

## الملاحظات التقنية

- السكربت بيستخدم `-y` في FFmpeg علشان يعمل overwrite للملفات القديمة بدون تأكيد
- في التحويل/التقسيم بيستخدم `-map a` (صوت فقط)
- الملف الأصلي لا يتم تعديله

## حل المشاكل

### `ffmpeg is not recognized`

- نزّل FFmpeg من:
  - https://ffmpeg.org/download.html
- ضيف مسار FFmpeg في PATH

### `markitdown is not installed`

- اتأكد إن Python وpip شغالين من التيرمنال
- نفّذ:

```powershell
python -m pip install "markitdown[audio-transcription]"
```

### `Error: file not found.`

- اتأكد إن المسار صحيح
- ممكن تحط المسار بين quotes لو فيه مسافات

### `Invalid choice. Pick 1-9.`

- لازم تدخل رقم من 1 إلى 9

### `Error: parts must be 2 or more.`

- في خيار التقسيم المتعدد لازم عدد الأجزاء يكون 2 أو أكتر

## مثال استخدام سريع

1. شغّل السكربت
2. اختار `2` للتقسيم نصين
3. اكتب مسار الملف
4. استنى لحد ما تظهر رسالة `Done.`
5. هتلاقي النواتج في `C:\Users\DELL\Music`
