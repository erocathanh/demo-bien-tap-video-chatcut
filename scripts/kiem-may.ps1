[Console]::OutputEncoding = [Text.Encoding]::UTF8
# kiem-may.ps1 - READ-ONLY machine check for Windows PowerShell 5.1 (same verdict and exit code as kiem-may.sh).
# Run:  powershell -NoProfile -ExecutionPolicy Bypass -File scripts\kiem-may.ps1
# Bypass applies to this one process only; nothing on the machine is changed. Saved as UTF-8 WITH BOM on purpose:
# PowerShell 5.1 reads BOM-less files as ANSI and breaks the Vietnamese text.
$ErrorActionPreference = 'SilentlyContinue'
$SkillDir = Split-Path -Parent $PSScriptRoot

$reqMissing = $false; $optMissing = $false; $canEdit = $true; $canIcon = $true; $restart = $false
$installs = New-Object System.Collections.Generic.List[string]

function Line($mark, $name, $found, $need, $note) {
  $s = "$mark $name"
  if ($found) { $s = "$s $found" }
  if ($need) { $s = "$s ($need)" }
  Write-Output "$s - $note"
}
function Has($cmd) { return [bool](Get-Command $cmd -ErrorAction SilentlyContinue) }
function FirstLine($text) { if ($null -eq $text) { return '' }; return ((@($text)[0]) -replace "`r", '').Trim() }
function VersionGe($a, $b) {
  try { return ([version]($a -replace '[^0-9.]', '')) -ge ([version]$b) } catch { return $false }
}

$arch = $env:PROCESSOR_ARCHITEW6432; if (-not $arch) { $arch = $env:PROCESSOR_ARCHITECTURE }
Write-Output "KIỂM MÁY - chỉ xem, không cài gì (win, $arch)"
Write-Output "----------------------------------------"

# 1. Git
if (Has 'git') { Line '✅' 'Git' ((FirstLine (git --version)) -replace 'git version ', '') 'có' 'ổn' }
else { Line '❌' 'Git' '-' 'có' 'chưa cài'; $reqMissing = $true; $installs.Add('winget install -e --accept-source-agreements --accept-package-agreements --id Git.Git') }

# 2. Node.js
if (Has 'node') {
  $nv = (FirstLine (node -v)) -replace 'v', ''
  if (VersionGe $nv '18.0') { Line '✅' 'Node.js' $nv 'cần ≥ 18' 'ổn' }
  else { Line '❌' 'Node.js' $nv 'cần ≥ 18' 'bản cũ quá'; $reqMissing = $true; $canEdit = $false; $canIcon = $false; $installs.Add('winget install -e --accept-source-agreements --accept-package-agreements --id OpenJS.NodeJS.LTS') }
} elseif (Test-Path "$env:ProgramFiles\nodejs\node.exe") {
  Line '⚠️' 'Node.js' 'đã cài' 'cần ≥ 18' 'ĐÃ CÀI nhưng cửa sổ Claude này chưa thấy => thoát hẳn Claude rồi mở lại'
  $reqMissing = $true; $restart = $true; $canEdit = $false; $canIcon = $false
} else {
  Line '❌' 'Node.js' '-' 'cần ≥ 18' 'chưa cài (xưởng dựng video + công cụ tải phim của ChatCut cần nó)'
  $reqMissing = $true; $canEdit = $false; $canIcon = $false; $installs.Add('winget install -e --accept-source-agreements --accept-package-agreements --id OpenJS.NodeJS.LTS')
}

# 3. FFmpeg
if ((Has 'ffprobe') -and (Has 'ffmpeg')) {
  $fv = ((FirstLine (ffprobe -version)) -split ' ')[2]
  Line '✅' 'FFmpeg' $fv 'có' 'ổn'
} elseif (Get-ChildItem "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\Gyan.FFmpeg*\*\bin\ffprobe.exe" -ErrorAction SilentlyContinue) {
  Line '⚠️' 'FFmpeg' 'đã cài' 'có' 'ĐÃ CÀI nhưng cửa sổ Claude này chưa thấy => thoát hẳn Claude rồi mở lại'
  $reqMissing = $true; $restart = $true; $canIcon = $false
} else {
  Line '❌' 'FFmpeg' '-' 'có' 'chưa cài (đọc và kiểm tra video)'
  $reqMissing = $true; $canIcon = $false; $installs.Add('winget install -e --accept-source-agreements --accept-package-agreements --id Gyan.FFmpeg')
}

