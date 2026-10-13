$ErrorActionPreference = 'Stop'
try {
  $vinnslanName = 'vitverk'
  Write-Host ('Installing Vinnslan for ' + 'https://vinnslan.vitverk.is')
  $vinnslanCodex = Get-Command codex -ErrorAction SilentlyContinue
  if (-not $vinnslanCodex) { throw 'Codex CLI was not found. Install Codex CLI, then run this installer again.' }
  $vinnslanHome = $env:VINNSLAN_PLUGIN_HOME
  if (-not $vinnslanHome) { $vinnslanHome = Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'Vinnslan\Plugins' }
  $vinnslanTarget = Join-Path $vinnslanHome $vinnslanName
  $vinnslanMarker = Join-Path $vinnslanTarget '.vinnslan-installer'
  if (Test-Path -LiteralPath $vinnslanTarget) {
    $vinnslanItem = Get-Item -LiteralPath $vinnslanTarget
    if (($vinnslanItem.Attributes -band [IO.FileAttributes]::ReparsePoint) -or -not (Test-Path -LiteralPath $vinnslanMarker) -or (Get-Content -LiteralPath $vinnslanMarker -Raw).Trim() -ne $vinnslanName) {
      throw 'Refusing to replace an unmanaged installation folder.'
    }
  } else {
    New-Item -ItemType Directory -Path $vinnslanTarget -Force | Out-Null
    Set-Content -LiteralPath $vinnslanMarker -Value $vinnslanName
  }
  foreach ($vinnslanPath in @('.agents', 'plugins', 'README.md', 'Sign in to Codex.cmd')) {
    $vinnslanDestination = Join-Path $vinnslanTarget $vinnslanPath
    if ((Test-Path -LiteralPath $vinnslanDestination) -and ((Get-Item -LiteralPath $vinnslanDestination).Attributes -band [IO.FileAttributes]::ReparsePoint)) {
      throw 'Refusing a linked installation path.'
    }
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot $vinnslanPath) -Destination $vinnslanTarget -Recurse -Force
  }
  $vinnslanRegistered = Join-Path $vinnslanTarget '.codex-registered'
  if (-not (Test-Path -LiteralPath $vinnslanRegistered)) {
    & $vinnslanCodex.Source plugin marketplace add $vinnslanTarget
    if ($LASTEXITCODE -ne 0) { throw 'Codex catalog registration failed.' }
    Set-Content -LiteralPath $vinnslanRegistered -Value $vinnslanName
  }
  & $vinnslanCodex.Source plugin add "$vinnslanName@$vinnslanName"
  if ($LASTEXITCODE -ne 0) { throw 'Codex plugin installation failed.' }
  Write-Host ('Installed. Open ' + (Join-Path $vinnslanTarget 'Sign in to Codex.cmd') + ' to sign in through your browser.')
  Write-Host 'Then start a new Codex task. You can delete the extracted download.'
} catch {
  Write-Error $_ -ErrorAction Continue
  exit 1
}
