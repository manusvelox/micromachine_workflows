function [ CHA, CHB ] = readDualChannelDaqData( fileName )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    idx = 1;
    fileID = fopen(fileName, 'r');
    status = fseek(fileID,4*(idx - 1), 'bof');
    rawData= fread(fileID, [2 inf], 'uint16');
    fclose(fileID);

    % Bitshift, scale, and shift the data
    rawData = bitshift(rawData, -4);
    bits = 12;          % [1] DAQ is 12 bit resolution
    levels = 2^bits;    % [1] Number of DAQ input states
    range = 0.8;        % [V] DAQ has +- 400 mV input range
    dataVolts = range*(rawData - levels/2)/levels;  % [V] scale and shift channel A signal

%    dataVolts =  (rawData - 2048)*.4/2048;
    
    
    % Extract channels
    CHA = dataVolts(1:2:end);
    CHB = dataVolts(2:2:end);
    
    clear dataVolts;
    clear rawData;



end

