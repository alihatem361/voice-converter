# Voice Converter Tool (SplitAndConvert.ps1)

ده سكربت PowerShell تفاعلي (Menu) لتحويل وتقسيم ملفات الصوت/الفيديو باستخدام FFmpeg، وكمان يقدر يطلع نص مكتوب من الصوت باستخدام MarkItDown.

## السكربت بيعمل إيه؟

- تحويل أي ملف فيه صوت إلى MP3
- تقسيم الملف لنصين + حفظهم MP3
- تقسيم الملف لعدد أجزاء تختاره + حفظ كل جزء MP3
- استخراج الصوت بدون إعادة ترميز (copy codec)
- تحويل الصوت لنص Markdown باستخدام MarkItDown
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

بعد التشغيل هتظهر القائمة، اختار رقم من 1 لـ 6.

## خيارات القائمة

| الاختيار | الوظيفة                               | الوصف                                                       |
| -------- | ------------------------------------- | ----------------------------------------------------------- |
| 1        | Convert to MP3                        | بيحوّل الملف إلى MP3 بجودة عالية (`-q:a 2`)                 |
| 2        | Split in half + MP3                   | بيقسم الملف لنصين متساويين ويحفظهم MP3                      |
| 3        | Split into multiple parts + MP3       | بيطلب منك عدد الأجزاء (لازم 2 أو أكتر) ويحفظ كل جزء MP3     |
| 4        | Extract audio (no re-encode)          | بيستخرج الصوت كما هو بدون re-encode باستخدام `-acodec copy` |
| 5        | Transcribe audio to text (MarkItDown) | بيحوّل الصوت إلى ملف نصي Markdown                           |
| 6        | Exit                                  | خروج من البرنامج                                            |

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

### `Invalid choice. Pick 1-6.`

- لازم تدخل رقم من 1 إلى 6

### `Error: parts must be 2 or more.`

- في خيار التقسيم المتعدد لازم عدد الأجزاء يكون 2 أو أكتر

## مثال استخدام سريع

1. شغّل السكربت
2. اختار `2` للتقسيم نصين
3. اكتب مسار الملف
4. استنى لحد ما تظهر رسالة `Done.`
5. هتلاقي النواتج في `C:\Users\DELL\Music`
