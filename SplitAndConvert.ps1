# =============================================
#   Voice Converter Tool
# =============================================

$OutputDir = "C:\Users\DELL\Music"

# Ensure output folder exists
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

function Show-Banner {
    Write-Host ""
    Write-Host "  ===========================================" -ForegroundColor Cyan
    Write-Host "  Voice Converter Tool" -ForegroundColor Cyan
    Write-Host "  ===========================================" -ForegroundColor Cyan
    Write-Host ""
}

function Show-Menu {
    Write-Host "  Choose an option:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  [1] Convert to MP3" -ForegroundColor Green
    Write-Host "  [2] Split in half + MP3" -ForegroundColor Green
    Write-Host "  [3] Split into multiple parts + MP3" -ForegroundColor Green
    Write-Host "  [4] Extract audio (no re-encode)" -ForegroundColor Green
    Write-Host "  [5] Transcribe audio to text (MarkItDown)" -ForegroundColor Green
    Write-Host "  [6] Compress Video (Fast H.264)" -ForegroundColor Green
    Write-Host "  [7] Change Video/Audio Speed" -ForegroundColor Green
    Write-Host "  [8] Remove Noise + Compress" -ForegroundColor Green
    Write-Host "  [9] Exit" -ForegroundColor Red
    Write-Host ""
}

function Get-FilePath {
    Write-Host ""
    $path = Read-Host "  Enter input file path"
    $path = $path.Trim('"').Trim("'")

    if (-not (Test-Path $path)) {
        Write-Host "  Error: file not found." -ForegroundColor Red
        return $null
    }
    return $path
}

function Get-FileDuration {
    param([string]$Path)
    $duration = (ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 $Path)
    return [double]$duration
}

# ------------------------------------------
# 1. Convert to MP3
# ------------------------------------------
function Convert-ToMp3 {
    $filePath = Get-FilePath
    if (-not $filePath) { return }

    $fileName = [System.IO.Path]::GetFileNameWithoutExtension($filePath)
    $output = Join-Path $OutputDir "$($fileName).mp3"

    Write-Host ""
    Write-Host "  Converting..." -ForegroundColor Cyan

    ffmpeg -i $filePath -q:a 2 -map a $output -y 2>$null

    if ($LASTEXITCODE -eq 0) {
        Write-Host "  Done." -ForegroundColor Green
        Write-Host "  Output: $output" -ForegroundColor Yellow
    } else {
        Write-Host "  Error during conversion." -ForegroundColor Red
    }
}

# ------------------------------------------
# 2. Split in half + MP3
# ------------------------------------------
function Split-InHalf {
    $filePath = Get-FilePath
    if (-not $filePath) { return }

    $fileName = [System.IO.Path]::GetFileNameWithoutExtension($filePath)
    $totalSeconds = Get-FileDuration -Path $filePath
    $halfTime = [math]::Round($totalSeconds / 2, 2)

    Write-Host ""
    Write-Host "  Splitting file: $fileName" -ForegroundColor Cyan
    Write-Host "  Midpoint at: $halfTime seconds" -ForegroundColor Yellow

    $output1 = Join-Path $OutputDir "$($fileName)_Part1.mp3"
    $output2 = Join-Path $OutputDir "$($fileName)_Part2.mp3"

    ffmpeg -i $filePath -t $halfTime -q:a 2 -map a $output1 -y 2>$null
    ffmpeg -i $filePath -ss $halfTime -q:a 2 -map a $output2 -y 2>$null

    if ($LASTEXITCODE -eq 0) {
        Write-Host "  Done." -ForegroundColor Green
        Write-Host "  Output folder: $OutputDir" -ForegroundColor Yellow
    } else {
        Write-Host "  Error during split." -ForegroundColor Red
    }
}

