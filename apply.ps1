<#
.SYNOPSIS
  Apply this Claude Code template to a project directory.
.DESCRIPTION
  Copies .claude/, CLAUDE.md, mcp.example.json into the target.
  Never overwrites existing files.
  Fetches default official skills from anthropics/skills unless -NoOfficial
  is given. -Add accepts a comma-separated list of opt-in official skills
  (docx, pdf, pptx, xlsx).
.PARAMETER Target
  Path to the project directory.
.PARAMETER NoOfficial
  Skip fetching official skills from anthropics/skills.
.PARAMETER Add
  Comma-separated list of opt-in official skills to install in addition to
  the defaults. Allowed: docx, pdf, pptx, xlsx.
.EXAMPLE
  ~\claude-template\apply.ps1 C:\path\to\project
.EXAMPLE
  ~\claude-template\apply.ps1 C:\path\to\project -Add docx,pdf
.EXAMPLE
  ~\claude-template\apply.ps1 C:\path\to\project -NoOfficial
#>
param(
  [Parameter(Mandatory = $true, Position = 0)]
  [string]$Target,
  [switch]$NoOfficial,
  [string[]]$Add = @()
)

$ErrorActionPreference = 'Stop'
$TemplateDir = Split-Path -Parent $MyInvocation.MyCommand.Path

$DefaultOfficial = @('skill-creator', 'mcp-builder', 'frontend-design', 'webapp-testing', 'doc-coauthoring')
$OptinOfficial = @('docx', 'pdf', 'pptx', 'xlsx')
$Allowed = $DefaultOfficial + $OptinOfficial
$OfficialRepo = 'https://github.com/anthropics/skills.git'

if (-not (Test-Path -LiteralPath $Target -PathType Container)) {
  Write-Error "Target directory does not exist: $Target"
  exit 1
}

# Validate -Add entries
foreach ($s in $Add) {
  if ([string]::IsNullOrWhiteSpace($s)) { continue }
  if ($Allowed -notcontains $s) {
    Write-Error "Unknown -Add skill: $s. Allowed: $($Allowed -join ', ')"
    exit 1
  }
}

Write-Host "Applying template from $TemplateDir to $Target ..."

# .claude/ — recursive, no overwrite
$claudeSrc = Join-Path $TemplateDir '.claude'
$claudeDst = Join-Path $Target '.claude'

if (Test-Path -LiteralPath $claudeDst) {
  Write-Host "  .claude/ already exists, merging individual files (no overwrite)"
  Get-ChildItem -Path $claudeSrc -Recurse -File -Force | ForEach-Object {
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

# Fetch official skills
if (-not $NoOfficial) {
  Write-Host ""
  Write-Host "Fetching official skills from $OfficialRepo ..."

  $tmp = Join-Path $env:TEMP ("claude-skills-" + [System.Guid]::NewGuid().ToString('N'))
  New-Item -ItemType Directory -Force -Path $tmp | Out-Null

  try {
    $cloneArgs = @('clone', '--depth', '1', '--quiet', $OfficialRepo, (Join-Path $tmp 'repo'))
    & git @cloneArgs 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
      throw "git clone failed (exit $LASTEXITCODE)"
    }

    $skillsDir = Join-Path $tmp 'repo\skills'
    $toInstall = $DefaultOfficial + ($Add | Where-Object { $_ })
    foreach ($skill in $toInstall) {
      $src = Join-Path $skillsDir $skill
      $dst = Join-Path $claudeDst "skills\$skill"
      if (Test-Path -LiteralPath $dst) {
        Write-Host "  skip official (exists): $skill"
      } elseif (Test-Path -LiteralPath $src -PathType Container) {
        Copy-Item -LiteralPath $src -Destination $dst -Recurse
        Write-Host "  added official:         $skill"
      } else {
        Write-Host "  not found in official repo: $skill"
      }
    }
  } catch {
    Write-Host "  Failed to fetch official skills (offline?): $_"
    Write-Host "  Skipping. Re-run later or use -NoOfficial."
  } finally {
    if (Test-Path -LiteralPath $tmp) {
      Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue
    }
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
