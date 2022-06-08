function output_hcube = hypercubeMyFun(filename)
% Slight modification of hypercube to account for missing headers
% Save orginal as appended "_original"

% Check if filename is the header file
if ~isfile(filename)
    error('File name does not exist.')
end

if ~strcmpi(filename(end-2:end),'hdr')
    error('Input is not header file. Select .hdr file.')
end

filename_original = [filename(1:end-4) '.hdr_original'];

% Check if orignal exists, do not overwrite if it does
if ~isfile(filename_original)
% Make copy of original hdr file
    copyfile(filename, filename_original);
end

try 
    hypercube(filename);
catch ME
    switch ME.message
        % Resonon file name mismatch
        case 'Expected Gain values in input header file to be an array with number of elements equal to 462.'
            % Rename header file to txt to be read
            header_file_txt = [filename(1:end-3) 'txt'];
            movefile(filename, header_file_txt);
            % Read header text file
            fid = fopen(header_file_txt);
            header_data = textscan(fid,'%s','delimiter','\n');
            fclose(fid);
            % Find line where 'gain' is
            gain_found_cell = strfind(header_data{1},'gain');
            gain_found = ~cellfun(@isempty,gain_found_cell);
            gain_index = find(gain_found ==1);
            % Rename header file gain value = sensor gain
            header_data{1}{gain_index} = ['sensor ' header_data{1}{gain_index}];
            % Write new header
            fid = fopen(header_file_txt,'w');
            for n = 1:numel(header_data{1,1}) 
                fprintf(fid,'%s\r\n',header_data{1,1}{n,1}); 
            end
            fclose(fid);
            % Rename file back to .hdr
            movefile(header_file_txt, filename);
        case 'Expected HeaderOffset in input header file to be nonempty.'
            % Add header offset into header file
            % Rename header file to txt to be read
            header_file_txt = [filename(1:end-3) 'txt'];
            movefile(filename, header_file_txt);
            % Read header text file
            fid = fopen(header_file_txt);
            header_data = textscan(fid,'%s','delimiter','\n');
            fclose(fid);
            % Find line where 'byte' is
            byte_found_cell = strfind(header_data{1},'byte');
            byte_found = ~cellfun(@isempty,byte_found_cell);
            byte_index = find(byte_found ==1);
            % Append header offset after byte
            for n = length(header_data{1}):-1:byte_index
                header_data{1}{n+1} = header_data{1}{n};
            end
            header_data{1}{byte_index} = 'header offset = 0';
            % Write new header
            fid = fopen(header_file_txt,'w');
            for n = 1:numel(header_data{1,1}) 
                fprintf(fid,'%s\r\n',header_data{1,1}{n,1}); 
            end
            fclose(fid);
            % Rename file back to .hdr
            movefile(header_file_txt, filename);
    end
end
    
output_hcube = hypercube(filename);

end

