# SplitAndConvert.ps1 - Audio Splitter & Converter

A PowerShell script that splits any audio/video file into two equal parts and converts them to MP3 format.

## Requirements

- **FFmpeg** - Must be installed and available in your system PATH
- **FFprobe** - Comes with FFmpeg installation
- **PowerShell** - Windows PowerShell or PowerShell Core

## What It Does

1. Takes any audio or video file as input
2. Calculates the total duration automatically
3. Splits the file at the exact midpoint
4. Converts both halves to high-quality MP3 format
5. Saves the output files in the same folder as the original

## Usage

### Basic Syntax

```powershell
.\SplitAndConvert.ps1 -FilePath "path\to\your\file"
```

### Examples

**Split an MP3 file:**

```powershell
.\SplitAndConvert.ps1 -FilePath "C:\Users\DELL\Music\podcast.mp3"
```

**Split a video file (extracts audio only):**

```powershell
.\SplitAndConvert.ps1 -FilePath "C:\Users\DELL\Videos\lecture.mkv"
```

**Split a WAV file:**

```powershell
.\SplitAndConvert.ps1 -FilePath "C:\Users\DELL\Music\recording.wav"
```

## Output

The script creates two MP3 files in the same directory as the input file:

| Input File    | Output Files                              |
| ------------- | ----------------------------------------- |
| `podcast.mp3` | `podcast_Part1.mp3` + `podcast_Part2.mp3` |
| `lecture.mkv` | `lecture_Part1.mp3` + `lecture_Part2.mp3` |

## Supported Input Formats

Any format supported by FFmpeg, including:

- Audio: MP3, WAV, FLAC, AAC, OGG, M4A, WMA
- Video: MP4, MKV, AVI, MOV, WMV, FLV, WebM

## Console Output

The script displays progress messages in Arabic:

| Message             | Meaning                          |
| ------------------- | -------------------------------- |
| جاري تقسيم الملف    | Splitting file in progress       |
| نقطة المنتصف عند    | Midpoint at (seconds)            |
| تمت العملية بنجاح   | Operation completed successfully |
| خطأ: الملف مش موجود | Error: File not found            |

## Parameters

| Parameter   | Required | Description                                |
| ----------- | -------- | ------------------------------------------ |
| `-FilePath` | Yes      | Full path to the audio/video file to split |

## Notes

- Existing output files will be **overwritten** automatically (uses `-y` flag)
- Audio quality is set to high (`-q:a 2`)
- Only audio streams are extracted (`-map a`)
- The original file remains unchanged

## Troubleshooting

**"ffmpeg is not recognized"**

- Install FFmpeg from https://ffmpeg.org/download.html
- Add FFmpeg to your system PATH

**"الملف مش موجود" (File not found)**

- Check that the file path is correct
- Use quotes around paths with spaces

---

# FFmpeg Quick Commands

## Extract Audio/Voice from Video

Extract audio from any video file and save it as MP3.

### Basic Syntax

```powershell
ffmpeg -i "input_video" -vn -acodec libmp3lame -q:a 2 "output.mp3"
```

### Parameters Explained

| Parameter            | Description                                            |
| -------------------- | ------------------------------------------------------ |
| `-i`                 | Input file path                                        |
| `-vn`                | No video (discard video stream)                        |
| `-acodec libmp3lame` | Use MP3 encoder                                        |
| `-q:a 2`             | Audio quality (0-9, lower = better, 2 is high quality) |

### Examples

**Extract audio from MKV:**

```powershell
ffmpeg -i "C:\Users\DELL\Videos\recording.mkv" -vn -acodec libmp3lame -q:a 2 "C:\Users\DELL\Videos\recording.mp3"
```

**Extract audio from MP4:**

```powershell
ffmpeg -i "C:\Videos\movie.mp4" -vn -acodec libmp3lame -q:a 2 "C:\Videos\movie_audio.mp3"
```

**Extract as WAV (lossless):**

```powershell
ffmpeg -i "C:\Videos\video.mkv" -vn -acodec pcm_s16le "C:\Videos\audio.wav"
```

**Extract as AAC:**

```powershell
ffmpeg -i "C:\Videos\video.mp4" -vn -acodec aac -b:a 192k "C:\Videos\audio.m4a"
```

### Output Formats

| Format | Command                     | Use Case                      |
| ------ | --------------------------- | ----------------------------- |
| MP3    | `-acodec libmp3lame -q:a 2` | General use, good compression |
| WAV    | `-acodec pcm_s16le`         | Lossless, editing             |
| AAC    | `-acodec aac -b:a 192k`     | High quality, smaller size    |
| FLAC   | `-acodec flac`              | Lossless, compressed          |

### Quality Settings for MP3

| `-q:a` Value | Bitrate (approx.) | Quality |
| ------------ | ----------------- | ------- |
| 0            | ~245 kbps         | Best    |
| 2            | ~190 kbps         | High    |
| 4            | ~165 kbps         | Good    |
| 6            | ~130 kbps         | Medium  |
| 9            | ~65 kbps          | Low     |

---

## Author

Created for easy audio splitting and conversion tasks.
