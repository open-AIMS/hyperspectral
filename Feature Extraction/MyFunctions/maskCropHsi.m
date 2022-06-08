function hsi_output = maskCropHsi(hsi_input,roi_mask)

% Apply roi mask to HSI and crop only its boundaries

% apply mask to reflectance
masked_scene_datacube = double(hsi_input.DataCube).*double(roi_mask);
masked_scene_hsi = hypercube(masked_scene_datacube,hsi_input.Wavelength,hsi_input.Metadata);
% find boundaries
[row_array, column_array] = find(roi_mask > 0);
% crop boudaries
hsi_output = cropData(masked_scene_hsi,min(row_array):max(row_array),min(column_array):max(column_array));

end

