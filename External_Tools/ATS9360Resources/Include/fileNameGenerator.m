%% fileNameGenerator(path_name, extension, overwrite (opt))
% INPUTS: - path (full or partial path to file, '' for 
% This program creates a unique filename based upon the input directory and
% file name. If the provided file name overlaps a pre-existing file, the 
% date and time will be appended (if not already selected). If this still is not unique, a sequential
% number is appended. The unique name generation prevents overwriting of
% files unless it is disabled (overwrite = 1)

function [filePathNameExt] = fileNameGenerator(path_name_ext, datetimestamp, overwrite)

% Optional overwrite flag can disable automatic overwrite protection
if ~exist('overwrite', 'var')
    overwrite = 0;
end
% Optional datetimestamp flag adds the date and time to the file name
% before the extension
if ~exist('datetimestamp', 'var')
    datetimestamp = 0;
end


    % Attempt to strip extension from filename, if included
    if strfind(path_name_ext, '.')
        nameChunks = strsplit(path_name_ext, '.');
        extension = strcat('.', nameChunks{end});
        path_name_ext = path_name_ext(1:end-length(nameChunks{end})-1);
    else
    % Otherwise, no extension at all
    extension = '';
    end



% Assemble the file name
testFileName = strcat(path_name_ext, extension);

% If this is unique (or overwrite okay), and date/time not requested, return the file name
if (~exist(testFileName, 'file') || overwrite) && datetimestamp == 0
    filePathNameExt = testFileName;
    return
end

% Add date and time, if unique (or overwrite okay) return new file name
timeStamp = datestr(now, 'yyyymmdd_HHMM');

testFileName = strcat(path_name_ext, '_', timeStamp, extension);

if (~exist(testFileName, 'file') || overwrite)
    filePathNameExt = testFileName;
    return
end

% If still not unique with date/time, find how many overlapping files, add
% number to differentiate.
fileNum = length(dir(strcat(path_name_ext, '*', timeStamp, extension)))+1;
filePathNameExt = strcat(path_name_ext, '_', num2str(fileNum), '_', timeStamp, extension);

end