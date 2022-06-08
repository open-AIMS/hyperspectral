
Git Repository: https://github.com/AIMS/hyperspectral


# Processing Hyperspectal Data from Coral Scans
Processing data in raw sensor counts of an entire scene into individal coral reflectance.

## Step 1: Flat field correction
Correct cross illumination variability by applying flat field correction using calibration target. 

## Step 2: Reflectance processing
Convert data into reflectance (normalising data) using calibration target and calibration files

## Step 3: Coral segmentation
Apply manually labelled ground truthing to reflectance
Do not rename source file names

## Step 4: Coral extraction
Apply manually labelled ground truthing to reflectance

## Step 5: Feature extraction
Extract features for analysis. E.g., median of 650nm, number of pixels

## Step 6: Feature analysis
Classification, correlation or other analysis on features.

# Instructions for source managing using git

Install Git crednetial manager:
https://github.com/GitCredentialManager/git-credential-manager

Create personal token: 
https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token

