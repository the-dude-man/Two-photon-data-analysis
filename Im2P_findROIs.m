function sOneSession = Im2P_findROIs(Folder, IsOverride, ROIs)
%Dudi Deutsch, Princeton, Nov 2016

if nargin == 1
    IsOverride = 0;
end  
    
if nargin < 3
    ROIs = {'PC2Cell','LPC','PC1Cell'}; 
end

disp('Running the function Im2P_findROIs')

CurrDir = cd(Folder);

%Parameters
Sides = {'Left','Right'};

%Name of file to save (and to check if alredy exists)
S = pwd;
FILESEP = strfind(S,filesep()); FILESEP = FILESEP(end);
FileName = ['OneSession','_',S(FILESEP+1:end),'.mat'];

%OneSession structure already made for this folder?
if ~exist(FileName,'file')
    disp(['Folder ',Folder,', the file ',FileName,' doesnt exist. Returning.'])
    sOneSession = []; cd(CurrDir)
    return
end

load(FileName)%sOneSession

%Find ROIs in Tiff
nROI_Index = 1;

if ~isfield(sOneSession,'TiffFrame')
    disp(['Folder ',Folder,', No Tif Frame in sOneSession. Returning.'])
    cd(CurrDir),return
end

%Check if ROIs are already definde. If yes - override??
if isfield(sOneSession,'ROIname') && ~IsOverride
    cd(CurrDir),return
else
    sOneSession.ROIname = []; sOneSession.ROISide = []; sOneSession.ROIRepeatNumber = [];
    sOneSession.TiffROI = []; sOneSession.AVIROI = [];
    
end

while 1 %multipe ROIs are possible
    I = mean(sOneSession.TiffFrame,3);%Choose ROI for signal calculations
    disp(['Draw ROI for folder: ',Folder])
    fig = figure;
    BW = roipoly(I/max(max(I)));
    close(fig)
    %ROI = reshape(BW,size(BW,1)*size(BW,2),1);%coordinates of pixels in ROI
    disp(['ROI ',num2str(nROI_Index),' is drawn'])
    ROIname = questdlg('Choose ROI','',ROIs{1},ROIs{2},ROIs{3},ROIs{1});
    ROIside = questdlg('Choose side','',Sides{1},Sides{2},Sides{2});
    ROI_IsLast = questdlg('Was it the last ROI?','','Yes','No','Yes');
    ROIRepeat = 1;%1 is the default (ROIRepeat>1 only if the same ROIname and side already exist)
    if nROI_Index >1
        PreviousROIsNames = sOneSession.ROIname;
        PreviousROIsSide = sOneSession.ROISide;
        ROIRepeat = UpdateROIName(ROIname,ROIside,PreviousROIsNames,PreviousROIsSide);      
    end
    sOneSession.ROIname{nROI_Index} = ROIname;
    sOneSession.ROISide{nROI_Index} = ROIside;
    sOneSession.ROIRepeatNumber = ROIRepeat;
    sOneSession.TiffROI{nROI_Index} = BW;
    nROI_Index = nROI_Index + 1;
    if strcmp(ROI_IsLast,'Yes'), break, end
end


%Find ROI in avi (for Laser ON/OFF detection)
if ~isfield(sOneSession,'AVIFrame') || isempty(sOneSession.AVIFrame)
    disp(['Folder ',Folder,', No AVI Frame in sOneSession. Returning.'])
else
    I = mean(sOneSession.AVIFrame,3);%choose ROI between fly eyes
    disp('Draw ROI...')
    fig = figure;
    BW = roipoly(I/max(max(I)));
    close(fig)
    sOneSession.AVIROI = BW;
    disp(['AVIROI is drawn for Session ',Folder])
end

save(FileName,'sOneSession')
cd(CurrDir)
end




function ROIRepeat = UpdateROIName(ROIname,ROIside,PreviousROIsNames,PreviousROIsSide)
%The function UpdateROIName looks at the ROIs that were already chosen to
%check if the same name+side exist. If yes  - add a serial number.
ROIRepeat = 1;%default
for nROI = 1:length(PreviousROIsNames)
    if strcmp(ROIname,PreviousROIsNames{nROI}) && strcmp(ROIside,PreviousROIsSide{nROI})
        ROIRepeat = ROIRepeat + 1;
    end
end
end


