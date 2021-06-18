%% Read Data from ATS9360 bin files by group of lines

function [dataOut] = readBinFile(fileName)%(fileName, numLines)

    if (length(strfind(fileName, '/')) || length(strfind(fileName, '\') ~= 0))
        fprintf('Full Output File Path Provided\n');
        fileID = fopen(fileName);
    else
        fprintf('No File Path/Directory Provided\n');
        fprintf('Finding File in Local Directory\n');
        fprintf(strcat(pwd, '/',fileName,'\n'));
        fileID = fopen(strcat(pwd, '/',fileName), 'r');
    end
    dataIn = fread(fileID, 'uint16');
    dataOut = bitshift(dataIn, -4);
    fclose(fileID);
    
end