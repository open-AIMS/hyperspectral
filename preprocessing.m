%% Preprocessing of Line's field trip dataset
%  
% 1. create folder just for tif images 
% 2. crop and label images
%
% Modified by: Jon Kok (j.kok@aims.gov.au)
% Last modified: 25/03/2021

%% Define variables
input_hsi_folder = '/Volumes/Extreme SSD/Jan 2021 south sector';
output_image_folder = '/Volumes/Extreme SSD/Jan 2021 south sector rgb only';

%% Copy only tif to RGB folder for image labelling
file_list = dir([input_hsi_folder '/**/*.tif']);  

% copy files to RGB folder
for n = 1:length(file_list)
    file_name = file_list(n).name;
    folder_path = file_list(n).folder;
    folder_path_new = [output_image_folder folder_path(43:end)];
    mkdir(folder_path_new);
    copyfile([folder_path filesep file_name],[folder_path_new filesep file_name]);
end


%% View labelled data
rgb_img = imread(gTruth.DataSource.Source{1});
figure
imshow(rgb_img)
