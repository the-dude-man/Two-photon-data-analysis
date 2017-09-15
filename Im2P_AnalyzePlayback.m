%function sOneSession = Im2P_AnalyzePlayback(MasterFolder)
%Dudi Deutsch, Princeton, Nov 2016


CurrDir = cd(MasterFolder);
%For example:
%windows: MasterFolder = 'Z:\Dudi\Imaging\2Photon\Diego_setup\DSX_2P_Playback';
%Mac: MasterFolder = '/Volumes/murthy/Dudi/Imaging/2Photon/Diego_setup/DSX_Playback';


%Parameters
ROIforAnalysis = 'Ring';
SaveTo = ['AllPlayback_res_',ROIforAnalysis];
nFlyNumber = 0;


%Create a tables for the different groups of stimuli
%Group 1 - PauseDur
Pulse_PauseDur = cell2table(cell(1,8),'VariableNames',...
    {'FlyNumber', 'Folder', 'Gender', 'stimparam', 'Norm_MaxDFF','sum_DFF','NormDFF','StartEndFrame'});
%Group 2 - sine freq
SineFreq1 = cell2table(cell(1,8),'VariableNames',...
    {'FlyNumber', 'Folder', 'Gender', 'stimparam', 'Norm_MaxDFF','sum_DFF','NormDFF','StartEndFrame'});
%Group 3 - Intensity
Intensity = cell2table(cell(1,8),'VariableNames',...
    {'FlyNumber', 'Folder', 'Gender', 'stimparam', 'Norm_MaxDFF','sum_DFF','NormDFF','StartEndFrame'});

%Group 4 - Carrier
PulseCarrier = cell2table(cell(1,8),'VariableNames',...
    {'FlyNumber', 'Folder', 'Gender', 'stimparam', 'Norm_MaxDFF','sum_DFF','NormDFF','StartEndFrame'});

%Group 5 - IPI (pulse dur = 16ms)
IPI = cell2table(cell(1,8),'VariableNames',...
    {'FlyNumber', 'Folder', 'Gender', 'stimparam', 'Norm_MaxDFF','sum_DFF','NormDFF','StartEndFrame'});


XLSfile = dir('DSX*.xlsx*');
if isempty(XLSfile) || size(XLSfile,1)>1
    disp('Need exactly 1 excell file in the master folder. Returning.')
    cd(CurrDir), return
end

XLSfile = fullfile(MasterFolder,XLSfile(1).name);
Table = readtable(XLSfile);
nSessions = find(Table.Date>0 & Table.Session>0,1,'Last');

