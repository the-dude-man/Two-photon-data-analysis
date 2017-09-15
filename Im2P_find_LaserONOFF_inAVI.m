% The function SyncVRFrames_AVIandLASER goes over all the .avi files in the
% folder and detects laser on/off.

%At this point, the user needs to define the ROI  - the area between (and
%not including) the eyes seems to work well.

%Fufure: detect Laser ON W/O the need for user defined ROI


function sOneSession = Im2P_find_LaserONOFF_inAVI(Folder, IsOverride)

if nargin == 1, IsOverride = 0; end

disp('Running the function Im2P_find_LaserONOFF_inAVI')

%Parameters
Override_LaserOnOff = 1;%If already found - override? [0 - no, 1 - yes]
ROIFrame = 10;
BackGroundFrames = 1:100;
BG = zeros(size(BackGroundFrames));
nStep = 25;%Step size for laser on. The step size for laser off will be double
nMaxFramesSearch = 14400;%at 60fps, the laserON/laserOFF must be at the first/last 5 minutes of the movie to be detected

CurrFolder = cd(Folder);

%OneSession structure already made for this folder?
S = pwd;
FILESEP = strfind(S,filesep()); FILESEP = FILESEP(end);
FileName = ['OneSession','_',S(FILESEP+1:end),'.mat'];

if exist(FileName,'file')
    load(FileName)
else
    disp(['Missing structure sOneSession for folder ',Folder,' Returning.'])
    sOneSession = -1;
    return
end
    
    
if isfield(sOneSession,'LaserOnFrame') && ~isempty(sOneSession.LaserOnFrame) && ~IsOverride
    disp('The field LaserOnFrame already exists and is not empty. Override sets to: No. Returning.')
    return   
end


%Laser on/off already found
if isfield(sOneSession,'LaserOnFrame') && ~isempty(sOneSession.LaserOnFrame) && ~Override_LaserOnOff
    disp('Laser On / Off already found. Not overriding.')
    cd(CurrFolder)
    return
end

%Find .avi file
VidFiles = dir('*.avi');
Nfiles = size(VidFiles,1);
if Nfiles == 0 || Nfiles > 2, disp('No avi or more than one avi'), cd(CurrFolder)
    sOneSession.LaserOnFrame = [];
    sOneSession.LaserOffFrame = [];
    sOneSession.aviFramerate = [];
    return
end

VideoFile = [];
for ii = 1:Nfiles
VideoFile = VidFiles(ii).name;
if ~isempty(strfind(VidFiles(ii).name,'debug')),continue,end
end

if isempty(VideoFile), disp('No avi file (except debug.avi files)'), cd(CurrFolder)
    sOneSession.LaserOnFrame = [];
    sOneSession.LaserOffFrame = [];
    sOneSession.aviFramerate = []; 
end

%Read movie
disp(['Looking for Laser on/off in ',VideoFile])
vr = VideoReader(VideoFile);
FrameRate = vr.FrameRate;
vr = VideoReaderFFMPEG(VideoFile);
vr.FrameRate = FrameRate;
sOneSession.aviFramerate = vr.FrameRate;

%Find ROI (BW - black and white mask)
if ~isfield(sOneSession,'AVIROI') || isempty(sOneSession.AVIROI)
    h = figure(1); close(h), h = figure(1);
    FRAME = read(vr,ROIFrame);
    BW = roipoly(FRAME);
    close(h)
    sOneSession.AVIROI = FRAME;
else
    BW = sOneSession.AVIROI;
end

%find background
disp('Finding background illumination in ROI')
for Frame = BackGroundFrames
    FRAME = read(vr,Frame + 1);
    BG(Frame) = mean(FRAME(BW==1));
end

noise = std(BG(BG<prctile(BG,20)));

%Find laser on
nFlag = 0;
%Find the laser on block
LightInROI = zeros(1,vr.NumberOfFrames);
for nFrameBlock = 2*nStep+1:nStep:nMaxFramesSearch
    disp(['Searching for LASER ON in blocks, frame ' ,num2str(nFrameBlock)])
    FRAME = read(vr,nFrameBlock);
    LightInROI(nFrameBlock) = mean(FRAME(BW==1)) - prctile(BG,20);
    if LightInROI(nFrameBlock) > 100 * noise && nFlag == 1
        break
    end
    nFlag = 1;
end

%Find the laser ON frame
LightInROI = zeros(1,nFrameBlock-1);
for nFrame = nFrameBlock-nStep:nFrameBlock-1
    FRAME = read(vr,nFrame);
    LightInROI(nFrame) = mean(FRAME(BW==1)) - prctile(BG,20);
end

Laser_ON = find(diff(LightInROI) == max(diff(LightInROI)));
disp(['LASER ON, frame: ', num2str(Laser_ON)])


%find "laser off" block
nFlag = 0;
LightInROI = zeros(1,vr.NumberOfFrames);
for nFrameBlock = vr.NumberOfFrames-2*nStep:-2*nStep:vr.NumberOfFrames - nMaxFramesSearch
    disp(['Searching for LASER OFF in blocks, frame ' ,num2str(nFrameBlock)])
    FRAME = read(vr,nFrameBlock);
    LightInROI(nFrameBlock) = mean(FRAME(BW==1)) - prctile(BG,20);
    
    if LightInROI(nFrameBlock) > 100 * noise && nFlag == 1
        break
    end
    nFlag = 1;
end

%Find the laser OFF frame
LightInROI = zeros(1,nFrameBlock-1);
for nFrame = nFrameBlock-1:nFrameBlock+2*nStep+1
    FRAME = read(vr,nFrame);
    LightInROI(nFrame) = mean(FRAME(BW==1)) - prctile(BG,20);
end
Laser_OFF = find(diff(LightInROI) == min(diff(LightInROI)));
disp(['LASER OFF, frame: ', num2str(Laser_OFF)])


if ~exist('Laser_ON','var') && ~exist('Laser_OFF','var')
    sOneSession.LaserOnFrame = []; sOneSession.LaserOffFrame = [];
    disp('Laser on/off are both undetected')
elseif ~exist('Laser_ON','var')
    disp('Laser on is undetected')
elseif ~exist('Laser_OFF','var')
    disp('Laser off is undetected')
else
    sOneSession.LaserOnFrame = Laser_ON;
    sOneSession.LaserOffFrame = Laser_OFF;
    save(FileName,'sOneSession')
    FileName = [VideoFile(1:end-4), 'LaserUndetectedinAVI.mat'];
    if exist(FileName,'file'),delete(FileName),end
end

delete('tp*.tif')%temporary files
cd(CurrFolder)

end


