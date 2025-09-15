# --- Config ---
$javaExe   = "C:\opt\Fiji_Shreya\Fiji.app\java\win64\zulu8.60.0.21-ca-fx-jdk8.0.322-win_x64\jre\bin\java.exe"
$classPath = "C:\opt\Fiji_Shreya\Fiji.app\jars\bio-formats\*;C:\opt\Fiji_Shreya\Fiji.app\jars\*;"
$mainClass = "loci.formats.tools.ImageConverter"

# --- Input/output folders
$inputFolder  = "T:\tomo\Shreya\2505_soleil_recon_FijiTIFfiles"
$outputFolder = "T:\tomo\Shreya\2505_soleil_recon_OMEfiles"

# --- Log file path (append date/time so you don’t overwrite old logs)
$logFile = "C:\Users\sysgen\Desktop\convert_log_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"

# Make sure output folder exists
if (!(Test-Path $outputFolder)) {
    New-Item -ItemType Directory -Path $outputFolder | Out-Null
}

# Initialize a log buffer (array of strings)
$logBuffer = @()
$logBuffer += "=== Conversion started: $(Get-Date) ==="


# --- Loop through all .tif files in input folder
Get-ChildItem -Path $inputFolder -Filter *.tif | ForEach-Object {
    $inputFile  = $_.FullName
    $baseName   = [System.IO.Path]::GetFileNameWithoutExtension($_.Name)
    $outputFile = Join-Path $outputFolder ($baseName + ".ome.tif")

    $message = "Converting $inputFile -> $outputFile"
    Write-Host $message
    $logBuffer += $message

    #try {
    #    & $javaExe -cp $classPath $mainClass $inputFile $outputFile 2>&1 | Out-File -FilePath $logFile -Append -Encoding UTF8
    #    if ($LASTEXITCODE -eq 0) {
    #        "SUCCESS: $outputFile created" | Out-File -FilePath $logFile -Append -Encoding UTF8
    #    } else {
    #        "ERROR: Conversion failed for $inputFile (exit code $LASTEXITCODE)" | Out-File -FilePath $logFile -Append -Encoding UTF8
    #    }
    #}
    #catch {
    #    "EXCEPTION: $($_.Exception.Message)" | Out-File -FilePath $logFile -Append -Encoding UTF8
    #}

    & $javaExe -cp $classPath $mainClass $inputFile $outputFile
}


$logBuffer += "=== Conversion finished: $(Get-Date) ==="

# Write the entire buffer to the log file once
$logBuffer | Out-File -FilePath $logFile -Encoding UTF8
