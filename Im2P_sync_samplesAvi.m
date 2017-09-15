%The function finds the sample number of each frame in the avi movie, for
%the frames between laser on and laser off

%The sample is for an arbitrary point in the frame, let's explain:
%Let's say the avi is at 60fps. So ~167 samples/frame. The laser is on somewehre within these 167 frames. Let's say: sample:100
%Now, the sample number for the frame following the 1st one with laser on
%will be defined here to be sample 100 + dS, where dS is (time between the
%two avi frames from the .h5 file in seconds)*nSamplesPerSecond, and so on
%for the next frames


%IMPORTANT: The code here assumes that a few files already exist at this point:
%(1)*LaserONOFFinMovie.mat (found by SyncVRFrames_AVIandLASER) 
%(2).h5 files - timestemps from the pointgrey camera - saved duing the experiment
%(3)*TiffStarts_FromMirrors found by the function SyncVRFrames_AVIandLASER
%is loaded to get the Laser On and Off *sample* number


%LaserOn_Vs_AVI_duration is the difference in ms between: 
%laser on to laser off duration     and     AVI frames with laser on duration
function  sOneSession = Im2P_sync_samplesAvi(Folder, IsOverride)

if nargin == 1, IsOverride = 0; end

disp('Running the function Im2P_sync_samplesAvi')

%Parameters
nSamplesPerSecond = 10000;
nFps = 60;

CurrDir = cd(Folder);

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
      
if isfield(sOneSession,'Samples_AVIFrames') && ~isempty(sOneSession.Samples_AVIFrames) && ~IsOverride
    disp('The field Samples_AVIFrames already exists and is not empty. Override sets to: No. Returning.')
    return
end
  

%Chek that and already exist - otherwise can't synchronize
if ~isfield(sOneSession,'LaserOnFrame') || ~isfield(sOneSession,'LaserOffFrame') ||...
        isempty(sOneSession.LaserOnFrame) || isempty(sOneSession.LaserOffFrame)
    disp('Missing AviFrame on Laser On/Off, cant synchronize. Returning.')
    cd(CurrDir)
    return
end


%% OK, let's start synchronizing...
LaserOnFrame = sOneSession.LaserOnFrame;
LaserOffFrame = sOneSession.LaserOffFrame;

% %Get the sample number of the tiff files
% Tiff_Start_samples = dir('*Mirrors*.mat');
% if isempty(Tiff_Start_samples),disp('No Tiff_Start_samples, returning'),cd(CurrDir),return,end
% load(Tiff_Start_samples(1).name)

%Find timestemps on shutter off
fnames_Stamp = dir('*.h5');
if ~isempty(fnames_Stamp), timeStamps = h5read(fnames_Stamp(1).name,'/timeStamps');else timeStamps = [];end

%call to the function that reads timestamps
if ~isempty(timeStamps)
Corrected_shutterTime = stamps2times(timeStamps);  
else
    disp('No shutter times'), cd(CurrDir);return
end


Samples_AVIFrames(1:length(LaserOnFrame:LaserOffFrame),1) = LaserOnFrame:LaserOffFrame;
Samples_AVIFrames(1:length(LaserOnFrame:LaserOffFrame),2) =...
    (Corrected_shutterTime(LaserOnFrame:LaserOffFrame) - Corrected_shutterTime(LaserOnFrame))*nSamplesPerSecond + 1;

LaserOn_Vs_AVI_duration = (Samples_AVIFrames(end,2) - sOneSession.LaserOffSample)/10;%in miliseconds
if abs(LaserOn_Vs_AVI_duration) > 1000/nFps
   disp('Time between first/last avi with LASER_ON doesnt match LASER_ON total time'),
end

sOneSession.Samples_AVIFrames = Samples_AVIFrames;
sOneSession.LaserOn_Vs_AVI_duration = LaserOn_Vs_AVI_duration;

save(FileName,'sOneSession')
cd(CurrDir)

end