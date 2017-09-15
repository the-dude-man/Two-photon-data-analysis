
function sOneSession = Im2P_AddStimData(Folder, IsOverride)
%Dudi Deutsch, Princeton, Nov 2016

if nargin == 1, IsOverride = 0; end


disp('Running the function Im2P_AddStimData')

CurrDir = cd(Folder);

%remove junk tif files if exist
junktiffiles = dir('tp*.tif');
if ~isempty(junktiffiles)
    for ii = 1:size(junktiffiles,1)
   filename = junktiffiles(ii).name;
   delete(filename)
    end
end

%OneSession structure already made for this folder?
S = pwd;
FILESEP = strfind(S,filesep()); FILESEP = FILESEP(end);
FileName = ['OneSession','_',S(FILESEP+1:end),'.mat'];


if exist(FileName,'file')
    load(FileName)
else
    disp(['Missing structure sOneSession for folder ',Folder,' Returning.'])
    cd(CurrDir)
    sOneSession = -1;
    return
end
      
if isfield(sOneSession,'LOGfile') && ~isempty(sOneSession.LOGfile) && ~IsOverride
    disp('The field LOGfile already exists and is not empty. Override sets to: No. Returning.')
    cd(CurrDir)
    return
end



%Check that relevant fields are not missing from sOneSession
if ~(isfield(sOneSession,'NumberOfTifs')) || isempty(sOneSession.NumberOfTifs)
    disp(['Missing field sOneSession.NumberOfTifs in ',Folder,'. Returning.'])
    return
end

%Load data - vDat
vDatFile = dir('*vDat*');
vDatFile = vDatFile.name;

load(vDatFile)


%%Find the sampling rate
%SamplesPerSeconds = rDat.log{2,2};
%fps = SamplesPerSeconds/median(diff(sOneSession.SamplesStart_ImFrames(:,1)));


Slash = strfind(Folder,filesep()); Slash = Slash(end);
TiffFiles = dir('*.tif');

%Find number of Tiff files and number of stimulations
NumberOfStim = size(rDat.stiStart,1);
vFiles = zeros(1,size(TiffFiles,1));
for nTiffFile = 1:size(TiffFiles,1)
    TiffFileName = TiffFiles(nTiffFile).name;
    Slash = strfind(TiffFileName,'_'); Slash = Slash(end);
    Dot = strfind(TiffFileName,'.');
    TiffFileNumber = str2double(TiffFileName(Slash+1:Dot));
    vFiles(TiffFileNumber) = 1;
end
LastOne =  find(vFiles==1,1,'last');
vFiles = vFiles(1:LastOne);


if ~all(vFiles==1), disp(['Missing Tiff file in ',Folder])
else NumberOfTiffs = min(length(vFiles),sOneSession.NumberOfTifs);
    disp(['For folder (session) ',Folder ,': ',...
        num2str(NumberOfStim),' stims',' and ',num2str(NumberOfTiffs),' Tif files'])
end
if NumberOfTiffs > NumberOfStim
    disp('Note: Number of Tif files is larger than number of stimuli')
end


N_BothStimANDtif = min(NumberOfStim,NumberOfTiffs);

%Stim start end, Stim names
sOneSession.StartStim = rDat.stiStartSample(1:N_BothStimANDtif);
sOneSession.stimOrder = rDat.stimOrder(1:N_BothStimANDtif);
%sanity check
if ~isempty(find(sOneSession.StartStim(2:end)<=0,1)) || ~isempty(find(diff(rDat.stiStartSample(1:N_BothStimANDtif))<0,1))
    disp('Stim start seems wrong, returning.'), cd(CurrDir),return
end


%Update sOneSession
sOneSession.LOGfile = rDat.log(1:N_BothStimANDtif,:);
sOneSession.stimAll = rDat.stimAll;

%Parse the stimulus using it's name from the table
for Stim = 1:min(sOneSession.NumberOfTifs,size(sOneSession.LOGfile,1))
string = sOneSession.LOGfile{Stim,1}{1};
param = Im2P_parseParametersFromFileName(string);
param.Intensity = sOneSession.LOGfile{Stim,7}{1};
sOneSession.StimParams{Stim} = param;
end



save(FileName,'sOneSession')
cd(CurrDir)

