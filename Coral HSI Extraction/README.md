
Git Repository: https://github.com/AIMS/hyperspectral

# Extract coral HSI from tank scans 

## Steps
Input: Reflectance Folder = One pair of reflectance HSI dataset (.hdr & .bil)
Input: GroundTruth Folder = Corresponding ground truth label mat file (.mat)
Output: Validation Folder = RBG of tank, polygon on RGB
Output: ExtractedCorals Folder = All extracted coral HSI
All other folders should be empty. Script will overwrite existing results.
Run script. Check validation folders. RGB should be of the correct tank. Polygon should be correctly overlapped. Cropping shouldn't cut off corals. Copy extracted corals dataset into next phase (Feature Extraction)

## Extract corals from tank
Read Ground truth polygon and extract shape from tank. Crop unused boundaries. 
Output: Extracted coral HSI

## Notes
RGB rendering of HSI is relative and contrast stretched so users can see the image clearly. Cannot be used for cross comparison.
