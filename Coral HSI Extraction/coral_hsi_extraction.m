%% Processing Hyperspectal Data from Coral Scans
% Process raw hyperspectral data into labelled individual coral reflectance 
% datasets for analysis. 

% Git Repository: https://github.com/AIMS/hyperspectral
% Only 1 HSI dataset in Reflectance folder
%
% Use tank name using HSI reflectance data as reference to extract
% corresponding labelsets
%
% Author: Jon Kok
% Last edited: 26/05/2022
%% Define folders
% Initialise script

% Clear workspace
clc
clear
close all

% Start timer
tic

% Change directory to main script path
main_file_path = matlab.desktop.editor.getActiveFilename;
[main_file_path, ~, ~] = fileparts(main_file_path);
cd(main_file_path);

% Add function folders to path
addpath('MyFunctions')
% Add data folders to path
addpath(genpath('Data'))

%% Add folders
% Folder for reflectance data
folder_path_reflectance = ['Data' filesep 'Reflectance'];
% Folder for coral ground truthing labels
folder_path_ground_truth = ['Data' filesep 'GroundTruth'];
% Folder for extracted coral HSI
folder_path_extracted = ['Data' filesep 'ExtractedCorals'];
% Folder for validation
folder_path_validation = ['Data' filesep 'Validation'];

%% Step 1: Coral segmentation from Grouth Truthing
% Apply manually labelled ground truthing to reflectance HSI.

% Check HSI raw folder
content_rf_hdr = dir([folder_path_reflectance filesep '*.hdr']);
content_rf_bil = dir([folder_path_reflectance filesep '*.bil']);
content_rf_dat = dir([folder_path_reflectance filesep '*.dat']);
% Error check if more than 1 dataset in raw folder
if ~(length(content_rf_hdr) == 1 && (length(content_rf_bil) == 1 || length(content_rf_dat) == 1))
    error('Ensure that there is only one .hdr and one .bil file in Raw Folder.')
end
% Read HSI raw
rf_hsi_filename_full_path = [folder_path_reflectance filesep content_rf_hdr.name];
tank_id = content_rf_hdr.name(1:end-8);
tank_rf_hsi = hypercubeMyFun(rf_hsi_filename_full_path);
tank_rf_rgb = colorize(tank_rf_hsi,'Method','rgb','contrastStretching',true);
% Save RGB rendering in reflectance folder, overwrite if already exist
tank_rf_tif_filename = [content_rf_hdr.name(1:end-7) 'tif'];
tank_rf_tif_filename_full_path = [folder_path_reflectance filesep tank_rf_tif_filename];
imwrite(tank_rf_rgb,tank_rf_tif_filename_full_path);
fig_temp = figure;
imshow(tank_rf_rgb)
title(['RGB rendering of raw HSI scan on tank id: ' tank_id],'Interpreter','none')
saveas(fig_temp,strcat(folder_path_validation,filesep,tank_id, '_rgb.jpg'))
close(fig_temp)

% Read data ground truth
content_gtruth = dir([folder_path_ground_truth filesep '*.mat']);
if ~(length(content_gtruth) == 1)
    error('Ensure that there is only one grouth truth .mat GroundTruth Folder.')
end
gtruth_filename_full_path = [folder_path_ground_truth filesep content_gtruth(1).name];
load(gtruth_filename_full_path)
% Ignore warning regarding datasource filenames cannot be found
% Find datasource that matches reflectance filename
filename_ffc_index = strfind(tank_rf_tif_filename,'_ffc');
filename_rf_index = strfind(tank_rf_tif_filename,'_rf');
filename_end_index = min([filename_rf_index filename_ffc_index]);
tank_name = tank_rf_tif_filename(1:filename_end_index-1);
% Read source file names
%if isSubField(gTruth.DataSource,'Source')
if iscell(gTruth.DataSource)
    source_filename_array = gTruth.DataSource;
else
    source_filename_array = gTruth.DataSource.Source;
end
% Convert source file names to tank names
% Catch for linux vs windows file separator
filename_forward_slash_index = strfind(source_filename_array,'/');
filename_backward_slash_index = strfind(source_filename_array,'\');
if isempty(filename_backward_slash_index{1})
    filename_slash_index = filename_forward_slash_index;
else
    filename_slash_index = filename_backward_slash_index;
end
source_index = 0;
for n = 1:length(source_filename_array)
    filename_index = filename_slash_index{n}(end);
    source_filename = source_filename_array{n}(filename_index+1:end);
    if strfind(source_filename,tank_name) == 1 
        source_index = n;
    end
end
if source_index == 0
    error('DataSource tank file names in Reflectance and GrouthTruth folders does not match.')
end
%% Plot all polygon on
% Find all labelled corals
label_name_array = gTruth.LabelData.Properties.VariableNames;
label_cell_array = table2array(gTruth.LabelData);
coral_polygons_counter = 1;
for m = 1:length(label_name_array)
    if ~isempty(label_cell_array{source_index,m})
        coral_polygons(coral_polygons_counter) = polyshape(label_cell_array{source_index,m});
        coral_polygons_counter = coral_polygons_counter + 1;
    end
end

fig_temp = figure;
imshow(tank_rf_rgb)
hold on
plot(coral_polygons)
title(['RGB rendering of raw HSI scan with coral polgons on tank id: ' tank_id],'Interpreter','none')
saveas(fig_temp,strcat(folder_path_validation,filesep,tank_id, '_rgb_coral_polygons.jpg'))
close(fig_temp)

%% Find all labelled corals
label_name_array = gTruth.LabelData.Properties.VariableNames;
label_cell_array = table2array(gTruth.LabelData);
for m = 1:length(label_name_array)
    if ~isempty(label_cell_array{source_index,m})
        % Label polygon
        if iscell(label_cell_array{source_index,m})
            label_array = cell2mat(label_cell_array{source_index,m});
        else
            label_array = label_cell_array{source_index,m};
        end
        coral_bw_mask = roipoly(tank_rf_rgb,label_array(:,1),label_array(:,2));
        % Label name
        label_name = cell2mat(label_name_array(m));
        % Crop HSI
        coral_hsi_mask_applied = maskCropHsi(tank_rf_hsi,coral_bw_mask);
        coral_rgb = colorize(coral_hsi_mask_applied,'Method','rgb','ContrastStretching',true);
        % Save HSI and RGB in same local folder
        coral_hsi_filename = [tank_name '_' label_name '.bil.hdr'];
        coral_hsi_filename_full_path = [folder_path_extracted filesep coral_hsi_filename];
        coral_rgb_filename = [tank_name '_' label_name '.tif'];
        coral_rgb_filename_full_path = [folder_path_extracted filesep coral_rgb_filename];
        enviwriteMyFun(coral_hsi_mask_applied,coral_hsi_filename_full_path);
        imwrite(coral_rgb,coral_rgb_filename_full_path);
    end
end

% Display run time
runtime_seconds = toc;
disp(['Run time: ' num2str(runtime_seconds/60) ' minutes'])