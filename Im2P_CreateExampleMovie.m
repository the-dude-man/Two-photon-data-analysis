

%Parameters
%Folder = 'Z:\Dudi\Imaging\2Photon\Diego_setup\DSX_2P_Playback\20161215\20161215_105';
Folder = 'Z:\Dudi\Imaging\2Photon\Dudi_setup\DSX_VR2P_Auditory\20170511\20170511_203';
Trial = 203;
Is_2PVR = 1;
FrameStartMovie = 200;
FrameEndMovie = 600;

%MovieName
Slash = strfind(Folder,filesep); Slash = Slash(end);
MovieName = [Folder(Slash+1:end),'_',num2str(Trial),'_',num2str(FrameStartMovie),'_',num2str(FrameEndMovie),'_ResponseExample.avi'];

CurrDir = cd(Folder);
TiffFiles = dir(['*_',num2str(Trial),'*.tif']);
OneSession = dir('OneSession*');

if ~Is_2PVR && ~(size(TiffFiles,1) == 1 && size(OneSession,1) == 1)
    Disp('Need to have exactly one Tiff file for the trial and one OneSession.mat for the session')
    cd(CurrDir)
    return
elseif Is_2PVR && size(OneSession,1) == 1 && size(TiffFiles,1) > 1
    TiffFiles = TiffFiles(2);
end


%load/read files
tifname = fullfile(pwd,TiffFiles(1).name); tifname = tifname(1:end-4); %remove the .tif extension
Onesession_name = fullfile(pwd,OneSession(1).name);

load(Onesession_name)
[Data, ~] = Im2P_singletiff2mat(tifname, 0);

if FrameStartMovie > size(Data,3) || FrameEndMovie > size(Data,3)
    disp('Start/End movies cant exceed the number of frames')
    cd(CurrDir)
    return
end


%Get info from sOneSession
GreenCh = sOneSession.ImMeta.GCaMP_Ch;
SamplesPerSeconds = sOneSession.LOGfile{2,2};
fps = SamplesPerSeconds/median(diff(sOneSession.SamplesStart_ImFrames(:,1)));
FrameStartStim = round(sOneSession.LOGfile{1,4}/1000*fps);
FrameEndStim = size(Data,3) - round((sOneSession.LOGfile{1,5})/1000*fps);



%Write movie
outputVideo = VideoWriter(MovieName);
outputVideo.FrameRate = fps;
outputVideo.Quality = 100;
open(outputVideo);

for nTifFrame=FrameStartMovie:FrameEndMovie
    disp(num2str(nTifFrame))
    grayImage = mat2gray(double(Data(:,:,nTifFrame,GreenCh)),[0 200]);
    rgbImage = cat(3, zeros(size(grayImage)), grayImage, zeros(size(grayImage)));
    if nTifFrame >= FrameStartStim && nTifFrame < FrameEndStim %Add a small box at the corner when the stimulus is in
        rgbImage(1:20,1:20,1) = 51/255;% Red
        rgbImage(1:20,1:20,2) = 51/255;% Green
        rgbImage(1:20,1:20,3) = 255/255;% Blue
    end
    imshow(rgbImage)
    writeVideo(outputVideo,rgbImage);
end
close(outputVideo)


cd(CurrDir)

