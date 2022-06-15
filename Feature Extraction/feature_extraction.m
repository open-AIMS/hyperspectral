%% Processing Hyperspectal Data from Coral Scans
% Process raw hyperspectral data into labelled individual coral reflectance 
% datasets for analysis. 

% Git Repository: https://github.com/AIMS/hyperspectral
%
% Extract features from extracted corals HSI
%
% Current features: 
% Relative size = number of pixels
% Median of red band intensity = 650 nm [1]
% Median of Chl a = 675nm [2] 
% Sum of Chl a 
% Ratio of Chl a to size
% Median of Peridinin = mean(510-610nm) [2]
% Sum of Peridinin 
% Ratio of Peridinin to size
% 
%
% [1] https://www.britannica.com/science/color/The-visible-spectrum
% [2] Bio-optical modeling of photosynthetic pigments in corals, 2006
%
% Author: Jon Kok
% Last edited: 03/06/2022
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
% Addd data folders to path
addpath(genpath('Data'))

coral_hsi_folder_path = fullfile('Data','ExtractedCorals');
label_folder_path = fullfile('Data','GroundTruth');
features_folder_path = fullfile('Data','ExtractedFeatures');

folder_path_rgb = fullfile(features_folder_path,'RGB');
folder_path_650nm_heatmap = fullfile(features_folder_path,'650nmHeatmap');
folder_path_650nm_boxplot = fullfile(features_folder_path,'650nmBoxplot');
folder_path_675nm_heatmap = fullfile(features_folder_path,'675nmHeatmap');
folder_path_675nm_boxplot = fullfile(features_folder_path,'675nmBoxplot');
folder_path_510nm_610nm_heatmap = fullfile(features_folder_path,'510nm610nmHeatmap');
folder_path_510nm_610nm_boxplot = fullfile(features_folder_path,'510nm610nmBoxplot');


label_contents = dir([label_folder_path '/*.mat']);
label_filename_full_path = fullfile(label_contents.folder,label_contents.name);
label_type_index_found = find(label_filename_full_path == '_',2,'last');
label_type = label_filename_full_path(label_type_index_found(1)+1:label_type_index_found(2)-1);

%% Find coral that matches label filename
% Check contents of coral folder
contents_hdr = dir([coral_hsi_folder_path filesep '*.hdr']);
contents_filename = {contents_hdr.name};
for n = 1:length(contents_filename)
    contents_filename_long = contents_filename{n};
    contents_tank_id_index_start = strfind(lower(contents_filename_long),'tank');
    contents_tank_id_index_end = find(contents_filename_long(contents_tank_id_index_start:end)=='_',1,'first') +contents_tank_id_index_start - 2;
    contents_tank_name_found = contents_filename_long(contents_tank_id_index_start:contents_tank_id_index_end);
    contents_tank_id{n} = contents_tank_name_found(~isspace(contents_tank_name_found));
    label_type_id{n} = contents_filename_long(end-8);
end

label_tank_id_index_start = strfind(lower(label_filename_full_path),'tank');
label_tank_id_index_end = find(label_filename_full_path(label_tank_id_index_start:end)=='_',1,'first') + label_tank_id_index_start - 2;
label_tank_id = label_filename_full_path(label_tank_id_index_start:label_tank_id_index_end);

[~, contents_found_array] = find(contains(contents_tank_id,label_tank_id,'IgnoreCase',true) & contains(label_type_id,label_type(1),'IgnoreCase',true));

