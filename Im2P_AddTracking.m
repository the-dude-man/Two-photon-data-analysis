%This function collects the tracking data from FicTrac output files:
%-debug.avi and .dat

function sOneSession = Im2P_AddTracking(Folder, IsOverride)
%Folder = 'Z:\Dudi\Imaging\2Photon\Dudi_setup\DSX_VR2P_Auditory\20170425\20170425_210';
%IsOverride = 0;

if nargin == 1, IsOverride = 0; end

disp('Running the function Im2P_AddTracking')


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
    
    
if isfield(sOneSession,'FicTrac_datfile') && ~isempty(sOneSession.FicTrac_datfile) && ~IsOverride
    disp('The field FicTrac_datfile already exists and is not empty. Override sets to: No. Returning.')
    return   
end

%.dat file = FicTrac output
datfile = dir('*.dat');
if ~size(datfile,1) == 1, disp('No .dat file or more than one .dat file. Returning.')
    cd(CurrFolder)
    return
end

%output file from FicTrac (.dat file)
datfile = datfile(1).name;
DAT = importdata(datfile);

sOneSession.FicTracOUT = DAT;
sOneSession.FicTrac_FrameNumberComment = ['The frame number in .dat(:,1) is consistent with the frame number in -debug.avi, but not with the frame number in the original. '...
'Need to substruct 33 from the frame in .dat to get the corresponding frame number in the original .avi movie'];

save(FileName,'sOneSession')

cd(CurrFolder)

end