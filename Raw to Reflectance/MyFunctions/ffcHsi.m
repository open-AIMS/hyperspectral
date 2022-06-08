function output_hsi = ffcHsi(input_hsi, input_ffc_profile)

% Use pixel with highest signal as reference
input_ffc_profile = double(input_ffc_profile);

[~, pixel_index] = max(sum(input_ffc_profile,3));
reference_spectrum = input_ffc_profile(1,pixel_index,:);
gain = reference_spectrum./input_ffc_profile;
input_hsi_metadata = input_hsi.Metadata;
input_hsi_metadata.DataType = "double";
output_hsi = hypercube(double(input_hsi.DataCube).*gain,input_hsi.Wavelength,input_hsi_metadata);
end
