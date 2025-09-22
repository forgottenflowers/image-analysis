import os
import glob
import time
import logging
from ij import IJ

# Folder containing .vol.info files
vol_info_dir = "G:/trial_data/vol_info"
vol_data_dir = os.path.dirname(vol_info_dir)

# Image properties common to all vol files (predefining makes code faster)
z = 2048                            # int(params["NUM_Z"])
endian = "little-endian"            #"little-endian" if params["BYTEORDER"].upper() == "LOWBYTEFIRST" else "big-endian"
image_type = "[16-bit Unsigned]"    #default  

# Save log
logging.basicConfig(filename="C:/Users/shra13/Desktop/shreya_log_file.txt", level=logging.INFO, format="%(asctime)s - %(message)s")

# Get all .vol.info files
vol_info_files = glob.glob(os.path.join(vol_info_dir, "*.vol.info"))

# Loop over each .vol.info file
for vol_info_path in vol_info_files:

    start_time = time.time()
    print("working...")
    
    # Path to the matching .vol file
    infofilename = os.path.basename(vol_info_path)  #with extensions
    datafoldername = infofilename.replace("_0.vol.info","") 
    vol_data_path = vol_data_dir + "/" + datafoldername + "/" + datafoldername + "_0_16b.vol"
    
    # Skip if file does not exist
    if not os.path.exists(vol_data_path):
        logging.info("Skipping, file not found: %s", vol_data_path)
        continue
    
    # Path to output file
    out_path = vol_data_dir + "/" + datafoldername + "/" + datafoldername + "_0_16b.tif"
 
    # Read parameters from info file
    params = {}
    with open(vol_info_path, "r") as f:
        for line in f:
            if "=" in line:
                key, val = line.strip().split("=")
                params[key.strip()] = val.strip()
            
    # Image properties
    x = int(params["NUM_X"])
    y = int(params["NUM_Y"])

    # Build imageJ macro string
    macro_string = (
        "open=" + vol_data_path + " " +
        "image=" + image_type + " " +
        "width=" + str(x) + " " +
        "height=" + str(y) + " " +
        "number=" + str(z) + " " +
        endian
    )
    
    # Run the raw import exactly like GUI
    IJ.run("Raw...", macro_string)

    # Get the active image (ImagePlus object)
    imp = IJ.getImage()

    # Save as TIF
    IJ.saveAs(imp, "Tiff", out_path)

    # Close image to free memory
    imp.close()

    elapsed = time.time() - start_time
    logging.info("%s    Time elapsed: %.2f seconds", out_path, elapsed)

print("done...")

# ----------------------------------------------------------------------------------------------
# open windows command line: Press the Windows key + r. In the Run box, type cmd, and then click Ok. This opens the Command Prompt window.
