# Voice Converter (SplitAndConvert.ps1)

Split any audio or video file into two equal halves and convert the audio to MP3 using FFmpeg.

## Features

- Splits input at the exact midpoint
- Converts both halves to MP3
- Works with audio and video files (audio stream only)
- Writes output next to the original file
- Overwrites existing output files

## Requirements

- FFmpeg (includes FFprobe) available in PATH
- Windows PowerShell or PowerShell Core

## Quick Start

```powershell
.\SplitAndConvert.ps1 -FilePath "C:\path\to\your\file"
```

## Usage

```powershell
.\SplitAndConvert.ps1 -FilePath "C:\Users\DELL\Music\podcast.mp3"
.\SplitAndConvert.ps1 -FilePath "C:\Users\DELL\Videos\lecture.mkv"
.\SplitAndConvert.ps1 -FilePath "C:\Users\DELL\Music\recording.wav"
```

## Parameters

| Parameter   | Required | Description                                |
| ----------- | -------- | ------------------------------------------ |
| -FilePath   | Yes      | Full path to the audio or video file       |

## Output

Two MP3 files are created in the same directory as the input file.

| Input File    | Output Files                              |
| ------------- | ----------------------------------------- |
| podcast.mp3   | podcast_Part1.mp3 + podcast_Part2.mp3     |
| lecture.mkv   | lecture_Part1.mp3 + lecture_Part2.mp3     |

## Notes

- Uses `-y` to overwrite existing output files
- High MP3 quality uses `-q:a 2`
- Extracts audio only with `-map a`
- Original file remains unchanged

## Console Output

Progress messages are shown in Arabic:

| Message             | Meaning                          |
| ------------------- | -------------------------------- |
| جاري تقسيم الملف    | Splitting file in progress       |
| نقطة المنتصف عند    | Midpoint at (seconds)            |
| تمت العملية بنجاح   | Operation completed successfully |
| خطأ: الملف مش موجود | Error: File not found            |

## Troubleshooting

**"ffmpeg is not recognized"**

- Install FFmpeg from https://ffmpeg.org/download.html
- Add FFmpeg to your system PATH

**"الملف مش موجود" (File not found)**

- Check the file path
- Use quotes around paths with spaces

---

## FFmpeg Quick Commands

### Extract Audio from Video (MP3)

```powershell
ffmpeg -i "input_video" -vn -acodec libmp3lame -q:a 2 "output.mp3"
```

### MP3 Quality Settings

| -q:a Value | Bitrate (approx.) | Quality |
| ---------- | ----------------- | ------- |
| 0          | ~245 kbps         | Best    |
| 2          | ~190 kbps         | High    |
| 4          | ~165 kbps         | Good    |
| 6          | ~130 kbps         | Medium  |
| 9          | ~65 kbps          | Low     |

## Author

Created for easy audio splitting and conversion tasks.