# ------------------------------------------
# 3. Split into multiple parts + MP3
# ------------------------------------------
function Split-IntoParts {
    $filePath = Get-FilePath
    if (-not $filePath) { return }

    $fileName = [System.IO.Path]::GetFileNameWithoutExtension($filePath)
    $totalSeconds = Get-FileDuration -Path $filePath

    Write-Host ""
    $parts = Read-Host "  How many parts?"
    $parts = [int]$parts

    if ($parts -lt 2) {
        Write-Host "  Error: parts must be 2 or more." -ForegroundColor Red
        return
    }

    $partDuration = [math]::Round($totalSeconds / $parts, 2)

    Write-Host ""
    Write-Host "  Splitting into $parts parts..." -ForegroundColor Cyan
    Write-Host "  Each part: $partDuration seconds" -ForegroundColor Yellow

    for ($i = 0; $i -lt $parts; $i++) {
        $startTime = [math]::Round($i * $partDuration, 2)
        $partNum = $i + 1
        $output = Join-Path $OutputDir "$($fileName)_Part$($partNum).mp3"

        if ($i -eq ($parts - 1)) {
            # Last part runs to end
            ffmpeg -i $filePath -ss $startTime -q:a 2 -map a $output -y 2>$null
        } else {
            ffmpeg -i $filePath -ss $startTime -t $partDuration -q:a 2 -map a $output -y 2>$null
        }

        Write-Host "  Done: Part $partNum" -ForegroundColor DarkGreen
    }

    Write-Host ""
    Write-Host "  Split completed." -ForegroundColor Green
    Write-Host "  Output folder: $OutputDir" -ForegroundColor Yellow
}

# ------------------------------------------
# 4. Extract audio without re-encoding
# ------------------------------------------
function Extract-Audio {
    $filePath = Get-FilePath
    if (-not $filePath) { return }

    $fileName = [System.IO.Path]::GetFileNameWithoutExtension($filePath)

    # Detect input audio codec
    $audioCodec = (ffprobe -v error -select_streams a:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 $filePath)

    # Choose extension based on codec
    $ext = switch ($audioCodec) {
        "aac"    { "m4a" }
        "mp3"    { "mp3" }
        "opus"   { "opus" }
        "vorbis" { "ogg" }
        "flac"   { "flac" }
        default  { "mka" }
    }

    $output = Join-Path $OutputDir "$($fileName).$ext"

    Write-Host ""
    Write-Host "  Extracting audio ($audioCodec)..." -ForegroundColor Cyan

    ffmpeg -i $filePath -vn -acodec copy $output -y 2>$null

    if ($LASTEXITCODE -eq 0) {
        Write-Host "  Done." -ForegroundColor Green
        Write-Host "  Output: $output" -ForegroundColor Yellow

        Write-Host ""
        $transcribe = Read-Host "  Transcribe audio to text with MarkItDown? [y/n]"
        if ($transcribe -eq "y") {
            Transcribe-WithMarkItDown -AudioPath $output
        }
    } else {
        Write-Host "  Error during extraction." -ForegroundColor Red
    }
}

# ------------------------------------------
# 5. Transcribe audio to text via MarkItDown
# ------------------------------------------
function Transcribe-WithMarkItDown {
    param([string]$AudioPath = "")

    if (-not $AudioPath) {
        $AudioPath = Get-FilePath
        if (-not $AudioPath) { return }
    }

    # Check if markitdown CLI is available
    $markitdownAvailable = Get-Command markitdown -ErrorAction SilentlyContinue
    if (-not $markitdownAvailable) {
        Write-Host ""
        Write-Host "  markitdown is not installed." -ForegroundColor Yellow
        $install = Read-Host "  Install markitdown[audio-transcription] now? [y/n]"
        if ($install -eq "y") {
            Write-Host "  Installing..." -ForegroundColor Cyan
            python -m pip install "markitdown[audio-transcription]"
            if ($LASTEXITCODE -ne 0) {
                Write-Host "  Installation failed. Make sure Python/pip is in PATH." -ForegroundColor Red
                return
            }
        } else {
            return
        }
    }

    $fileName = [System.IO.Path]::GetFileNameWithoutExtension($AudioPath)
    $output   = Join-Path $OutputDir "$($fileName)_transcript.md"

    Write-Host ""
    Write-Host "  Transcribing audio with MarkItDown..." -ForegroundColor Cyan
    Write-Host "  (This may take a moment depending on file length)" -ForegroundColor DarkGray

    markitdown $AudioPath -o $output 2>$null

    if ($LASTEXITCODE -eq 0) {
        Write-Host "  Done." -ForegroundColor Green
        Write-Host "  Transcript saved to: $output" -ForegroundColor Yellow
    } else {
        Write-Host "  Error during transcription." -ForegroundColor Red
        Write-Host "  Tip: Run  pip install 'markitdown[audio-transcription]'  and ensure Python is in PATH." -ForegroundColor DarkYellow
    }
}

