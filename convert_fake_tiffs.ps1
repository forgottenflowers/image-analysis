# We want ro convert the previously generated imageJ fake tiffs to OME tiffs for Ease of usage on Amira

# ---------- USER SETTINGS ----------
# Path to .bat launchers
$BFR2RAW = "C:\opt\Fiji_Shreya\Fiji.app\lib\bioformats2raw-0.10.1\bin\bioformats2raw.bat"
$RAW2OME = "C:\opt\Fiji_Shreya\Fiji.app\lib\raw2ometiff-0.7.1\bin\raw2ometiff.bat"

# Path to blosc.dll
$BloscPath = "C:\opt\Fiji_Shreya\Fiji.app\lib\win64\blosc"

# Max number of files to process at once
$MaxParallel = 4

# Log file (in current folder)
$LogFile = ".\convert_to_ome_log.txt"
# -----------------------------------

# Make sure JAVA_OPTS is set for this session only
$env:JAVA_OPTS = "-Djna.library.path=$BloscPath"

# Clear old log
if (Test-Path $LogFile) { Remove-Item $LogFile }

# Write header
"===== Conversion started: $(Get-Date) =====" | Out-File -FilePath $LogFile -Encoding UTF8 -Append

# Convert all .tif files in current folder
Get-ChildItem -Filter *.tif | ForEach-Object -Parallel {
    param($BFR2RAW, $RAW2OME, $LogFile)

    $file = $_.FullName
    $name = [System.IO.Path]::GetFileNameWithoutExtension($file)

    try {
        $msg = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] START: $file"
        $msg | Out-File -FilePath $LogFile -Encoding UTF8 -Append
        Write-Host $msg

        # Step 1: Convert fake TIFF to Zarr
        & $BFR2RAW $file "$name.zarr" 2>&1 | Out-File -FilePath $LogFile -Encoding UTF8 -Append

        # Step 2: Convert Zarr to OME-TIFF
        & $RAW2OME "$name.zarr" "$name.ome.tif" 2>&1 | Out-File -FilePath $LogFile -Encoding UTF8 -Append

        # Clean up intermediate Zarr
        Remove-Item -Recurse -Force "$name.zarr"

        $msg = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] SUCCESS: $file → $name.ome.tif"
        $msg | Out-File -FilePath $LogFile -Encoding UTF8 -Append
        Write-Host $msg
    }
    catch {
        $msg = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] ERROR: $file → $($_.Exception.Message)"
        $msg | Out-File -FilePath $LogFile -Encoding UTF8 -Append
        Write-Host $msg
    }

} -ArgumentList $BFR2RAW, $RAW2OME, $LogFile -ThrottleLimit $MaxParallel

"===== Conversion finished: $(Get-Date) =====" | Out-File -FilePath $LogFile -Encoding UTF8 -Append
