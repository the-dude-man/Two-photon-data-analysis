%Im2P_SampleTIFFandAVI_forROI saves a single Tiff frame and a single avi
%frame (if .avi exists) for the session. Used later for choosing ROI (currently manualy):
%Tiff - for DF/F
%AVI - square between the eyes, used to find laser on/off

function sOneSession = Im2P_SampleTIFFandAVI_forROI(Folder)
%Folder = 'Z:\Dudi\Imaging\2Photon\Diego_setup\DSX_2P_Playback\20161010\20161010_402';

%Parameters
ROIFrame = 10;

CurrDir = cd(Folder);

%Name of file to save (and to check if alredy exists)
S = pwd;
FILESEP = strfind(S,filesep()); FILESEP = FILESEP(end);
FileName = ['OneSession','_',S(FILESEP+1:end),'.mat'];

%OneSession structure already made for this folder?
if exist(FileName,'file')
    disp(['The file ',FileName,' already exists, adding info to it.']),
    load(FileName)
else
    sOneSession = struct('ImMeta',[],'TiffFrame',[],'AVIFrame',[]);
end



%Tiff file
TiffFiles = dir('*.tif');
tifname = TiffFiles(1).name;
tifname = tifname(1:end-4);

[Data, ImMeta] = Im2P_singletiff2mat(tifname, 0);
sOneSession.ImMeta = ImMeta;
if ~(sOneSession.ImMeta.GCaMP_Ch == 1 || sOneSession.ImMeta.GCaMP_Ch == 2)
    disp(['Folder ',Folder,', GCaMP channel undefined. Function Im2P_SampleTIFFandAVI_forROIReturning is returning'])
    sOneSession.TiffFrame = [];
end
GCaMP_Channel = sOneSession.ImMeta.GCaMP_Ch;
sOneSession.TiffFrame = mean(Data(:,:,:,GCaMP_Channel),3);


%avi file
VIDfiles = dir('*.avi');
Nfiles = size(VIDfiles,1);
if isempty(VIDfiles) || size(VIDfiles,1)>2
    disp(['Folder ',Folder,',no avi file or more than 2 avi fles.'])
    sOneSession.AVIFrame = [];
else%1 or two .avi files. If two - one of them is the debug file.
    for ii = 1:Nfiles
        if ~strcmp(VIDfiles(ii).name,'debug')
            VideoFile = VIDfiles(ii).name;
            vr = VideoReaderFFMPEG(VideoFile);
            FRAME = read(vr,ROIFrame);
            sOneSession.AVIFrame = FRAME;
        end
    end
end


save(FileName,'sOneSession')
cd(CurrDir)

end