%% Extract feaures from corals
% For each coral
coral_id_counter = 1;
for contents_index = 1:length(contents_found_array)
    coral_index = contents_found_array(contents_index);
    coral_id_name = string(contents_hdr(coral_index).name(1:end-8));
    coral_id(coral_id_counter) = coral_id_name;
    % Read coral HSI
    coral_hsi = hypercubeMyFun([contents_hdr(coral_index).folder filesep contents_hdr(coral_index).name]);
    % Show image of coral
    coral_rgb = colorize(coral_hsi,'Method','rgb','contrastStretching',true);
    fig_temp = figure;
    imshow(coral_rgb)
    removeToolbarExplorationButtons(fig_temp)
    title(['RGB rendering of coral id: ' coral_id_name],'Interpreter','none')
    saveas(fig_temp,strcat(folder_path_rgb,filesep,coral_id_name,'_rgb.jpg'))
    close(fig_temp)

    %% Relative size = number of pixels
    % Count pixel to exclude masked out regions
    num_of_pixels(coral_id_counter) = 0;
    for n = 1:size(coral_hsi.DataCube,1)
        for m = 1:size(coral_hsi.DataCube,2)
            if sum(coral_hsi.DataCube(n,m,:))
                num_of_pixels(coral_id_counter) = num_of_pixels(coral_id_counter) + 1;
            end
        end
    end
    
    %% Median of red band intensity = 650 nm [1]
    % Find wavelength index for red band at 650nm
    wavelength_delta = coral_hsi.Wavelength - 650;
    [~, wavelength_index_650] = min(abs(wavelength_delta));
    % Create data array that excludes masked out regions
    data_counter = 1;
    clearvars data_array
    for n = 1:size(coral_hsi.DataCube,1)
        for m = 1:size(coral_hsi.DataCube,2)
            if sum(coral_hsi.DataCube(n,m,:))
                data_array(data_counter) = coral_hsi.DataCube(n,m,wavelength_index_650);
                data_counter = data_counter + 1;
            end
        end
    end
    % Median of red intensity
    red_median(coral_id_counter) = median(data_array);
    % Show red intensity heat map on image
    fig_temp = figure;
    imshow(coral_hsi.DataCube(:,:,wavelength_index_650),[])
    removeToolbarExplorationButtons(fig_temp)
    title(['Heatmap of 650nm reflectance (red band) on coral id: ' coral_id_name],'Interpreter','none')
    colormap('jet')
    colorbar
    saveas(fig_temp,strcat(folder_path_650nm_heatmap,filesep,coral_id_name, '_650nm_red_band_heatmap.jpg'))
    close(fig_temp)
    % Show box plot to inspect median and variance
    fig_temp = figure;
    boxplot(data_array)
    removeToolbarExplorationButtons(fig_temp)
    title(['Box plot of 650nm reflectance (red band) on coral id: ' coral_id_name],'Interpreter','none')
    saveas(fig_temp,strcat(folder_path_650nm_boxplot,filesep,coral_id_name, '_650nm_red_band_boxplot.jpg'))
    close(fig_temp)

    %% Chl a = 675nm [2] 
    % Find wavelength index for 675nm
    wavelength_delta = coral_hsi.Wavelength - 675;
    [~, wavelength_index_675] = min(abs(wavelength_delta));
    % Create data array that excludes masked out regions
    data_counter = 1;
    clearvars data_array
    for n = 1:size(coral_hsi.DataCube,1)
        for m = 1:size(coral_hsi.DataCube,2)
            if sum(coral_hsi.DataCube(n,m,:))
                data_array(data_counter) = coral_hsi.DataCube(n,m,wavelength_index_675);
                data_counter = data_counter + 1;
            end
        end
    end
    % Median of chl a
    chl_a_median(coral_id_counter) = median(data_array);
    % Sum of Chl a
    chl_a_sum(coral_id_counter) = sum(data_array);
    % Ratio of Chl a to size
    chl_per_pixel(coral_id_counter) = chl_a_sum(coral_id_counter)/num_of_pixels(coral_id_counter);

    % Show chl heat map on image
    fig_temp = figure;
    imshow(coral_hsi.DataCube(:,:,wavelength_index_675),[])
    removeToolbarExplorationButtons(fig_temp)
    title(['Heatmap of 675nm reflectance (Chl a proxy) on coral id: ' coral_id_name],'Interpreter','none')
    colormap('jet')
    colorbar
    saveas(fig_temp,strcat(folder_path_675nm_heatmap,filesep,coral_id_name, '_675nm_chl_a_heatmap.jpg'))
    close(fig_temp)
    % Show box plot to inspect median and variance
    fig_temp = figure;
    boxplot(data_array)
    removeToolbarExplorationButtons(fig_temp)
    title(['Box plot of 675nm reflectance (Chl a proxy) on coral id: ' coral_id_name],'Interpreter','none')
    saveas(fig_temp,strcat(folder_path_675nm_boxplot,filesep,coral_id_name, '_675nm_chl_a_boxplot.jpg'))
    close(fig_temp)

    %% Peridinin = mean(510-610nm) [2] 
    % Find wavelength index for 510nm and 610nm
    wavelength_delta = coral_hsi.Wavelength - 510;
    [~, wavelength_index_510] = min(abs(wavelength_delta));
    wavelength_delta = coral_hsi.Wavelength - 610;
    [~, wavelength_index_610] = min(abs(wavelength_delta));
    % Create data array that excludes masked out regions
    data_counter = 1;
    temp_image = [];
    clearvars data_array
    for n = 1:size(coral_hsi.DataCube,1)
        for m = 1:size(coral_hsi.DataCube,2)
            if sum(coral_hsi.DataCube(n,m,:))
                data_array(data_counter) = mean(coral_hsi.DataCube(n,m,wavelength_index_510:wavelength_index_610));
                temp_image(n,m) = data_array(data_counter);
                data_counter = data_counter + 1;
            else
                temp_image(n,m) = 0;
            end
        end
    end
    % Median of Peridinin
    peridinin_median(coral_id_counter) = median(data_array);
    % Sum of Peridinin
    peridinin_sum(coral_id_counter) = sum(data_array);
    % Ratio of Peridinin to size
    peridinin_per_pixel(coral_id_counter) = peridinin_sum(coral_id_counter)/num_of_pixels(coral_id_counter);

    % Show peridinin heat map on image
    fig_temp = figure;
    imshow(temp_image,[])
    removeToolbarExplorationButtons(fig_temp)
    title(['Heatmap of mean(510-610nm) reflectance (Peridinin proxy) on coral id: ' coral_id_name],'Interpreter','none')
    colormap('jet')
    colorbar
    saveas(fig_temp,strcat(folder_path_510nm_610nm_heatmap,filesep,coral_id_name, '_510nm_610nm_peridinin_heatmap.jpg'))
    close(fig_temp)
    % Show box plot to inspect median and variance
    fig_temp = figure;
    boxplot(data_array)
    removeToolbarExplorationButtons(fig_temp)
    title(['Box plot of mean(510-610nm) reflectance (Peridinin proxy) on coral id: ' coral_id_name],'Interpreter','none')
    saveas(fig_temp,strcat(folder_path_510nm_610nm_boxplot,filesep,coral_id_name, '_510nm_610nm_peridinin_boxplot.jpg'))
    close(fig_temp)

    coral_id_counter = coral_id_counter + 1;
