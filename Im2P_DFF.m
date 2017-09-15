function sOneSession = Im2P_DFF(Folder, IsOverrideDFF)
%Dudi Deutsch, Princeton, Nov 2016
%See comment around line 74: Can do more accurate using sOneSession.SamplesStart_ImFrames !!!!!

if nargin == 1, IsOverrideDFF = 0; end

disp('Running the function Im2P_DFF')

%Parameters
SecondsAroundPeak = 0.2;%Image is averages +- SecondsAroundPeak around peak DFF to see where is the peak response


%Check that all the relevant flieds exist in sOneSession
%OneSession structure already made for this folder?
CurrDir = cd(Folder);
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

if isfield(sOneSession,'GreenSignal') && ~isempty(sOneSession.GreenSignal) && ~IsOverrideDFF
    disp('The field GreenSignal already exists and is not empty. Override sets to: No. Returning.')
    return
end

IsAllFields(1) = isfield(sOneSession,'ImMeta') && ~isempty(sOneSession.ImMeta);
IsAllFields(2) = isfield(sOneSession,'TiffROI') && ~isempty(sOneSession.TiffROI);
IsAllFields(3) = isfield(sOneSession,'SamplesStart_ImFrames') && ~isempty(sOneSession.SamplesStart_ImFrames);
IsAllFields(4) = isfield(sOneSession,'StartStim') && ~isempty(sOneSession.StartStim);
IsAllFields(5) = isfield(sOneSession,'stimAll') && ~isempty(sOneSession.stimAll);

if ~all(IsAllFields==1), disp(['Missing fields in sOneSession for ',Folder]),return,end

%Find the sampling rate
SamplesPerSeconds = sOneSession.LOGfile{2,2};
fps = SamplesPerSeconds/median(diff(sOneSession.SamplesStart_ImFrames(:,1)));
FramesAroundPeak = round(SecondsAroundPeak*fps);


%Tiff files
vDatFile = dir('*vDat*');vDatFile = vDatFile.name;
load(vDatFile)
TiffFiles = dir('*.tif');

%Find number of Tiff files and number of stimulations
NumberOfTifs = sOneSession.NumberOfTifs;
GreenCh = sOneSession.ImMeta.GCaMP_Ch;
if sOneSession.ImMeta.ChNum == 2, RedCh = 3 - sOneSession.ImMeta.GCaMP_Ch; end
GreenSignal = struct; RedSignal = struct;
sOneSession.GreenSignal = [];
sOneSession.RedSignal = [];

for nROI = 1:length(sOneSession.TiffROI)%loop over ROIs
    
    ROI = sOneSession.TiffROI{nROI};
    ReshapedROI = reshape(ROI,size(ROI,1)*size(ROI,2),1);
    
    for nTiffFile = 1:size(TiffFiles,1)
        tifname = TiffFiles(nTiffFile).name; tifname = tifname(1:end-4);
        Underscore = strfind(tifname,'_'); Underscore = Underscore(end);
        TifNumber = str2double(tifname(Underscore+1:end));
        
        if ~isempty(strfind(tifname,'stack')), continue,end%Zstack
        if TifNumber > NumberOfTifs-1
            sOneSession.NumberOfTifs = NumberOfTifs-1;
            continue
        end
        FrameStartStim = round(sOneSession.LOGfile{1,4}/1000*fps);%converst miliseconds to frame number
        %Can do more accurate using sOneSession.SamplesStart_ImFrames !!!!!
        
        disp(['ROI ',num2str(nROI),'/',num2str(length(sOneSession.TiffROI)),...
            ' ,Reading Tif ',num2str(nTiffFile),' out of ',num2str(size(TiffFiles,1)),',Tifname: ',tifname])
        
        [Data, ~] = Im2P_singletiff2mat(tifname, 0);
        Green = Data(:,:,:,GreenCh);
        Green = reshape(Green,size(Green,1)*size(Green,2),size(Green,3));
        if  sOneSession.ImMeta.ChNum == 2
            Red = Data(:,:,:,RedCh);
            Red = reshape(Red,size(Red,1)*size(Red,2),size(Red,3));
        end
        GreenSignal.FinROI{TifNumber} = mean(Green(ReshapedROI,:));
        GreenSignal.DFFinROI{TifNumber} = (GreenSignal.FinROI{TifNumber} - mean(GreenSignal.FinROI{TifNumber}(1:FrameStartStim-1)))/...
            mean(GreenSignal.FinROI{TifNumber}(1:FrameStartStim-1));
        GreenSignal.MaxDFF{TifNumber} = max(GreenSignal.DFFinROI{TifNumber});
        peakframe = find(GreenSignal.DFFinROI{TifNumber} == GreenSignal.MaxDFF{TifNumber},1);
        GreenSignal.FrameNumber_MaxDFF{TifNumber} = peakframe;
        nStart = max(peakframe - FramesAroundPeak,10);
        nEnd = min(peakframe + FramesAroundPeak,size(Data,3)-10);
        SignalAroundPeak = mean(Data(:,:,nStart:nEnd,GreenCh),3);
        Background = mean(Data(:,:,1:FrameStartStim-1,GreenCh),3);
        GreenSignal.TiffatMaxDFF_minusBG{TifNumber} = SignalAroundPeak - Background;
        
        if  sOneSession.ImMeta.ChNum == 2
            RedSignal.FinROI{TifNumber} = mean(Red(ReshapedROI,:));
            RedSignal.DFFinROI{TifNumber} = (RedSignal.FinROI{TifNumber} - mean(RedSignal.FinROI{TifNumber}(1:FrameStartStim-1)))/...
                mean(RedSignal.FinROI{TifNumber}(1:FrameStartStim-1));
            RedSignal.MaxDFF{TifNumber} = max(RedSignal.DFFinROI{TifNumber});
            peakframe = find(RedSignal.DFFinROI{TifNumber} == RedSignal.MaxDFF{TifNumber},1);
            RedSignal.FrameNumber_MaxDFF{TifNumber} = peakframe;
            nStart = max(peakframe - FramesAroundPeak,10);
            nEnd = min(peakframe + FramesAroundPeak,size(Data,3)-10);
            SignalAroundPeak = mean(Data(:,:,nStart:nEnd,RedCh),3);
            Background = mean(Data(:,:,1:FrameStartStim-1,RedCh),3);
            RedSignal.TiffatMaxDFF_minusBG{TifNumber} = SignalAroundPeak - Background;
        else
            RedCh = [];
        end
        
    end

    for Field = fieldnames(GreenSignal)'
        sOneSession.GreenSignal{nROI}.(Field{1}) = GreenSignal.(Field{1});
    end
    for Field = fieldnames(RedSignal)'
        sOneSession.RedSignal{nROI}.(Field{1}) = RedSignal.(Field{1});
    end
    
    
    %Remove incomplete acquisitions
    MaxIndex = min([sOneSession.NumberOfTifs size(sOneSession.LOGfile,1)...
        size(sOneSession.GreenSignal{nROI}.DFFinROI,2)]);
    for Stim = 1:MaxIndex
        FrameStartStim = round((sOneSession.LOGfile{Stim,4}+sOneSession.LOGfile{Stim,5})/1000*fps);%converst miliseconds to frame number
        if size(sOneSession.GreenSignal{nROI}.DFFinROI{Stim},2) < FrameStartStim
            NumberOfTifs = Stim - 1;
            sOneSession.NumberOfTifs = NumberOfTifs;
            break
        end
    end
       
end%end of loop over ROIs

save(FileName,'sOneSession')
cd(CurrDir)
end