# ------------------------------------------
# 6. Compress video
# ------------------------------------------
function Compress-Video {
    $filePath = Get-FilePath
    if (-not $filePath) { return }

    $fileName = [System.IO.Path]::GetFileNameWithoutExtension($filePath)
    $output = Join-Path $OutputDir "$($fileName)_compressed.mp4"

    Write-Host ""
    Write-Host "  Compressing video... This might take a few minutes depending on the video length." -ForegroundColor Cyan

    ffmpeg -i $filePath -c:v libx264 -crf 23 -preset veryfast -c:a aac -b:a 128k $output -y

    if ($LASTEXITCODE -eq 0) {
        Write-Host "  Done." -ForegroundColor Green
        Write-Host "  Output: $output" -ForegroundColor Yellow
    } else {
        Write-Host "  Error during compression." -ForegroundColor Red
    }
}

# ------------------------------------------
# 7. Change video/audio speed
# ------------------------------------------
function Change-VideoSpeed {
    $filePath = Get-FilePath
    if (-not $filePath) { return }

    Write-Host ""
    $speedInput = Read-Host "  Enter speed multiplier (0.5 - 100) e.g. 1.25, 1.5, 0.5"
    $speedInput = $speedInput.Trim()

    # Handle locale: users may enter 1,5 instead of 1.5
    $speedInput = $speedInput -replace ",", "."

    $speed = 0.0
    if (-not [double]::TryParse(
        $speedInput,
        [System.Globalization.NumberStyles]::Float,
        [System.Globalization.CultureInfo]::InvariantCulture,
        [ref]$speed
    )) {
        Write-Host "  Error: invalid speed value." -ForegroundColor Red
        return
    }

    if ($speed -lt 0.5 -or $speed -gt 100) {
        Write-Host "  Error: speed must be between 0.5 and 100." -ForegroundColor Red
        return
    }

    $fileName = [System.IO.Path]::GetFileNameWithoutExtension($filePath)
    $speedLabel = $speed.ToString("0.###", [System.Globalization.CultureInfo]::InvariantCulture)
    $output = Join-Path $OutputDir "$($fileName)_speed$($speedLabel).mp4"

    # Build atempo chain (each atempo supports 0.5..2.0)
    $remaining = $speed
    $atempoParts = @()
    while ($remaining -gt 2.0) {
        $atempoParts += "atempo=2.0"
        $remaining = $remaining / 2.0
    }
    $remainingLabel = $remaining.ToString("0.########", [System.Globalization.CultureInfo]::InvariantCulture)
    $atempoParts += "atempo=$remainingLabel"
    $atempoFilter = ($atempoParts -join ",")

    $speedFilterLabel = $speed.ToString("0.########", [System.Globalization.CultureInfo]::InvariantCulture)
    $filterComplex = "[0:v]setpts=PTS/$speedFilterLabel[v];[0:a]$atempoFilter[a]"

    Write-Host ""
    Write-Host "  Changing speed to x$speedLabel..." -ForegroundColor Cyan

    ffmpeg -i $filePath -filter_complex $filterComplex -map "[v]" -map "[a]" -c:v libx264 -crf 23 -preset veryfast -c:a aac -b:a 128k $output -y

    if ($LASTEXITCODE -eq 0) {
        Write-Host "  Done." -ForegroundColor Green
        Write-Host "  Output: $output" -ForegroundColor Yellow
    } else {
        Write-Host "  Error changing speed." -ForegroundColor Red
    }
}

