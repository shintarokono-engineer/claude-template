<#
.SYNOPSIS
  Apply this Claude Code template to a project directory.
.DESCRIPTION
  Copies .claude/, CLAUDE.md, mcp.example.json into the target.
  Never overwrites existing files.
.PARAMETER Target
  Path to the project directory.
.EXAMPLE
  ~\claude-template\apply.ps1 C:\path\to\project
#>
param(
  [Parameter(Mandatory = $true, Position = 0)]
  [string]$Target
)

$ErrorActionPreference = 'Stop'
$TemplateDir = Split-Path -Parent $MyInvocation.MyCommand.Path

if (-not (Test-Path -LiteralPath $Target -PathType Container)) {
  Write-Error "Target directory does not exist: $Target"
  exit 1
}

Write-Host "Applying template from $TemplateDir to $Target ..."

# .claude/ — recursive, no overwrite
$claudeSrc = Join-Path $TemplateDir '.claude'
$claudeDst = Join-Path $Target '.claude'

if (Test-Path -LiteralPath $claudeDst) {
  Write-Host "  .claude/ already exists, merging individual files (no overwrite)"
  Get-ChildItem -Path $claudeSrc -Recurse -File | ForEach-Object {
    $rel = $_.FullName.Substring($TemplateDir.Length + 1)
    $dst = Join-Path $Target $rel
    $dstDir = Split-Path -Parent $dst
    if (-not (Test-Path -LiteralPath $dstDir)) {
      New-Item -ItemType Directory -Force -Path $dstDir | Out-Null
    }
    if (Test-Path -LiteralPath $dst) {
      Write-Host "    skip (exists): $rel"
    } else {
      Copy-Item -LiteralPath $_.FullName -Destination $dst
      Write-Host "    add:           $rel"
    }
  }
} else {
  Copy-Item -LiteralPath $claudeSrc -Destination $claudeDst -Recurse
  Write-Host "  copied .claude/"
}

# Top-level files — no overwrite
foreach ($f in @('CLAUDE.md', 'mcp.example.json')) {
  $src = Join-Path $TemplateDir $f
  $dst = Join-Path $Target $f
  if (Test-Path -LiteralPath $dst) {
    Write-Host "  skip (exists):   $f"
  } else {
    Copy-Item -LiteralPath $src -Destination $dst
    Write-Host "  copied:          $f"
  }
}

Write-Host @"

Done. Next steps:
  1. Edit $Target\CLAUDE.md and replace the <...> placeholders.
  2. To enable MCP servers: rename mcp.example.json -> .mcp.json and edit.
  3. For personal overrides: copy .claude\settings.local.json.example -> .claude\settings.local.json
  4. Add to .gitignore (project-side):
       .claude/settings.local.json
       .mcp.json
"@