for nSession = 1:nSessions
    Use = Table.Use(nSession);
    if ~Use, continue,end
    Date = Table.Date(nSession);
    Session = Table.Session(nSession);
    Folder = fullfile(MasterFolder,num2str(Date),[num2str(Date),'_',num2str(Session)]);
    cd(Folder)
    File_OneSession = dir('*OneSession*'); File_OneSession = File_OneSession(1).name;
    if ~exist(File_OneSession,'file')
        disp(['No structure sOneSession for folder ',Folder,' . Skipping.'])
        cd(MasterFolder), continue
    end
    
    load(File_OneSession)
    
    %Check that all the relevant fields exist and not empty
    IsAllFields(1) = isfield(sOneSession,'stimAll') && ~isempty(sOneSession.stimAll);
    IsAllFields(2) = isfield(sOneSession,'stimOrder') && ~isempty(sOneSession.stimOrder);
    IsAllFields(3) = isfield(sOneSession,'StimParams') && ~isempty(sOneSession.StimParams);
    IsAllFields(4) = isfield(sOneSession,'GreenSignal') && ~isempty(sOneSession.GreenSignal);
    
    if ~all(IsAllFields)
        disp(['Missing fields in sOneSession in folder ',Folder,' . Skipping.'])
        cd(MasterFolder), continue
    end
    
    %Find the relevant ROI if exist
    ROItoUSE = 0;
    for nROI_Index = 1:size(sOneSession.ROIname,2)
        if strfind(sOneSession.ROIname{nROI_Index},ROIforAnalysis)
            ROItoUSE = nROI_Index;
            break
        end
    end
    
    if ROItoUSE == 0 %The ROIforAnalysis is analyzed this session
        disp(['Requested ROI not found for session ',Folder])
        continue
    end
    
    
    disp(['Finding stimuli and maxDFF for session ',Folder])
    
    %Find number of stimuli types and how many trials to take
    AllStim = size(sOneSession.stimAll,2);
    sOneSession.LastStimToUse = min(size(sOneSession.GreenSignal{ROItoUSE}.DFFinROI,2), Use*AllStim);

    %Frames per second
    SamplesPerSeconds = sOneSession.LOGfile{2,2};
    fps = SamplesPerSeconds/median(diff(sOneSession.SamplesStart_ImFrames(:,1)));
    
    nFlyNumber = nFlyNumber + 1;
    
    %Find max DFF for normalization
    MaxDFF = 0;
    for nStim = 1:sOneSession.LastStimToUse
        if  MaxDFF < sOneSession.GreenSignal{ROItoUSE}.MaxDFF{nStim}, MaxDFF = sOneSession.GreenSignal{ROItoUSE}.MaxDFF{nStim};end
    end

    %find MaxSum_DFF
    MaxSumDFF = 0;
    
    for nStim = 1:sOneSession.LastStimToUse
        StartStim = floor(sOneSession.LOGfile{nStim,4}/1000*fps);
        if  MaxSumDFF < sum(sOneSession.GreenSignal{ROItoUSE}.DFFinROI{nStim}(StartStim:end))
            MaxSumDFF = sum(sOneSession.GreenSignal{ROItoUSE}.DFFinROI{nStim}(StartStim:end));
        end
    end
    
    %Add info to the tables for the different groups of stimuli
    Im2P_Analysis_Playback_StimGroups
    
    %Group 1 - PauseDur
    nTrials = vStim_Group.PauseDur;
    if isempty(Pulse_PauseDur.FlyNumber{1,1})
        nIndex = 1;
    else
        nIndex = size(Pulse_PauseDur,1) + 1;
    end
    
    
    for nTrial = 1:length(nTrials)
        %Find the frame number at StartStim/EndStim
        StartStim = floor(sOneSession.LOGfile{nTrials(nTrial),4}/1000*fps);
        EndStim = length(sOneSession.GreenSignal{ROItoUSE}.DFFinROI{nTrials(nTrial)}) - ceil(sOneSession.LOGfile{nTrials(nTrial),5}/1000*fps);
        if EndStim < StartStim, disp([pwd,', EndStim cant come before StartStim. Returning.']), cd(CurrDir), return, end
        Pulse_PauseDur.FlyNumber{nIndex,1} = nFlyNumber;
        Pulse_PauseDur.Folder{nIndex,1} = Folder;
        Pulse_PauseDur.Gender{nIndex,1} = Table.Gender{nSession};
        Pulse_PauseDur.stimparam{nIndex,1} =...
            [sOneSession.StimParams{nTrials(nTrial)}.ppau sOneSession.StimParams{nTrials(nTrial)}.pdur];
        Pulse_PauseDur.Norm_MaxDFF{nIndex,1} = sOneSession.GreenSignal{ROItoUSE}.MaxDFF{nTrials(nTrial)}/MaxDFF;
        Pulse_PauseDur.sum_DFF{nIndex,1} =...
            sum(sOneSession.GreenSignal{ROItoUSE}.DFFinROI{nTrials(nTrial)}(StartStim:end))/MaxSumDFF;
        Pulse_PauseDur.NormDFF{nIndex,1} = ...
            sOneSession.GreenSignal{ROItoUSE}.DFFinROI{nTrials(nTrial)}/MaxDFF;
        Pulse_PauseDur.StartEndFrame{nIndex,1} = [StartStim EndStim];
        nIndex = nIndex + 1;
        
    end
    
    %Group 2 - Sine
    nTrials = vStim_Group.Sine;
    if isempty(SineFreq1.FlyNumber{1,1})
        nIndex = 1;
    else
        nIndex = size(SineFreq1,1) + 1;
    end
    
    for nTrial = 1:length(nTrials)
        SineFreq1.FlyNumber{nIndex,1} = nFlyNumber;
        SineFreq1.Folder{nIndex,1} = Folder;
        SineFreq1.Gender{nIndex,1} = Table.Gender{nSession};
        SineFreq1.stimparam{nIndex,1} = sOneSession.StimParams{nTrials(nTrial)}.car;
        SineFreq1.Norm_MaxDFF{nIndex,1} = sOneSession.GreenSignal{ROItoUSE}.MaxDFF{nTrials(nTrial)}/MaxDFF;
        SineFreq1.sum_DFF{nIndex,1} =...
            sum(sOneSession.GreenSignal{ROItoUSE}.DFFinROI{nTrials(nTrial)}(StartStim:end))/MaxSumDFF;
        SineFreq1.NormDFF{nIndex,1} = ...
            sOneSession.GreenSignal{ROItoUSE}.DFFinROI{nTrials(nTrial)}/MaxDFF;
        SineFreq1.StartEndFrame{nIndex,1} = [StartStim EndStim];
        nIndex = nIndex + 1;
    end
    
    %Group 3 - Intensity
    nTrials = vStim_Group.Intensity;
    if isempty(Intensity.FlyNumber{1,1})
        nIndex = 1;
    else
        nIndex = size(Intensity,1) + 1;
    end
    
    for nTrial = 1:length(nTrials)
        Intensity.FlyNumber{nIndex,1} = nFlyNumber;
        Intensity.Folder{nIndex,1} = Folder;
        Intensity.Gender{nIndex,1} = Table.Gender{nSession};
        Intensity.stimparam{nIndex,1} = sOneSession.StimParams{nTrials(nTrial)}.Intensity;
        Intensity.Norm_MaxDFF{nIndex,1} = sOneSession.GreenSignal{ROItoUSE}.MaxDFF{nTrials(nTrial)}/MaxDFF;
        Intensity.sum_DFF{nIndex,1} =...
            sum(sOneSession.GreenSignal{ROItoUSE}.DFFinROI{nTrials(nTrial)}(StartStim:end))/MaxSumDFF;
        Intensity.NormDFF{nIndex,1} = ...
            sOneSession.GreenSignal{ROItoUSE}.DFFinROI{nTrials(nTrial)}/MaxDFF;
        Intensity.StartEndFrame{nIndex,1} = [StartStim EndStim];
        
        nIndex = nIndex + 1;
    end
    
    %Group 4 - Carrier
    nTrials = vStim_Group.Carrier;
    if isempty(PulseCarrier.FlyNumber{1,1})
        nIndex = 1;
    else
        nIndex = size(PulseCarrier,1) + 1;
    end
    
    for nTrial = 1:length(nTrials)
        PulseCarrier.FlyNumber{nIndex,1} = nFlyNumber;
        PulseCarrier.Folder{nIndex,1} = Folder;
        PulseCarrier.Gender{nIndex,1} = Table.Gender{nSession};
        PulseCarrier.stimparam{nIndex,1} = sOneSession.StimParams{nTrials(nTrial)}.pcar;
        PulseCarrier.Norm_MaxDFF{nIndex,1} = sOneSession.GreenSignal{ROItoUSE}.MaxDFF{nTrials(nTrial)}/MaxDFF;
        PulseCarrier.sum_DFF{nIndex,1} =...
            sum(sOneSession.GreenSignal{ROItoUSE}.DFFinROI{nTrials(nTrial)}(StartStim:end))/MaxSumDFF;
        PulseCarrier.NormDFF{nIndex,1} = ...
            sOneSession.GreenSignal{ROItoUSE}.DFFinROI{nTrials(nTrial)}/MaxDFF;
        PulseCarrier.StartEndFrame{nIndex,1} = [StartStim EndStim];
        
        nIndex = nIndex + 1;
    end
    
    %Group 5 - IPI
    nTrials = vStim_Group.IPI;
    if isempty(IPI.FlyNumber{1,1})
        nIndex = 1;
    else
        nIndex = size(IPI,1) + 1;
    end
    
    for nTrial = 1:length(nTrials)
        IPI.FlyNumber{nIndex,1} = nFlyNumber;
        IPI.Folder{nIndex,1} = Folder;
        IPI.Gender{nIndex,1} = Table.Gender{nSession};
        IPI.stimparam{nIndex,1} = sOneSession.StimParams{nTrials(nTrial)}.ppau + sOneSession.StimParams{nTrials(nTrial)}.pdur;
        IPI.Norm_MaxDFF{nIndex,1} = sOneSession.GreenSignal{ROItoUSE}.MaxDFF{nTrials(nTrial)}/MaxDFF;
        IPI.sum_DFF{nIndex,1} =...
            sum(sOneSession.GreenSignal{ROItoUSE}.DFFinROI{nTrials(nTrial)}(StartStim:end))/MaxSumDFF;
        IPI.NormDFF{nIndex,1} = ...
            sOneSession.GreenSignal{ROItoUSE}.DFFinROI{nTrials(nTrial)}/MaxDFF;
        IPI.StartEndFrame{nIndex,1} = [StartStim EndStim];
        
        nIndex = nIndex + 1;
    end
        
    cd(MasterFolder)
    
end

cd(MasterFolder)
if ~exist('./res','dir'), mkdir('res'),end
cd('res')
save(SaveTo,'Pulse_PauseDur','SineFreq1','Intensity','PulseCarrier','IPI','fps')

cd(CurrDir)
%end