# ------------------------------------------
# 8. Remove noise + compress
# ------------------------------------------
function Remove-NoiseAndCompress {
    $filePath = Get-FilePath
    if (-not $filePath) { return }

    $fileName = [System.IO.Path]::GetFileNameWithoutExtension($filePath)

    # Detect a real video stream (cover art shows up as a fake one)
    $videoCodec = (ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 $filePath)
    $hasVideo = $videoCodec -and ($videoCodec -notin @("png", "mjpeg", "bmp", "gif", "webp"))

    Write-Host ""
    Write-Host "  Noise removal level:" -ForegroundColor Yellow
    Write-Host "  [1] Light" -ForegroundColor Green
    Write-Host "  [2] Medium (default)" -ForegroundColor Green
    Write-Host "  [3] Strong" -ForegroundColor Green
    Write-Host ""
    $level = (Read-Host "  Your choice").Trim()
    if (-not $level) { $level = "2" }

    $filter = switch ($level) {
        "1" { "highpass=f=80,afftdn=nr=6:nf=-30:tn=1" }
        "2" { "highpass=f=80,afftdn=nr=12:nf=-25:tn=1" }
        "3" { "highpass=f=90,afftdn=nr=24:nf=-20:tn=1,anlmdn=s=0.0002" }
        default { $null }
    }

    if (-not $filter) {
        Write-Host "  Error: invalid level. Pick 1-3." -ForegroundColor Red
        return
    }

    Write-Host ""

    if ($hasVideo) {
        $output = Join-Path $OutputDir "$($fileName)_clean.mp4"
        Write-Host "  Cleaning audio and compressing video... This might take a few minutes." -ForegroundColor Cyan
        ffmpeg -i $filePath -af $filter -c:v libx264 -crf 26 -preset veryfast -c:a aac -b:a 96k $output -y
    } else {
        $output = Join-Path $OutputDir "$($fileName)_clean.opus"
        Write-Host "  Cleaning audio and compressing..." -ForegroundColor Cyan
        ffmpeg -i $filePath -vn -af $filter -ac 1 -ar 16000 -c:a libopus -b:a 32k -vbr on -application voip $output -y 2>$null
    }

    if ($LASTEXITCODE -eq 0) {
        $before = (Get-Item $filePath).Length / 1MB
        $after  = (Get-Item $output).Length / 1MB
        $saved  = 0
        if ($before -gt 0) { $saved = (1 - ($after / $before)) * 100 }

        Write-Host "  Done." -ForegroundColor Green
        Write-Host "  Output: $output" -ForegroundColor Yellow
        Write-Host "  Size: $($before.ToString('0.##')) MB -> $($after.ToString('0.##')) MB (saved $($saved.ToString('0.#'))%)" -ForegroundColor Yellow
    } else {
        Write-Host "  Error during noise removal." -ForegroundColor Red
    }
}

# ==========================================
#   Main Loop
# ==========================================

Show-Banner

while ($true) {
    Show-Menu
    $choice = Read-Host "  Your choice"

    switch ($choice) {
        "1" { Convert-ToMp3 }
        "2" { Split-InHalf }
        "3" { Split-IntoParts }
        "4" { Extract-Audio }
        "5" { Transcribe-WithMarkItDown }
        "6" { Compress-Video }
        "7" { Change-VideoSpeed }
        "8" { Remove-NoiseAndCompress }
        "9" {
            Write-Host ""
            Write-Host "  Goodbye." -ForegroundColor Cyan
            Write-Host ""
            return
        }
        default {
            Write-Host "  Invalid choice. Pick 1-9." -ForegroundColor Red
        }
    }

    Write-Host ""
    Write-Host "  --------------------------------------" -ForegroundColor DarkGray
}