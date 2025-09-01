# We want ro convert the previously generated imageJ fake tiffs to OME tiffs for ease of usage on Amira

# ---------- USER SETTINGS ----------

$BFR2RAW = "C:\opt\Fiji_Shreya\Fiji.app\lib\bioformats2raw-0.10.1\bin\bioformats2raw.bat"
$RAW2OME = "C:\opt\Fiji_Shreya\Fiji.app\lib\raw2ometiff-0.7.1\bin\raw2ometiff.bat"
$BloscPath = "C:\opt\Fiji_Shreya\Fiji.app\lib\win64\blosc"
$LogFile = ".\convert_to_ome_log.txt"

$MaxJobs = 4  # Number of files to process in parallel

# -----------------------------------


# Make sure JAVA_OPTS is set for this session only
$env:JAVA_OPTS = "-Djna.library.path=$BloscPath"

# Clear old log
if (Test-Path $LogFile) { Remove-Item $LogFile }

# Write header
"===== Conversion started: $(Get-Date) =====" | Out-File -FilePath $LogFile -Encoding UTF8 -Append


# Get all TIFF files
$files = Get-ChildItem -Filter *.tif
$jobs = @()

foreach ($file in $files) {
    # Wait if max jobs are running
    while ($jobs.Count -ge $MaxJobs) {
        $jobs = $jobs | Where-Object { $_.State -eq 'Running' }
        Start-Sleep -Seconds 1
    }

    # Start job
    $job = Start-Job -ArgumentList $file.FullName, $BFR2RAW, $RAW2OME, $LogFile -ScriptBlock {
        param($filePath, $BFR2RAW, $RAW2OME, $LogFile)
        try {
            $name = [System.IO.Path]::GetFileNameWithoutExtension($filePath)
            $msg = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] START: $($filePath)"
            $msg | Out-File -FilePath $LogFile -Encoding UTF8 -Append
            Write-Host $msg

            & $BFR2RAW $filePath "$name.zarr" 2>&1 | Out-File -FilePath $LogFile -Encoding UTF8 -Append
            & $RAW2OME "$name.zarr" "$name.ome.tif" 2>&1 | Out-File -FilePath $LogFile -Encoding UTF8 -Append

            Remove-Item -Recurse -Force "$name.zarr"

            $msg = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] SUCCESS: $($filePath) → $name.ome.tif"
            $msg | Out-File -FilePath $LogFile -Encoding UTF8 -Append
            Write-Host $msg
        } catch {
            $msg = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] ERROR: $($filePath) → $($_.Exception.Message)"
            $msg | Out-File -FilePath $LogFile -Encoding UTF8 -Append
            Write-Host $msg
        }
    }

    $jobs += $job
}

# Wait for all jobs to finish
while ($jobs | Where-Object { $_.State -eq 'Running' }) {
    Start-Sleep -Seconds 2
}


"===== Conversion finished: $(Get-Date) =====" | Out-File -FilePath $LogFile -Encoding UTF8 -Append
