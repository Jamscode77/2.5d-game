# Generates Visual Studio project files for MechFrontline.
# Requires Unreal Engine 5.5+ installed and RunUAT / UnrealVersionSelector on PATH,
# or set $EngineRoot explicitly.

param(
	[string]$EngineRoot = $env:UE_ROOT
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$UProject = Join-Path $ProjectRoot "MechFrontline.uproject"

if (-not (Test-Path $UProject)) {
	Write-Error "Missing MechFrontline.uproject at $UProject"
}

if (-not $EngineRoot) {
	Write-Host "UE_ROOT not set. Double-click MechFrontline.uproject or right-click → Generate Visual Studio project files in Explorer."
	Write-Host "Or re-run: .\Scripts\GenerateProjectFiles.ps1 -EngineRoot 'C:\Program Files\Epic Games\UE_5.5'"
	exit 1
}

$UBT = Join-Path $EngineRoot "Engine\Binaries\DotNET\UnrealBuildTool\UnrealBuildTool.exe"
if (-not (Test-Path $UBT)) {
	# UE5.4+ layout fallback
	$UBT = Join-Path $EngineRoot "Engine\Binaries\DotNET\UnrealBuildTool.exe"
}

& $UBT -projectfiles -project="$UProject" -game -rocket -progress
