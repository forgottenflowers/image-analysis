import os
import glob
import time
import logging
from ij import IJ

# Define folders
in_path = "T:/tomo/Shreya/2505_soleil_recon_FijiTIFfiles"
out_path = "T:/tomo/Shreya/2505_soleil_recon_multipleTiffs"
log_path = "C:/Users/sysgen/Desktop/multipletiff_log_file.txt"

# Save log
logging.basicConfig(filename=log_path, level=logging.INFO, format="%(asctime)s - %(message)s")

# Get all .tif files
tif_files = glob.glob(os.path.join(in_path, "*.tif"))

# Loop over each .tif file
for tif_path in tif_files:

    start_time = time.time()
    print("working...")
    
    # Get output directory name
    base = os.path.basename(tif_path)
    foldername = infofilename.replace(".tif","")
    
    # Create output directory in the output path
    out_dir = os.path.join(out_path, foldername)
    os.makedirs(out_dir, exist_ok=True)                 # won't fail if it already exists
    
    # Get the active image (ImagePlus object)
    imp = IJ.getImage()

   # Run the macro to save as multiple tiff files as slices of a stack into the output directory
    IJ.run("Image Sequence... ", "format=TIFF save="+out_dir)

    # Close image to free memory
    imp.close()

    elapsed = time.time() - start_time
    logging.info("%s    Time elapsed: %.2f seconds", out_path, elapsed)

print("done...")


# cd C:\opt\Fiji_Interdent_Oleksandra\Fiji.app
# ImageJ-win64_Interdent.exe --ij2 --headless --console --run "C:\Users\sysgen\Desktop\hello.py"
