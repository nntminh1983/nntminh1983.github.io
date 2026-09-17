<#
  prepare-photo.ps1

  Cat va thu nho anh chan dung cho website.

  Anh may anh thuong la anh ngang va nang vai MB. Khung anh tren web la khung
  doc, va mot trang tinh khong nen tai ve file lon nhu vay. Script nay cat anh
  ve dung ty le khung, thu nho lai, va luu thanh assets/photo.jpg.

  Cach dung:
      powershell -ExecutionPolicy Bypass -File prepare-photo.ps1 -Source "duong\dan\anh-goc.jpg"

  Tham so FaceY cho biet tam khuon mat nam o dau theo chieu doc cua anh goc
  (0.0 = dinh anh, 1.0 = day anh). Mac dinh 0.42 hop voi anh chan dung chup
  chinh dien thong thuong. Giam xuong neu anh bi cat mat phan dau.
#>

param(
    [Parameter(Mandatory = $true)][string]$Source,
    [string]$Destination = "$PSScriptRoot\assets\photo.jpg",
    [int]$Width   = 700,
    [double]$Ratio = 1.14,   # chieu cao / chieu rong, khop voi CSS
    [double]$FaceY = 0.42,
    [int]$Quality = 88
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

if (-not (Test-Path -LiteralPath $Source)) {
    Write-Error "Khong tim thay file: $Source"
    exit 1
}

$src = [System.Drawing.Image]::FromFile((Resolve-Path -LiteralPath $Source).Path)
try {
    Write-Host ("Anh goc : {0} x {1}" -f $src.Width, $src.Height)

    $targetAspect = 1.0 / $Ratio            # rong / cao
    $srcAspect    = $src.Width / $src.Height

    if ($srcAspect -gt $targetAspect) {
        # Anh rong hon khung -> cat bot hai ben, giu nguyen chieu cao
        $cropH = $src.Height
        $cropW = [int][Math]::Round($src.Height * $targetAspect)
        $cropX = [int][Math]::Round(($src.Width - $cropW) / 2.0)
        $cropY = 0
    }
    else {
        # Anh cao hon khung -> cat tren duoi, uu tien giu khuon mat
        $cropW = $src.Width
        $cropH = [int][Math]::Round($src.Width / $targetAspect)
        $cropX = 0
        $cropY = [int][Math]::Round(($src.Height * $FaceY) - ($cropH / 2.0))
        $cropY = [Math]::Max(0, [Math]::Min($cropY, $src.Height - $cropH))
    }

    Write-Host ("Vung cat: {0} x {1} tai ({2}, {3})" -f $cropW, $cropH, $cropX, $cropY)

    $outW = $Width
    $outH = [int][Math]::Round($Width * $Ratio)

    $bmp = New-Object System.Drawing.Bitmap($outW, $outH)
    $bmp.SetResolution(72, 72)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    try {
        $g.InterpolationMode  = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $g.SmoothingMode      = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
        $g.PixelOffsetMode    = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality

        $destRect = New-Object System.Drawing.Rectangle(0, 0, $outW, $outH)
        $g.DrawImage($src, $destRect, $cropX, $cropY, $cropW, $cropH,
                     [System.Drawing.GraphicsUnit]::Pixel)
    }
    finally { $g.Dispose() }

    $codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() |
             Where-Object { $_.MimeType -eq 'image/jpeg' }
    $params = New-Object System.Drawing.Imaging.EncoderParameters(1)
    $params.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter(
        [System.Drawing.Imaging.Encoder]::Quality, [int64]$Quality)

    $destDir = Split-Path -Parent $Destination
    if (-not (Test-Path -LiteralPath $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }

    $bmp.Save($Destination, $codec, $params)
    $bmp.Dispose()

    $kb = [Math]::Round((Get-Item -LiteralPath $Destination).Length / 1KB, 1)
    Write-Host ""
    Write-Host ("Da luu  : {0}" -f $Destination)
    Write-Host ("Kich thuoc: {0} x {1}, {2} KB" -f $outW, $outH, $kb)
}
finally {
    $src.Dispose()
}
