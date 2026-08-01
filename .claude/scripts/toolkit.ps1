<#
  agent-builder toolkit helper (Windows)

  Verb-for-verb twin of toolkit.sh. Both scripts print the SAME output for the
  same verb, so the /create-agent walkthrough branches on identical strings
  regardless of platform and never has to embed raw shell.

  Always invoke as:
    powershell -ExecutionPolicy Bypass -File .claude\scripts\toolkit.ps1 <verb> [args]

  The -ExecutionPolicy Bypass is required, not optional paranoia: files
  extracted from a zip downloaded off the internet carry the Mark of the Web,
  and the default RemoteSigned policy refuses to run them. Bypass applies only
  to this one invocation of this one file.
#>

param(
  [Parameter(Position = 0)]
  [string]$Verb = '',

  [Parameter(Position = 1, ValueFromRemainingArguments = $true)]
  [string[]]$Args = @()
)

$ErrorActionPreference = 'Stop'

function Test-GitPresent {
  $null = Get-Command git -ErrorAction SilentlyContinue
  if (-not $?) { return $false }
  try {
    git --version *> $null
    return $LASTEXITCODE -eq 0
  } catch {
    return $false
  }
}

function Test-InRepo {
  try {
    git rev-parse --git-dir *> $null
    return $LASTEXITCODE -eq 0
  } catch {
    return $false
  }
}

function Test-NothingStaged {
  git diff --cached --quiet *> $null
  return $LASTEXITCODE -eq 0
}

# ---------------------------------------------------------------------------
# git-probe - report environment without changing anything.
# Windows has no equivalent of the macOS stub-git problem, so a direct check is
# safe here. Output contract matches toolkit.sh exactly.
# ---------------------------------------------------------------------------
function Invoke-GitProbe {
  if (-not (Test-GitPresent)) {
    Write-Output 'git=missing'
    Write-Output 'identity=unknown'
    Write-Output 'repo=unknown'
    return
  }

  Write-Output 'git=ready'

  $name = (git config user.name 2>$null)
  $email = (git config user.email 2>$null)
  if ($name -and $email) {
    Write-Output 'identity=set'
  } else {
    Write-Output 'identity=missing'
  }

  if (Test-InRepo) { Write-Output 'repo=yes' } else { Write-Output 'repo=no' }
}

function Invoke-GitSetup {
  param([string]$Name, [string]$Email)

  if (-not (Test-InRepo)) { git init --quiet }

  if ($Name)  { git config --local user.name  $Name }
  if ($Email) { git config --local user.email $Email }

  git add -A
  if (Test-NothingStaged) {
    Write-Output 'result=nothing-to-commit'
  } else {
    git commit --quiet -m 'Starting point: agent-builder toolkit'
    Write-Output 'result=committed'
  }
}

function Invoke-Checkpoint {
  param([string]$Message = 'Checkpoint')

  if (-not (Test-GitPresent) -or -not (Test-InRepo)) {
    Write-Output 'result=skipped-no-git'
    return
  }

  git add -A
  if (Test-NothingStaged) {
    Write-Output 'result=nothing-to-commit'
  } else {
    git commit --quiet -m $Message
    Write-Output 'result=committed'
  }
}

function Invoke-FinalCommit {
  param([string]$Message = 'Complete V1')

  if (-not (Test-GitPresent) -or -not (Test-InRepo)) {
    Write-Output 'result=skipped-no-git'
    return
  }

  git add -A
  if (Test-NothingStaged) {
    Write-Output 'result=nothing-to-commit'
  } else {
    git commit --quiet -m $Message
    Write-Output 'result=committed'
  }

  Write-Output '--- history ---'
  git log --oneline
}

function Invoke-Scaffold {
  param([string]$SessionsDir)

  $dirs = @(
    '.claude\commands', '.claude\agents', '.claude\skills',
    '.claude\knowledge', 'project-plan'
  )
  if ($SessionsDir) { $dirs += $SessionsDir }

  foreach ($d in $dirs) {
    if (-not (Test-Path $d)) { New-Item -ItemType Directory -Path $d -Force | Out-Null }
  }

  Write-Output 'result=scaffolded'
}

function Invoke-SettingsInit {
  $template = '.claude\knowledge\templates\settings.template.json'

  if (-not (Test-Path $template)) {
    Write-Output 'result=template-missing'
    exit 1
  }

  if (-not (Test-Path '.claude')) {
    New-Item -ItemType Directory -Path '.claude' -Force | Out-Null
  }
  Copy-Item $template '.claude\settings.json' -Force
  Write-Output 'result=installed'
}

function Invoke-CopyToolkit {
  param([string]$Dest)

  if (-not $Dest) {
    Write-Output 'result=error-no-destination'
    exit 1
  }

  foreach ($sub in @('commands', 'skills', 'scripts')) {
    $path = Join-Path $Dest ".claude\$sub"
    if (-not (Test-Path $path)) { New-Item -ItemType Directory -Path $path -Force | Out-Null }
  }

  foreach ($c in @('review-workflow', 'save-workflow', 'improve-workflow')) {
    Copy-Item ".claude\commands\$c.md" (Join-Path $Dest '.claude\commands') -Force
  }

  $skills = @('create-agent', 'workflow-reviewer', 'save-progress',
              'security-checker', 'software-best-practices', 'workflow-improver')
  foreach ($s in $skills) {
    Copy-Item ".claude\skills\$s" (Join-Path $Dest '.claude\skills') -Recurse -Force
  }

  Copy-Item '.claude\agents'   (Join-Path $Dest '.claude') -Recurse -Force
  Copy-Item '.claude\knowledge' (Join-Path $Dest '.claude') -Recurse -Force
  Copy-Item '.claude\scripts\toolkit.sh'  (Join-Path $Dest '.claude\scripts') -Force
  Copy-Item '.claude\scripts\toolkit.ps1' (Join-Path $Dest '.claude\scripts') -Force

  if (Test-Path '.gitignore') { Copy-Item '.gitignore' $Dest -Force }

  Write-Output 'result=copied'
}

switch ($Verb) {
  'git-probe'     { Invoke-GitProbe }
  'git-setup'     { Invoke-GitSetup -Name $Args[0] -Email $Args[1] }
  'checkpoint'    { Invoke-Checkpoint -Message $Args[0] }
  'final-commit'  { Invoke-FinalCommit -Message $Args[0] }
  'scaffold'      { Invoke-Scaffold -SessionsDir $Args[0] }
  'settings-init' { Invoke-SettingsInit }
  'copy-toolkit'  { Invoke-CopyToolkit -Dest $Args[0] }
  default {
    Write-Error 'Usage: powershell -ExecutionPolicy Bypass -File .claude\scripts\toolkit.ps1 <verb> [args]'
    Write-Error 'Verbs: git-probe, git-setup, checkpoint, final-commit, scaffold, settings-init, copy-toolkit'
    exit 2
  }
}
