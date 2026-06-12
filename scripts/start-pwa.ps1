$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$PwaDir = Join-Path $ProjectRoot "pwa"
$PreferredPort = 4173

if (-not (Test-Path (Join-Path $PwaDir "index.html"))) {
  Write-Host "没有找到 pwa\index.html，请确认脚本在项目根目录内运行。" -ForegroundColor Red
  Read-Host "按回车退出"
  exit 1
}

$python = Get-Command python -ErrorAction SilentlyContinue
if (-not $python) {
  $python = Get-Command py -ErrorAction SilentlyContinue
}

if (-not $python) {
  Write-Host "没有找到 Python，无法启动本地静态服务。" -ForegroundColor Red
  Write-Host "可以安装 Python，或改用任意静态服务器托管 pwa 目录。"
  Read-Host "按回车退出"
  exit 1
}

function Test-PortAvailable {
  param([int]$Port)
  $listener = $null
  try {
    $listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Loopback, $Port)
    $listener.Start()
    return $true
  } catch {
    return $false
  } finally {
    if ($listener) {
      $listener.Stop()
    }
  }
}

$port = $PreferredPort
while (-not (Test-PortAvailable -Port $port)) {
  $port++
  if ($port -gt ($PreferredPort + 50)) {
    Write-Host "没有找到可用端口。" -ForegroundColor Red
    Read-Host "按回车退出"
    exit 1
  }
}

$arguments = @("-m", "http.server", "$port", "-d", $PwaDir)
if ($python.Name -eq "py.exe") {
  $arguments = @("-3") + $arguments
}

$url = "http://localhost:$port"
Write-Host "正在启动铝型材 DIY 设计器..." -ForegroundColor Green
Write-Host "地址：$url"
Write-Host "关闭这个窗口即可停止服务。"

Start-Process $url
& $python.Source @arguments
