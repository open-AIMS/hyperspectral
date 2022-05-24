%% Create new HSI mask and data based on ground truth labels
%
%
% Author: Jon Kok (j.kok@aims.gov.au)
% Last Modified: 04/04/2021

clc
clear
close all
tic
%% Define variables
gtruth_filename_full_path = 'gTruth_test.mat';
coral_folder_local_full_path = '/Users/jk/Downloads/6am_20_01_2021_temp';
load(gtruth_filename_full_path);

%% Extract polygon from reference HSI
% Read coral images
coral_image_filename_full_path_array = gTruth.DataSource.Source;

scene_index = 1;
coral_tif_filename_full_path = coral_image_filename_full_path_array{scene_index};
path_start_index = find(coral_tif_filename_full_path == '/',4,'last');
coral_tif_ref_path = coral_tif_filename_full_path(path_start_index(1):end);
coral_tif_filename = coral_tif_filename_full_path(path_start_index(end)+1:end);

% Find corresponding coral image
coral_rgb_ref_contents = dir([coral_folder_local_full_path '/**/*.tif']);
coral_rgb_ref_array = strcat({coral_rgb_ref_contents.folder},filesep,{coral_rgb_ref_contents.name});
coral_rgb_ref_found = contains(coral_rgb_ref_array,coral_tif_filename);
coral_rgb_ref_index = find(coral_rgb_ref_found == 1); 

if length(coral_rgb_ref_index) ~= 1
    error('None or more than 1 index found.')
end

coral_image_ref_full_path = cell2mat(coral_rgb_ref_array(coral_rgb_ref_index));
coral_image = imread(coral_image_ref_full_path);

figure
imshow(coral_image)

% Find all labelled corals
label_name_array = gTruth.LabelData.Properties.VariableNames;
label_cell_array = table2array(gTruth.LabelData);
for m = 1:length(label_name_array)
    if ~isempty(label_cell_array{scene_index,m})
    % label polygon
    label_array = cell2mat(label_cell_array{scene_index,m});
    coral_bw_mask = roipoly(coral_image,label_array(:,1),label_array(:,2));
    % label name
    label_name = cell2mat(label_name_array(m));
    % Crop HSI
    coral_hsi_full_path = [coral_folder_local_full_path filesep coral_tif_filename(1:end-8) '.bil.hdr'];
    coral_hsi_scene = hypercubeMyFun(coral_hsi_full_path);
    coral_hsi_mask_applied = maskCropHsi(coral_hsi_scene,coral_bw_mask);
    coral_rgb = colorize(coral_hsi_mask_applied,"Method","rgb","ContrastStretching",true);
    % Save HSI and RGB in same local folder
    coral_hsi_filename = [coral_hsi_full_path(1:end-8) '_' label_name '.bil.hdr'];
    coral_rgb_filename = [coral_hsi_full_path(1:end-8) '_' label_name '.tif'];
    enviwriteMyFun(coral_hsi_mask_applied,coral_hsi_filename);
    imwrite(coral_rgb,coral_rgb_filename);
    end
end
total_time = toc



