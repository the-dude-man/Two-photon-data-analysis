 function sOneSession = Im2P_sync_samplesTifs(Folder, IsOverride)
%Dudi Deutsch, Princeton, Nov 2016

%This function returns the samples of "start of image scan" in the two
%photon microscope, based on the mirror location in y that is read directly
%from the mirror control signal

if nargin == 1, IsOverride = 0; end

disp('Running the function Im2P_sync_samplesTifs')

%Parameters
nPlot = 0;


CurrDir = cd(Folder);

%Name of file to save (and to check if alredy exists)
S = pwd;
FILESEP = strfind(S,filesep()); FILESEP = FILESEP(end);
FileName = ['OneSession','_',S(FILESEP+1:end),'.mat'];

%OneSession structure already made for this folder?
if exist(FileName,'file')
    load(FileName)
else
    disp(['Missing structure sOneSession for folder ',Folder,' Returning.'])
    sOneSession = -1;
    return
end
    
    
if isfield(sOneSession,'LaserOnSample') && ~isempty(sOneSession.LaserOnSample) && ~IsOverride
    disp('The field LaserON already exists and is not empty. Override sets to: No. Returning.')
    return
end


BinFile = dir('*bin.mat'); 
if size(BinFile,1)~=1, disp('Need to have exactly 1 bin file. Returning.'),return,end

BinFile = BinFile(1).name;

tmp = load(BinFile,'data');
data = tmp.data;
D = diff(double(data(:,3)));
S = sort(D(1:round(length(D)/2)));
[pks,loc ] = findpeaks(-D);
Start_Frame = loc(pks>-0.8*(mean(S(2:11))) & pks<-1.2*(mean(S(1:10)))) + 10;
LaserOFF = Start_Frame(end) - 10;

Start_Frame = [1;Start_Frame(1:end-1)];
LaserON = 1;


if nPlot == 1
figure(1),hold off
plot(data(:,3)), hold on
plot(Start_Frame,data(Start_Frame,3),'*r')
end

nIndexIn_Start_Frame = 1;
mTiffs = zeros(size(Start_Frame,2),2);
Files = dir('*.tif');

sOneSession.NumberOfTifs = size(Files,1);
for nTiffFile = 1:size(Files,1)
    UnderScore = strfind(Files(nTiffFile).name,'_'); UnderScore = UnderScore(end);
    Point = strfind(Files(nTiffFile).name,'.tif');
    tifNumber = str2double(Files(nTiffFile).name(UnderScore+1:Point-1));
    disp(['Reading number of frames from tiff file ',num2str(tifNumber),' out of ',num2str(size(Files,1))])
    try
        info = imfinfo(Files(nTiffFile).name);
    catch
        disp(['File ',Folder,'_',num2str(tifNumber),' is probably corrupted. ',num2str(nTiffFile-1),' tif files are OK.'])
        sOneSession.NumberOfTifs = min(sOneSession.NumberOfTifs,tifNumber-1);
        continue
    end
    if isfield(info,'ImageDescription')
    FindCh = strfind(info(1).ImageDescription,'channelsAvailable = ');
    ImChannels = str2double(info(1).ImageDescription(FindCh(1)+20));
    else
    ImChannels = sOneSession.ImMeta.ChNum;
    end
    S = size(info,1)/ImChannels;

    mTiffs(nIndexIn_Start_Frame:nIndexIn_Start_Frame+S-1,1) =tifNumber;%Tiff file number
    mTiffs(nIndexIn_Start_Frame:nIndexIn_Start_Frame+S-1,2) =1:S;%Frame in current Tiff file
    nIndexIn_Start_Frame = nIndexIn_Start_Frame + S;
end

mTiffs = sortrows(mTiffs,1);
Start_Frame(1:size(mTiffs,1),2:3) = mTiffs;

SamplesStart_ImFrames = Start_Frame;
LastTiff = find(Start_Frame(:,2)==0,1) - 1;
if ~isempty(LastTiff), SamplesStart_ImFrames = Start_Frame(1:LastTiff,:);end

%legend - describes the columns in SamplesStart_ImFrames
SamplesTiffs_fields = {'Sample at start frmae','Frame number in session','Tif file number',...
    'Frame number in Tif file'};

sOneSession.LaserOnSample = LaserON;
sOneSession.LaserOffSample = LaserOFF;
sOneSession.SamplesStart_ImFrames = SamplesStart_ImFrames;
sOneSession.SamplesTiffs_fields = SamplesTiffs_fields;
if ~isfield(sOneSession,'NumberOfTifs') || isempty(sOneSession.NumberOfTifs) ||...
 sOneSession.NumberOfTifs > nTiffFile       
sOneSession.NumberOfTifs = nTiffFile;
end

save(FileName,'sOneSession')

cd(CurrDir)

end
