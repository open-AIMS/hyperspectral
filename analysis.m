%% Read HSI data into workplace for analysis
% - Using Erin's polygon from Line's field trip
% - Read hyperspectral data into workspace for analysis
%
%
% Note: that some corals were held down by wires which were also captured in
% the hyperspectral image. Median might be a way of reducing its influence
% in the analysis
%
% Author: Jon Kok (j.kok@aims.gov.au)
% Last modified: 27/05/2021

%% Clear workspace
clc
clear
close all

%% Define variables
% Parent folder for all HSI data
input_folder = '/Volumes/Extreme SSD/Erin HSI Processed';
load('wavelength_nm.mat')

%% Read data into workspace
folder_contents = dir([input_folder filesep '**' filesep '*.hdr']);
coral_filename_full_path_array = strcat({folder_contents.folder},filesep,{folder_contents.name});

% for n = 1:length(coral_filename_full_path_array)
for n = 1:10
    tic
    % Read hyperspectral data
    temp_coral_hsi = hypercubeMyFun(coral_filename_full_path_array{n});
    % Reshape data to 2-D, ignoring spatial context
    temp_datacube = reshape(temp_coral_hsi.DataCube,[size(temp_coral_hsi.DataCube,1)*size(temp_coral_hsi.DataCube,2),462]);
    % Remove zeros from datacube
    temp_datacube = temp_datacube(temp_datacube(:,200) ~= 0,:);
    % Save variable name as struct
    corals(n).label = folder_contents(n).name(1:end-4);
    
    %% ADD STATS OF INTEREST HERE
    corals(n).median = median(temp_datacube,1);
    corals(n).mean = mean(temp_datacube,1);
    corals(n).std = std(temp_datacube,0,1);
    corals(n).lower_quantile = quantile(temp_datacube,0.25,1);
    corals(n).upper_quantile = quantile(temp_datacube,0.75,1);
    % Clear variable to save memory
    clearvars temp_coral_hsi temp_datacube
end

%% Analysis over time points
% Analyse change in coral id 13
coral_name_array = {folder_contents.name};
% Find labels with id 13
str_found_array = strfind(coral_name_array,'_13.'); % include underscore and . to prevent false positives
index = find(not(cellfun('isempty',str_found_array)));

%% Plot curves
for n = 1:length(index)
figure
plot(wavelength_nm,corals(index(n)).median)
hold on
plot(wavelength_nm,corals(index(n)).lower_quantile)
plot(wavelength_nm,corals(index(n)).upper_quantile)
% label axis
title(coral_name_array{1})
xlabel('wavelength (nm)')
ylabel('reflectance')
legend({'median','lower quantile','upper quantile'})
end

