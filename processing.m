%% Processing Line's data to cropped reflectance 
%
% Processing steps
% 	1. Crop width from 300 to 1300. Use grey panel which is 250 to 350 pixel from top for FFC
% 	2. Apply FFC
% 	3. Correct to reflectance using grey panel
%   4. Extract and label each coral using RGB labels
%
% Author: Jon Kok
% Last Modified: 24/05/2021
     
%% FILE MISSING'/Volumes/Extreme SSD/field/Jan 2021_South sector/hyperspectral_Ferguson_Jan 2021/SSIAB_1st run 21_550/time point 2_6am/tank_12.bil.hdr'
     % /Volumes/Extreme SSD/field/Jan 2021_South sector/hyperspectral_Ferguson_Jan 2021/SSIAB_1st run 21_550/time point 3_2.15pm/tank 12 and 11.bil.hdr'

clc
clear
close all

%% Input variables
input_hsi_folder_path = '/Volumes/Extreme SSD/field/Jan 2021_South sector/hyperspectral_Ferguson_Jan 2021';
output_hsi_folder_path = '/Users/jk/Desktop/Erin HSI Processed';

%% Use ground truth to search for HSI references
folder_contents = dir('/Users/jk/Desktop/RBG_Hyperspec/**/*.mat');
gtruth_filename_full_path_array = strcat({folder_contents.folder},filesep,{folder_contents.name});

for gtruth_counter = 13 %1:length(gtruth_filename_full_path_array)
gtruth_filename_full_path = gtruth_filename_full_path_array{gtruth_counter};
load(gtruth_filename_full_path)
coral_image_filename_full_path_array = gTruth.DataSource;

% Process each tank at a time
for tank_counter = 2 %1:length(coral_image_filename_full_path_array)

coral_image_filename_full_path = coral_image_filename_full_path_array{tank_counter};
% Replace windows filesep to mac filesep, \ to /
coral_image_filename_full_path = replace(coral_image_filename_full_path,'\','/');
path_start_index = find(coral_image_filename_full_path == '/',3,'last');
coral_image_ref_path = coral_image_filename_full_path(path_start_index(1):end);
input_hsi_full_path = [input_hsi_folder_path coral_image_ref_path(1:end-8) '.bil.hdr']; 

if gtruth_counter == 5
input_hsi_full_path = strrep(input_hsi_full_path, 'Documents', 'SSIAB run 4_full run_23_01_2021');
end

if ~strcmp(input_hsi_full_path, '/Volumes/Extreme SSD/field/Jan 2021_South sector/hyperspectral_Ferguson_Jan 2021/SSIAB run 2_full run_21_01_2021/6am/tank 10.bil.hdr')
    % ignore this file. bad data

%% Find grey panel
coral_hsi = hypercubeMyFun(input_hsi_full_path);
coral_cropped_hsi = cropData(coral_hsi,250:coral_hsi.Metadata.Height,250:1250); 

% use 1st 100 pixel from top as grey panel for FFC
cal_target_hsi = cropData(coral_cropped_hsi,1:100,1:coral_cropped_hsi.Metadata.Width); 

for n = 1:cal_target_hsi.Metadata.Width
    for m = 1:cal_target_hsi.Metadata.Bands
        column_data = rmoutliers(double(cal_target_hsi.DataCube(:,n,m)));
        temp_median = median(column_data);
        % Prevent Inf and Nan calculations
        if temp_median == 0 
            temp_median = 1;
        end
        ffc_profile(1,n,m) = temp_median; 
    end
end

% Apply FFC
coral_ffc_hsi = ffcHsi(coral_cropped_hsi, ffc_profile);
coral_ffc_rgb = colorize(coral_ffc_hsi,"Method","rgb","ContrastStretching",true);
coral_cropped_rgb = colorize(coral_cropped_hsi,"Method","rgb","ContrastStretching",true);
coral_rgb = colorize(coral_hsi,"Method","rgb","ContrastStretching",true);

% Get cal target's raw data. 1st top 100 pixels
cal_target_datacube = coral_ffc_hsi.DataCube(1:100,:,:);
cal_target_spectrum = median(cal_target_datacube,1);

% Get reflectance
load('CalibrationTarget20Percent.mat')
cal_data = interp1(CalibrationTarget20Percent(:,1),CalibrationTarget20Percent(:,2),coral_ffc_hsi.Wavelength)'/100;

coral_reflectance_datacube = (coral_ffc_hsi.DataCube./cal_target_spectrum).*reshape(cal_data,1,1,length(cal_data));
coral_reflectance_metadata = coral_ffc_hsi.Metadata;
coral_reflectance_metadata.DataType = "double";
coral_reflectance_hsi = hypercube(coral_reflectance_datacube,coral_ffc_hsi.Wavelength,coral_reflectance_metadata);
coral_reflectance_rgb = colorize(coral_reflectance_hsi,"Method","rgb","ContrastStretching",true);


%% Apply Erin's labels on reflectance 
% Find all labelled corals
label_name_array = gTruth.LabelData.Properties.VariableNames;
label_array = table2array(gTruth.LabelData);

% Create folder for writing data
path_end_index = find(coral_image_ref_path == '/',1,'last');
tank_name_path_start_index = find(coral_image_filename_full_path == '/',1,'last');
tank_name_path_end_index = find(coral_image_filename_full_path == '-',1,'last');
tank_name = coral_image_filename_full_path(tank_name_path_start_index+1:tank_name_path_end_index-1);
tank_name_full_path = [output_hsi_folder_path coral_image_ref_path(1:path_end_index) tank_name];
mkdir(tank_name_full_path)

for m = 1:length(label_name_array)
    if ~isempty(label_array{tank_counter,m})
    % label polygon
    label_polygon = cell2mat(label_array{tank_counter,m})-249;
    % crop hsi using polygon
    coral_roi_mask = roipoly(coral_reflectance_rgb,label_polygon(:,1),label_polygon(:,2));
    temp_hsi = maskCropHsi(coral_reflectance_hsi,coral_roi_mask);    
    % label name 
    label_name = cell2mat(label_name_array(m));
    % save hsi
    temp_hsi_full_path = [tank_name_full_path filesep label_name '.hdr'];
    enviwriteMyFun(temp_hsi,temp_hsi_full_path);
    % save rgb
    temp_rgb = colorize(temp_hsi,"Method","rgb","ContrastStretching",true);
    temp_rgb_full_path = [tank_name_full_path filesep label_name '.tif'];
    imwrite(temp_rgb,temp_rgb_full_path)
    end
end

end

end

gtruth_counter

end