end

% Create table for excel data export
coralId = coral_id';
numOfPixel = num_of_pixels';
redMedian = red_median';
chlaMedian = chl_a_median';
chlaSum = chl_a_sum';
chlPerPixel = chl_per_pixel';
peridininMedian = peridinin_median';
peridininSum = peridinin_sum';
peridininPerPixel = peridinin_per_pixel';

table_extracted_features = table(coralId,numOfPixel,redMedian,chlaMedian,chlaSum,chlPerPixel,peridininMedian,peridininSum,peridininPerPixel);

%%%%% TODO: Excel file name not perfect

% Find coral file name.
tank_name_full = char(coralId(1));
coral_name_array = diff(char(coralId));
coral_name_array_sum = sum(coral_name_array,1);
coral_name_last_index = find(coral_name_array_sum > 0,1,'first');
tank_filename_temp = tank_name_full(1:coral_name_last_index);

tank_name_last_index = find(tank_filename_temp == '_',1,'last') - 1;
tank_name = tank_name_full(1:tank_name_last_index);

% Export to excel
writetable(table_extracted_features,[fullfile(features_folder_path,tank_name) '_' label_type '_features.xlsx'])





% 
% 
% 
% 
% 
% 
% 
% 
% 
% % Define raw file source. Currently using local workspace. 
% 
% % Folder for extracted coral HSI
% folder_path_extracted_corals = 
% % Folder for coral ground truthing labels
% folder_path_extracted_features= ['Data' filesep 'ExtractedFeatures'];
% folder_path_rgb = ['Data' filesep 'ExtractedFeatures' filesep 'RGB'];
% folder_path_650nm_heatmap = ['Data' filesep 'ExtractedFeatures' filesep '650nmHeatmap'];
% folder_path_650nm_boxplot = ['Data' filesep 'ExtractedFeatures' filesep '650nmBoxplot'];
% folder_path_675nm_heatmap = ['Data' filesep 'ExtractedFeatures' filesep '675nmHeatmap'];
% folder_path_675nm_boxplot = ['Data' filesep 'ExtractedFeatures' filesep '675nmBoxplot'];
% folder_path_510nm_610nm_heatmap = ['Data' filesep 'ExtractedFeatures' filesep '510nm610nmHeatmap'];
% folder_path_510nm_610nm_boxplot = ['Data' filesep 'ExtractedFeatures' filesep '510nm610nmBoxplot'];
% 
% %% Extract feaures from corals
% % Check contents of coral folder
% content_hdr = dir([folder_path_extracted_corals filesep '*.hdr']);
% % For each coral
% for coral_index = 1:length(content_hdr)
%     % Read coral HSI
%     coral_hsi = hypercubeMyFun([content_hdr(coral_index).folder filesep content_hdr(coral_index).name]);
%     coral_id(coral_index) = string(content_hdr(coral_index).name(1:end-8));
%     % Show image of coral
%     coral_rgb = colorize(coral_hsi,'Method','rgb','contrastStretching',true);
%     fig_temp = figure;
%     imshow(coral_rgb)
%     title(['RGB rendering of coral id: ' coral_id(coral_index)],'Interpreter','none')
%     saveas(fig_temp,strcat(folder_path_rgb,filesep,coral_id(coral_index),'_rgb.jpg'))
%     close(fig_temp)
% 
%     %% Relative size = number of pixels
%     % Count pixel to exclude masked out regions
%     num_of_pixels(coral_index) = 0;
%     for n = 1:size(coral_hsi.DataCube,1)
%         for m = 1:size(coral_hsi.DataCube,2)
%             if sum(coral_hsi.DataCube(n,m,:))
%                 num_of_pixels(coral_index) = num_of_pixels(coral_index) + 1;
%             end
%         end
%     end
%     
%     %% Median of red band intensity = 650 nm [1]
%     % Find wavelength index for red band at 650nm
%     wavelength_delta = coral_hsi.Wavelength - 650;
%     [~, wavelength_index_650] = min(abs(wavelength_delta));
%     % Create data array that excludes masked out regions
%     data_counter = 1;
%     clearvars data_array
%     for n = 1:size(coral_hsi.DataCube,1)
%         for m = 1:size(coral_hsi.DataCube,2)
%             if sum(coral_hsi.DataCube(n,m,:))
%                 data_array(data_counter) = coral_hsi.DataCube(n,m,wavelength_index_650);
%                 data_counter = data_counter + 1;
%             end
%         end
%     end
%     % Median of red intensity
%     red_median(coral_index) = median(data_array);
%     % Show red intensity heat map on image
%     fig_temp = figure;
%     imshow(coral_hsi.DataCube(:,:,wavelength_index_650),[])
%     title(['Heatmap of 650nm reflectance (red band) on coral id: ' coral_id(coral_index)],'Interpreter','none')
%     colormap('jet')
%     colorbar
%     saveas(fig_temp,strcat(folder_path_650nm_heatmap,filesep,coral_id(coral_index), '_650nm_red_band_heatmap.jpg'))
%     close(fig_temp)
%     % Show box plot to inspect median and variance
%     fig_temp = figure;
%     boxplot(data_array)
%     title(['Box plot of 650nm reflectance (red band) on coral id: ' coral_id(coral_index)],'Interpreter','none')
%     saveas(fig_temp,strcat(folder_path_650nm_boxplot,filesep,coral_id(coral_index), '_650nm_red_band_boxplot.jpg'))
%     close(fig_temp)
% 
%     %% Chl a = 675nm [2] 
%     % Find wavelength index for 675nm
%     wavelength_delta = coral_hsi.Wavelength - 675;
%     [~, wavelength_index_675] = min(abs(wavelength_delta));
%     % Create data array that excludes masked out regions
%     data_counter = 1;
%     clearvars data_array
%     for n = 1:size(coral_hsi.DataCube,1)
%         for m = 1:size(coral_hsi.DataCube,2)
%             if sum(coral_hsi.DataCube(n,m,:))
%                 data_array(data_counter) = coral_hsi.DataCube(n,m,wavelength_index_675);
%                 data_counter = data_counter + 1;
%             end
%         end
%     end
%     % Median of chl a
%     chl_a_median(coral_index) = median(data_array);
%     % Sum of Chl a
%     chl_a_sum(coral_index) = sum(data_array);
%     % Ratio of Chl a to size
%     chl_per_pixel(coral_index) = chl_a_sum(coral_index)/num_of_pixels(coral_index);
% 
%     % Show chl heat map on image
%     fig_temp = figure;
%     imshow(coral_hsi.DataCube(:,:,wavelength_index_675),[])
%     title(['Heatmap of 675nm reflectance (Chl a proxy) on coral id: ' coral_id(coral_index)],'Interpreter','none')
%     colormap('jet')
%     colorbar
%     saveas(fig_temp,strcat(folder_path_675nm_heatmap,filesep,coral_id(coral_index), '_675nm_chl_a_heatmap.jpg'))
%     close(fig_temp)
%     % Show box plot to inspect median and variance
%     fig_temp = figure;
%     boxplot(data_array)
%     title(['Box plot of 675nm reflectance (Chl a proxy) on coral id: ' coral_id(coral_index)],'Interpreter','none')
%     saveas(fig_temp,strcat(folder_path_675nm_boxplot,filesep,coral_id(coral_index), '_675nm_chl_a_boxplot.jpg'))
%     close(fig_temp)
% 
%     %% Peridinin = mean(510-610nm) [2] 
%     % Find wavelength index for 510nm and 610nm
%     wavelength_delta = coral_hsi.Wavelength - 510;
%     [~, wavelength_index_510] = min(abs(wavelength_delta));
%     wavelength_delta = coral_hsi.Wavelength - 610;
%     [~, wavelength_index_610] = min(abs(wavelength_delta));
%     % Create data array that excludes masked out regions
%     data_counter = 1;
%     temp_image = [];
%     clearvars data_array
%     for n = 1:size(coral_hsi.DataCube,1)
%         for m = 1:size(coral_hsi.DataCube,2)
%             if sum(coral_hsi.DataCube(n,m,:))
%                 data_array(data_counter) = mean(coral_hsi.DataCube(n,m,wavelength_index_510:wavelength_index_610));
%                 temp_image(n,m) = data_array(data_counter);
%                 data_counter = data_counter + 1;
%             else
%                 temp_image(n,m) = 0;
%             end
%         end
%     end
%     % Median of Peridinin
%     peridinin_median(coral_index) = median(data_array);
%     % Sum of Peridinin
%     peridinin_sum(coral_index) = sum(data_array);
%     % Ratio of Peridinin to size
%     peridinin_per_pixel(coral_index) = peridinin_sum(coral_index)/num_of_pixels(coral_index);
% 
%     % Show peridinin heat map on image
%     fig_temp = figure;
%     imshow(temp_image,[])
%     title(['Heatmap of mean(510-610nm) reflectance (Peridinin proxy) on coral id: ' coral_id(coral_index)],'Interpreter','none')
%     colormap('jet')
%     colorbar
%     saveas(fig_temp,strcat(folder_path_510nm_610nm_heatmap,filesep,coral_id(coral_index), '_510nm_610nm_peridinin_heatmap.jpg'))
%     close(fig_temp)
%     % Show box plot to inspect median and variance
%     fig_temp = figure;
%     boxplot(data_array)
%     title(['Box plot of mean(510-610nm) reflectance (Peridinin proxy) on coral id: ' coral_id(coral_index)],'Interpreter','none')
%     saveas(fig_temp,strcat(folder_path_510nm_610nm_boxplot,filesep,coral_id(coral_index), '_510nm_610nm_peridinin_boxplot.jpg'))
%     close(fig_temp)
% 
% end
% 
% % Create table for excel data export
% coralId = coral_id';
% numOfPixel = num_of_pixels';
% redMedian = red_median';
% chlaMedian = chl_a_median';
% chlaSum = chl_a_sum';
% chlPerPixel = chl_per_pixel';
% peridininMedian = peridinin_median';
% peridininSum = peridinin_sum';
% peridininPerPixel = peridinin_per_pixel';
% 
% table_extracted_features = table(coralId,numOfPixel,redMedian,chlaMedian,chlaSum,chlPerPixel,peridininMedian,peridininSum,peridininPerPixel);
% 
% % Export to excel
% writetable(table_extracted_features,[folder_path_extracted_features filesep 'features.xlsx'])
% 
% % Display run time
% runtime_seconds = toc;
% disp(['Run time: ' num2str(runtime_seconds/60) ' minutes'])