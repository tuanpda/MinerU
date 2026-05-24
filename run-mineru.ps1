# MinerU local launcher (Windows)
# Usage: .\run-mineru.ps1 parse | gradio | api

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $Root

$env:HF_HUB_DISABLE_SYMLINKS = "1"
$Python = Join-Path $Root ".venv\Scripts\python.exe"

if (-not (Test-Path $Python)) {
    Write-Error "Virtual env not found. Run setup first."
}

$Mode = if ($args.Count -gt 0) { $args[0] } else { "help" }

switch ($Mode) {
    "parse" {
        $Input = if ($args.Count -gt 1) { $args[1] } else { "samples\demo_mineru.pdf" }
        $Out = if ($args.Count -gt 2) { $args[2] } else { "output" }
        & (Join-Path $Root ".venv\Scripts\mineru.exe") -p $Input -o $Out -b pipeline
    }
    "gradio" {
        & (Join-Path $Root ".venv\Scripts\mineru-gradio.exe") -b pipeline
    }
    "api" {
        & (Join-Path $Root ".venv\Scripts\mineru-api.exe")
    }
    default {
        Write-Host @"
MinerU launcher
  .\run-mineru.ps1 parse [input] [output]   - Parse PDF (pipeline/CPU)
  .\run-mineru.ps1 gradio                   - Web UI
  .\run-mineru.ps1 api                      - REST API only
"@
    }
}
