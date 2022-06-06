function enviwriteMyFun(hsi_input,filename_input)
% Save hsi data in a format compatibly with Resonon Spectronon 
% Changing back sensor gain to gain
% Removing curly brackets in rotation
% Rename wavelength units to nm

% Save HSI using MATLAB function
enviwrite(hsi_input,filename_input);

% Rename "sensor gain" to "gain"
% Rename header file to txt to be read
header_file_txt = [filename_input(1:end-3) 'txt'];
movefile(filename_input, header_file_txt);
% Read header text file
fid = fopen(header_file_txt);
header_data = textscan(fid,'%s','delimiter','\n');
fclose(fid);
% Find line where 'gain' is
gain_found_cell = strfind(header_data{1},'gain');
gain_found = ~cellfun(@isempty,gain_found_cell);
gain_index = find(gain_found == 1);
% Rename header file gain value = gain
header_data{1}{gain_index} = header_data{1}{gain_index}(8:end);

% Remove curly brackets from rotation
% Find line where 'rotation' is
rotation_found_cell = strfind(header_data{1},'rotation');
rotation_found = ~cellfun(@isempty,rotation_found_cell);
rotation_index = find(rotation_found == 1);
% Rename header file 
header_data{1}{rotation_index} = erase(header_data{1}{rotation_index},{'{','}'});

% Rename wavelength units to nm
% Find line where 'wavelength units' is
wavelength_found_cell = strfind(header_data{1},'wavelength units');
wavelength_found = ~cellfun(@isempty,wavelength_found_cell);
wavelength_index = wavelength_found == 1;
% Rename header file 
header_data{1}{wavelength_index} = 'wavelength units = nm';

% Write new header
fid = fopen(header_file_txt,'w');
for n = 1:numel(header_data{1,1}) 
    fprintf(fid,'%s\r\n',header_data{1,1}{n,1}); 
end
fclose(fid);
% Rename file back to .hdr
movefile(header_file_txt, filename_input);

end

