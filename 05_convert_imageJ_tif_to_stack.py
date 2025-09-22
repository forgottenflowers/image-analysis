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
    
    # Path to the matching .vol file
    infofilename = os.path.basename(vol_info_path)  #with extensions
    datafoldername = infofilename.replace("_0.vol.info","") 
    vol_data_path = vol_data_dir + "/" + datafoldername + "/" + datafoldername + "_0_16b.vol"
    
     # Path to output directory
    out_dir = out_path + vol_data_dir + "/" + datafoldername + "/" + datafoldername + "_0_16b.tif"
    
    # Get the active image (ImagePlus object)
    imp = IJ.getImage()

   # Run the macro to save as multiple tiff files as slices of a stack into the output directory
    IJ.run("Image Sequence... ", "format=TIFF save="+out_dir)

    # Close image to free memory
    imp.close()

    elapsed = time.time() - start_time
    logging.info("%s    Time elapsed: %.2f seconds", out_path, elapsed)

print("done...")
