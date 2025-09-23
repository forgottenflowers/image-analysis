import os
import glob
import time
import logging
from ij import IJ

# Define folders
in_path = "E:/Shreya/2505_soleil_recon_hyperstacks"
out_path = "E:/Shreya/"
log_path = "C:/Users/shra13/Desktop/multipletiff_log_file.txt"
# log_path = "C:/Users/sysgen/Desktop/multipletiff_log_file.txt"

# Save log
logging.basicConfig(filename=log_path, level=logging.INFO, format="%(asctime)s - %(message)s")

# Get all .tif files with correct slashes compatible with Fiji
tif_files = [f.replace("\\", "/") for f in glob.glob(os.path.join(in_path, "*.tif"))]

# Loop over each .tif file
for tif_path in tif_files:

    start_time = time.time()
    print("working on: " + tif_path)
    logging.info("working on: %s", tif_path)
    
    # Get output directory name
    base = os.path.basename(tif_path)
    foldername = os.path.splitext(base)[0]
    
    # Create output directory in the output path
    out_dir = os.path.join(out_path, foldername)
    if not os.path.exists(out_dir):                     # Python 3.2: os.makedirs(out_dir, exist_ok=True)
        os.makedirs(out_dir)
    out_dir = out_dir.replace("\\", "/")                # Format required for ImageJ macro

    # Open the image (ImagePlus object)
    imp = IJ.openImage(tif_path)

    # Run the macro to save as multiple tiff files as slices of a stack into the output directory
    IJ.run(imp, "Image Sequence... ", "format=TIFF save=" + out_dir)

    # Close image to free memory
    imp.close()
    IJ.run("Collect Garbage")

    elapsed = time.time() - start_time
    logging.info("%s    Time elapsed: %.2f seconds", out_dir, elapsed)

print("done...")
logging.info("All files processed.")

# ----------------------------------------------------------------------------------------------
# open windows command line: Press the Windows key + r. In the Run box, type cmd, and then click Ok. This opens the Command Prompt window.
# Ctr+C to interrupt code and end it

# cd C:\opt\Fiji.app
# ImageJ-win64.exe --ij2 --headless --console --run "C:\Users\shra13\Desktop\testcode.py"

# cd C:\opt\Fiji_Interdent_Oleksandra\Fiji.app
# ImageJ-win64_Interdent.exe --ij2 --headless --console --run "C:\Users\sysgen\Desktop\try.py"
