# We want ro convert the previously generated imageJ fake tiffs to OME tiffs for ease of usage on Amira

# ---------- USER SETTINGS ----------

$BFR2RAW = "C:\opt\Fiji_Shreya\Fiji.app\lib\bioformats2raw-0.10.1\bin\bioformats2raw.bat"
$RAW2OME = "C:\opt\Fiji_Shreya\Fiji.app\lib\raw2ometiff-0.7.1\bin\raw2ometiff.bat"
$BloscPath = "C:\opt\Fiji_Shreya\Fiji.app\lib\win64\blosc"
$LogFile = "E:\soleil_recon\trial_data\tiffs\convert_to_ome_log.txt"

$MaxJobs = 4  # Number of files to process in parallel

# Folder containing TIFF files
$DataFolder = "E:\soleil_recon\trial_data\tiffs"

# -----------------------------------


# Make sure JAVA_OPTS is set for this session only
$env:JAVA_OPTS = "-Djna.library.path=$BloscPath"

# Clear old log
if (Test-Path $LogFile) { Remove-Item $LogFile }

# Write header
"===== Conversion started: $(Get-Date) =====" | Out-File -FilePath $LogFile -Encoding UTF8 -Append


# Get all TIFF files
$files = Get-ChildItem -Path $DataFolder -Filter *.tif
$jobs = @()

foreach ($file in $files) {

    "$file ..." | Out-File -FilePath $LogFile -Encoding UTF8 -Append

    # Wait if max jobs are running
    while ($jobs.Count -ge $MaxJobs) {
        $jobs = $jobs | Where-Object { $_.State -eq 'Running' }
        Start-Sleep -Seconds 1
    }

    # Start a background job
    $job = Start-Job -ArgumentList $file.FullName, $BFR2RAW, $RAW2OME, $BloscPath, $DataFolder, $LogFile -ScriptBlock {
        param($InputFile, $BFR2RAW, $RAW2OME, $BloscPath, $DataFolder, $LogFile)

        try {
            $env:JAVA_OPTS = "-Djna.library.path=$BloscPath"
            $BaseName = [System.IO.Path]::GetFileNameWithoutExtension($InputFile)
            $ZarrOutput = Join-Path $DataFolder "$BaseName.zarr"
            $OMEOutput = Join-Path $DataFolder "$BaseName.ome.tif"

            "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] START: $InputFile" | Out-File -FilePath $LogFile -Encoding UTF8 -Append

            & $BFR2RAW $InputFile $ZarrOutput 2>&1 | Out-File -FilePath $LogFile -Encoding UTF8 -Append
            & $RAW2OME $ZarrOutput $OMEOutput 2>&1 | Out-File -FilePath $LogFile -Encoding UTF8 -Append

            Remove-Item -Recurse -Force $ZarrOutput

            "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] SUCCESS: $InputFile → $OMEOutput" | Out-File -FilePath $LogFile -Encoding UTF8 -Append

        } catch {
            "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] ERROR: $InputFile → $($_.Exception.Message)" | Out-File -FilePath $LogFile -Encoding UTF8 -Append
        }
    }

    $jobs += $job
}

# Wait for all jobs to finish
while ($jobs | Where-Object { $_.State -eq 'Running' }) {
    Start-Sleep -Seconds 2
}

# Retrieve job outputs and errors
foreach ($job in $jobs) {
    Receive-Job $job -Wait | Out-File -FilePath $LogFile -Append
    Remove-Job $job
}



"===== Conversion finished: $(Get-Date) =====" | Out-File -FilePath $LogFile -Encoding UTF8 -Append
Write-Host "All conversions finished. See log at $LogFile"
