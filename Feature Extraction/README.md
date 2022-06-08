
Git Repository: https://github.com/AIMS/hyperspectral

# Extract coral HSI from tank scans 

## Steps
Input: ExtractedCorals Folder = All corals HSI dataset (.hdr & .bil)
Output: ExtractedFeature Folder = outputs of feature extractions
All other folders should be empty. Script will overwrite existing results.
Run script.

## Extract corals features from tank
Read Ground truth polygon and extract feature from coral
Output: Extracted coral features

## Notes
RGB rendering of HSI is relative and contrast stretched so users can see the image clearly. Cannot be used for cross comparison.