# 4. Python 3.8+ (the Microsoft Store stub python3 exits 49 and is rejected by running it)
$py = $null
foreach ($c in @('python3', 'python', 'py')) {
  if (Has $c) {
    if ($c -eq 'py') { & py -3 -c "import sys; sys.exit(sys.version_info < (3,8))" 2>$null } else { & $c -c "import sys; sys.exit(sys.version_info < (3,8))" 2>$null }
    if ($LASTEXITCODE -eq 0) { $py = $c; break }
  }
}
if ($py) {
  if ($py -eq 'py') { $pv = FirstLine (& py -3 -c "import sys;print('%d.%d.%d'%sys.version_info[:3])") ; $pyShow = 'py -3' }
  else { $pv = FirstLine (& $py -c "import sys;print('%d.%d.%d'%sys.version_info[:3])"); $pyShow = $py }
  Line '✅' 'Python 3' $pv 'cần ≥ 3.8' "ổn (lệnh: $pyShow)"
} elseif (Get-ChildItem "$env:LOCALAPPDATA\Programs\Python\Python3*\python.exe" -ErrorAction SilentlyContinue) {
  Line '⚠️' 'Python 3' 'đã cài' 'cần ≥ 3.8' 'ĐÃ CÀI nhưng cửa sổ Claude này chưa thấy => thoát hẳn Claude rồi mở lại'
  $reqMissing = $true; $restart = $true; $canIcon = $false
} else {
  Line '❌' 'Python 3' '-' 'cần ≥ 3.8' 'chưa cài (công cụ phụ: chia phụ đề, làm bảng hình)'
  $reqMissing = $true; $canIcon = $false; $installs.Add('winget install -e --accept-source-agreements --accept-package-agreements --id Python.Python.3.12 --scope user')
}

# 5. Pillow + Whisper (optional)
if ($py) {
  if ($py -eq 'py') { $plv = FirstLine (& py -3 -c "import PIL;print(PIL.__version__)" 2>$null) } else { $plv = FirstLine (& $py -c "import PIL;print(PIL.__version__)" 2>$null) }
  if ($plv) { Line '✅' 'Pillow' $plv 'tuỳ chọn' 'ổn (làm bảng hình có nhãn giây)' }
  else { Line '➖' 'Pillow' '-' 'tuỳ chọn' 'chưa cài => chỉ thiếu bảng hình soát khung; video vẫn làm được'; $optMissing = $true; $installs.Add("$pyShow -m pip install pillow") }
}
if (Has 'whisper') { Line '✅' 'Whisper' 'có' 'tuỳ chọn' 'ổn (nghe lại lời trong video)' }
else {
  Line '➖' 'Whisper' '-' 'tuỳ chọn' 'chưa cài => bỏ qua được; chỉ để kiểm lời (cài mất khoảng 9 phút trên máy thử Windows; lần dùng đầu tải thêm mô hình ~480 MB)'; $optMissing = $true
  # Whisper installs on Python 3.10-3.13 only
  if ($py -and ($pv -match '^3\.1[0-3]\.')) { $installs.Add("$pyShow -m pip install -U openai-whisper   (lâu: khoảng 9 phút — chạy riêng, thời hạn 10 phút hoặc chạy nền)") }
}

# 6. Vietnamese text
if ($env:PYTHONUTF8 -eq '1') { Line '✅' 'Chữ tiếng Việt' 'PYTHONUTF8=1' '' 'ổn' }
else { Line '⚠️' 'Chữ tiếng Việt' 'chưa đặt' 'PYTHONUTF8=1' 'các script của skill tự bật; nên đặt sẵn cho Whisper'; $optMissing = $true; $installs.Add('setx PYTHONUTF8 1') }

# 7. Disk space
$drive = (Get-Item $SkillDir).PSDrive
if ($drive) {
  $freeGb = [math]::Floor($drive.Free / 1GB)
  if ($freeGb -ge 3) { Line '✅' 'Ổ đĩa trống' "$freeGb GB" 'cần ≥ 3 GB' 'ổn' }
  else { Line '❌' 'Ổ đĩa trống' "$freeGb GB" 'cần ≥ 3 GB' 'thiếu chỗ cho bộ dựng video'; $reqMissing = $true; $canIcon = $false }
}

