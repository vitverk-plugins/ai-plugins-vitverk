$ErrorActionPreference = 'Stop'
try {
  $pluginName = 'vitverk'
  Write-Host ('Installing the plugin for ' + 'https://os.vitverk.is')
  $pluginCodex = Get-Command codex -ErrorAction SilentlyContinue
  if (-not $pluginCodex) { throw 'Codex CLI was not found. Install Codex CLI, then run this installer again.' }
  $pluginHome = $env:VITVERK_PLUGIN_HOME
  if (-not $pluginHome) { $pluginHome = Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'Vitverk\Plugins' }
  $pluginTarget = Join-Path $pluginHome $pluginName
  $pluginMarker = Join-Path $pluginTarget '.vitverk-installer'
  if (Test-Path -LiteralPath $pluginTarget) {
    $pluginItem = Get-Item -LiteralPath $pluginTarget
    if (($pluginItem.Attributes -band [IO.FileAttributes]::ReparsePoint) -or -not (Test-Path -LiteralPath $pluginMarker) -or (Get-Content -LiteralPath $pluginMarker -Raw).Trim() -ne $pluginName) {
      throw 'Refusing to replace an unmanaged installation folder.'
    }
  } else {
    New-Item -ItemType Directory -Path $pluginTarget -Force | Out-Null
    Set-Content -LiteralPath $pluginMarker -Value $pluginName
  }
  foreach ($pluginPath in @('.agents', 'plugins', 'README.md', 'Sign in to Codex.cmd')) {
    $pluginDestination = Join-Path $pluginTarget $pluginPath
    if ((Test-Path -LiteralPath $pluginDestination) -and ((Get-Item -LiteralPath $pluginDestination).Attributes -band [IO.FileAttributes]::ReparsePoint)) {
      throw 'Refusing a linked installation path.'
    }
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot $pluginPath) -Destination $pluginTarget -Recurse -Force
  }
  $pluginRegistered = Join-Path $pluginTarget '.codex-registered'
  if (-not (Test-Path -LiteralPath $pluginRegistered)) {
    & $pluginCodex.Source plugin marketplace add $pluginTarget
    if ($LASTEXITCODE -ne 0) { throw 'Codex catalog registration failed.' }
    Set-Content -LiteralPath $pluginRegistered -Value $pluginName
  }
  & $pluginCodex.Source plugin add "$pluginName@$pluginName"
  if ($LASTEXITCODE -ne 0) { throw 'Codex plugin installation failed.' }
  Write-Host ('Installed. Open ' + (Join-Path $pluginTarget 'Sign in to Codex.cmd') + ' to sign in through your browser.')
  Write-Host 'Then start a new Codex task. You can delete the extracted download.'
} catch {
  Write-Error $_ -ErrorAction Continue
  exit 1
}
