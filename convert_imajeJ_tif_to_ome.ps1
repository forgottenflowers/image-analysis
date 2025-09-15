# --- Config ---
$javaExe   = "C:\opt\Fiji_Shreya\Fiji.app\java\win64\zulu8.60.0.21-ca-fx-jdk8.0.322-win_x64\jre\bin\java.exe"
$classPath = "C:\opt\Fiji_Shreya\Fiji.app\jars\bio-formats\*;C:\opt\Fiji_Shreya\Fiji.app\jars\*;"
$mainClass = "loci.formats.tools.ImageConverter"

# --- Input/output folders
$inputFolder  = "T:\tomo\Shreya\2505_soleil_recon_FijiTIFfiles"
$outputFolder = "T:\tomo\Shreya\2505_soleil_recon_OMEfiles"

# --- Make sure output folder exists
if (!(Test-Path $outputFolder)) {
    New-Item -ItemType Directory -Path $outputFolder | Out-Null
}

# --- Loop through all .tif files in input folder
Get-ChildItem -Path $inputFolder -Filter *.tif | ForEach-Object {
    $inputFile  = $_.FullName
    $baseName   = [System.IO.Path]::GetFileNameWithoutExtension($_.Name)
    $outputFile = Join-Path $outputFolder ($baseName + ".ome.tif")

    Write-Host "Converting $inputFile -> $outputFile"

    & $javaExe -cp $classPath $mainClass $inputFile $outputFile
}
