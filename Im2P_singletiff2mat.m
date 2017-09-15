function [Data, ImMeta] = singletiff2mat(tifname, showError)
%% Reading a tiff file
% This assumes the file is a Z stack from 2 channels
%% getting StartOffset per tiff file
if ~exist('showError', 'var'); showError = 0; end

%find ScanImage version
info = imfinfo(fullfile([tifname, '.tif']));
Imclass = getClass(info);


TEMP = strfind(info(1).ImageDescription,'scanimage.SI.VERSION_MAJOR');
VERSION = info(1).ImageDescription(TEMP+29:TEMP+33);
if isempty(VERSION)
    TEMP = strfind(info(1).ImageDescription,'state.software.version');
    VERSION = info(1).ImageDescription(TEMP+23:TEMP+26);
elseif strfind(VERSION,'.')
    VERSION = VERSION(2:end-1);
end
VERSION = str2double(VERSION);


try
    switch VERSION
        case 3.8 %Old galvo two photon system downstairs 
            [X, Y, Channels, Zoom, Power, Z] = TiffMetadataOld(info);
            GCaMP_Ch = 2;
        case 5.1 %Galvo two photon system upstairs (same hardware as old, but newer version of ScanImage)
            [X, Y, Channels, Zoom, Power, Z] = TiffMetadata(info);
            GCaMP_Ch = 2;
        case 2015 %Resonant two photon downstairs. In this case, later, Data = flipud(Data)
            [X, Y, Channels, Zoom, Power, Z] = TiffMetadata(info);
            GCaMP_Ch = 1;
        otherwise
            disp('Unknown scanimage version. Returning.')
            Data = []; ImMeta = [];
            return
    end
    
    
    StartOffset = cell2mat({info.StripOffsets}'); % getting frame offset
    StartOffset = StartOffset(:, 1);
    Frames = numel(StartOffset)/Channels;
    % prealocating data
    Data = zeros(X, Y, Frames, Channels);
    
    for FrameIdx = 1:Frames
        if Channels > 1
            Data(:, :, FrameIdx, 2) = frame2mat(tifname, X, Y, StartOffset((FrameIdx - 1)*2 + 1), Imclass); % odd, Green
            Data(:, :, FrameIdx, 1) = frame2mat(tifname, X, Y, StartOffset(FrameIdx*2), Imclass); % even, Red
        else
            Data(:, :, FrameIdx, 1) = frame2mat(tifname, X, Y, StartOffset(FrameIdx), Imclass); % all, single channel (whatever that is)
        end
    end
    
    %if VERSION == 2015, Data = flipud(Data); end
       
    
    ImMeta.X = X; ImMeta.Y = Y; ImMeta.Z = Z;
    ImMeta.ChNum = Channels;
    ImMeta.GCaMP_Ch = GCaMP_Ch;
    ImMeta.Zoom = Zoom;
    ImMeta.Power = Power;
    ImMeta.Imclass = Imclass;
    ImMeta.ScanImageVersion = VERSION;
catch error
    if showError == 1
        fprintf(['could not run file', strrep(tifname, '\', ''), '\n']); display(error)
    end
end
end

function predata = frame2mat(BaseName, X, Y, StartOffset, Imclass)
fid = fopen(fullfile([BaseName, '.tif']));
fseek(fid,StartOffset,'bof');
predata = fread(fid, X*Y, ['*', Imclass]); % We knew this from BitsPerSample
fclose(fid);
predata = double(reshape(predata, Y, X)');
% this might change when scanimage is fixed to
% predata = double(reshape(predata, X, Y));
% however it does not matter if X and Y are the same value
end

function Imclass = getClass(info)
microscopetxt = info(1).ImageDescription;
if ~isempty(strfind(microscopetxt, 'int16'))
    Imclass = 'int16';
elseif ~isempty(strfind(microscopetxt, 'uint16'))
    Imclass = 'uint16';
elseif ~isempty(strfind(microscopetxt, 'int8'))
    Imclass = 'int8';
elseif ~isempty(strfind(microscopetxt, 'uint8'))
    Imclass = 'uint8';
elseif info(1).BitsPerSample == 16
    Imclass = 'uint16';
end
end

function [X, Y, Channels, Zoom, Power, Z] = TiffMetadataOld(info)
params = strfind(info(1,1).ImageDescription, 'state.');
for pIdx = 2:numel(params)
    if pIdx == numel(params)
        eval([info(1,1).ImageDescription(params(pIdx):end-1),';'])
    else
        eval([info(1,1).ImageDescription(params(pIdx):params(pIdx+1)-2),';'])
    end
end
X = state.acq.linesPerFrame; % Lines per frame or height
Y = state.acq.pixelsPerLine; % or Width
Channels = state.acq.numberOfChannelsAcquire;   %Were the 2 channels used?
Zoom = state.acq.zoomFactor;
Power = [];
Z = [];
end

function [X, Y, Channels, Zoom, Power, Z] = TiffMetadata(info)
params = strfind(info(1,1).ImageDescription, 'scanimage.');
for pIdx = 2:numel(params)
    try
        %if pIdx == numel(params) || pIdx == 103 || pIdx == 183 || pIdx == 184 || pIdx == 185
        if pIdx == numel(params) || pIdx == 170 || pIdx == 171 || pIdx == 172
            %eval([info(1,1).ImageDescription(params(pIdx):end-1),';'])
        else
            eval([info(1,1).ImageDescription(params(pIdx):params(pIdx+1)-2),';'])
        end
    catch
        fprintf([num2str(pIdx), ' '])
    end
end
X = scanimage.SI.hRoiManager.linesPerFrame;
Y = scanimage.SI.hRoiManager.pixelsPerLine;
Z = scanimage.SI.hFastZ.numFramesPerVolume;
Channels = sum(scanimage.SI.hChannels.channelSave > 0); %Were the 2 channels used?
Zoom = scanimage.SI.hRoiManager.scanZoomFactor;
Power = scanimage.SI.hBeams.powers;
end