# 7b. Where the skill lives: OneDrive sync and Vietnamese folder names break long builds (m22)
if ($SkillDir -match 'OneDrive') { Line '⚠️' 'Chỗ đặt bộ công cụ' 'trong OneDrive' '' 'OneDrive đồng bộ hàng nghìn tệp của bộ dựng video => nên chép sang %USERPROFILE%\.claude\skills' }
elseif ($SkillDir -match '[^\x00-\x7F]') { Line '⚠️' 'Chỗ đặt bộ công cụ' 'đường dẫn có dấu tiếng Việt' '' 'vài công cụ đọc sai đường có dấu => nên chép sang %USERPROFILE%\.claude\skills' }
else { Line '✅' 'Chỗ đặt bộ công cụ' '' '' 'ổn' }

# 8. CPU architecture
if ($arch -eq 'ARM64') { Line '❌' 'Kiến trúc' 'arm64' 'x64' 'Remotion không chạy trên Windows ARM => chỉ làm được «Sửa phim bằng sửa chữ»'; $canIcon = $false; $reqMissing = $true }
else { Line '✅' 'Kiến trúc' $arch '' 'bộ dựng video chạy được' }

# 9. Remotion packages for this system
$nm = Join-Path $SkillDir 'scripts\remotion\node_modules'
if (Test-Path $nm) {
  if (Test-Path (Join-Path $nm '@remotion\compositor-win32-x64-msvc')) { Line '✅' 'Bộ dựng video' 'đã cài' '' 'ổn' }
  else { Line '⚠️' 'Bộ dựng video' 'sai hệ' '' 'thư mục node_modules không phải của máy này => cài lại: cd scripts\remotion ; npm.cmd ci'; $canIcon = $false; $reqMissing = $true }
} else { Line '➖' 'Bộ dựng video' 'chưa cài' '' 'sẽ cài ở bước sau (npm ci, 1-3 phút)' }

# 10. ChatCut plugin
$helper = Get-ChildItem "$env:USERPROFILE\.claude\plugins\cache\chatcut-inc\chatcut\*\skills\asset-import\scripts\upload-media.mjs" -ErrorAction SilentlyContinue | Select-Object -Last 1
if ($helper) {
  $pver = $helper.FullName -replace '.*\\chatcut\\([^\\]+)\\skills\\.*', '$1'
  Line '✅' 'Plugin ChatCut' $pver '' 'ổn'
  if ((-not (Has 'ffmpeg')) -and (-not (Test-Path (Join-Path $helper.DirectoryName 'ffmpeg') -PathType Container))) {
    Line '⚠️' '  (tải phim)' '' '' 'plugin trên Windows thiếu FFmpeg đi kèm (lỗi plugin P1) => cần cài FFmpeg'
  }
} else {
  Line '❌' 'Plugin ChatCut' '-' '' 'chưa cài => trong Claude: /plugin, cài ChatCut, rồi /mcp -> Authenticate'
  $canEdit = $false; $canIcon = $false; $reqMissing = $true
}

# 11. Line endings
if ((Test-Path (Join-Path $SkillDir '.git')) -and (Has 'git')) {
  if (Test-Path (Join-Path $SkillDir '.gitattributes')) { Line '✅' 'Xuống dòng (git)' 'LF' '' 'ổn' }
  else { Line '⚠️' 'Xuống dòng (git)' (FirstLine (git -C $SkillDir config core.autocrlf)) '' 'bản tải về cũ, md5 trong MANIFEST có thể lệch => tải lại bản mới'; $optMissing = $true }
}

Write-Output "----------------------------------------"
$v1 = 'được'; if (-not $canEdit) { $v1 = 'CHƯA' }
$v2 = 'được'; if (-not $canIcon) { $v2 = 'CHƯA' }
Write-Output "KẾT LUẬN: «Sửa phim bằng sửa chữ»: $v1 · «Video icon kể chuyện»: $v2"
if ($restart) { Write-Output 'LƯU Ý: có phần mềm đã cài nhưng cửa sổ Claude này chưa thấy => thoát hẳn Claude, mở lại, dán lại đúng câu đã gõ lúc đầu (mở lại cuộc trò chuyện cũ hay mở cuộc mới đều được).' }
foreach ($i in $installs) { Write-Output "CÀI: $i" }

if ($reqMissing) { exit 1 }
if ($optMissing) { exit 2 }
exit 0
