
Git Repository: https://github.com/AIMS/hyperspectral

# Processing Hyperspectal Data from Coral Scans raw into reflectance 
Processing data in raw sensor counts of an entire scene into individal coral reflectance.

## Steps
Input: Raw Folder = One pair of raw HSI dataset (.hdr & .bil)
Output: Validation Folder = calibration target, cropped ffc results, rgb, cropped boundaries
Output: FFC Folder = HSI results after FFC on RAW HSI
Output: Reflectance Folder = Reflectance HSI
All other folders should be empty. Script will overwrite existing results.
Run script. Check validation folders. RGB should be of the correct tank. Cropping shouldn't cut off corals. Copy reflectance dataset into next phase (Coral Extraction)

## Flat field correction processing
Correct cross illumination variability by applying flat field correction using calibration target. Crop only usable area to increase dynamic range.
Output: RGB rendering of cropped HSI after flat field correction plotted in live script
Output: HSI after flat field correction in FFC Folder

## Reflectance processing
Convert data into reflectance (normalising data) using calibration target and calibration files. Append empty data to return cropped HSI to original HSI dimensions.
Output: RGB rendering of HSI after reflectance correction plotted in live script with cropped area drawn in red lines
Output: Reflectance HSI data in Reflectance Folder

## Notes
RGB rendering of HSI is relative and contrast stretched so users can see the image clearly. Cannot be used for cross comparison.
Script can find top of grey target automatically but cannot find the usable width robustly. Attempt is commented out and width is manually set at 350pixels on both ends. TODO: find edge automatically and robustly; alternatively insert QR markers.
  

