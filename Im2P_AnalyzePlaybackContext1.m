%function sOneSession = Im2P_AnalyzePlayback(MasterFolder)
%Dudi Deutsch, Princeton, Nov 2016

CurrDir = cd(MasterFolder);
%For example:
%windows: MasterFolder = 'Z:\Dudi\Imaging\2Photon\Diego_setup\DSX_2P_Playback';
%Mac: MasterFolder = '/Volumes/murthy/Dudi/Imaging/2Photon/Diego_setup/DSX_Playback';


%user Parameters
ROIforAnalysis = 'LPC';

%initialization
Slash = strfind(MasterFolder,'_'); Slash = Slash(end); 
SaveTo = ['All',MasterFolder(Slash+1:end),'_res_',ROIforAnalysis];
nFlyNumber = 0;
%Create a tables for the different groups of stimuli
%Group 1 : number of pulses in a pulse train
Pulse_Num = cell2table(cell(1,8),'VariableNames',...
    {'FlyNumber', 'Folder', 'Gender', 'stimparam', 'Norm_MaxDFF','sum_DFF','NormDFF','StartEndFrame'});
%Group 2 : sine 150hz with different sine length
Sine150_Dur = cell2table(cell(1,8),'VariableNames',...
    {'FlyNumber', 'Folder', 'Gender', 'stimparam', 'Norm_MaxDFF','sum_DFF','NormDFF','StartEndFrame'});
%Group 3 : Sine100, 2sec or 4sec
Sine100_2000_4000 = cell2table(cell(1,8),'VariableNames',...
    {'FlyNumber', 'Folder', 'Gender', 'stimparam', 'Norm_MaxDFF','sum_DFF','NormDFF','StartEndFrame'});

%Group 4 : Sine250, 2 sec or 4 sec
Sine250_2000_4000 = cell2table(cell(1,8),'VariableNames',...
    {'FlyNumber', 'Folder', 'Gender', 'stimparam', 'Norm_MaxDFF','sum_DFF','NormDFF','StartEndFrame'});

%Group 5 : Sine 4 seconds
SineFreq2 = cell2table(cell(1,8),'VariableNames',...
    {'FlyNumber', 'Folder', 'Gender', 'stimparam', 'Norm_MaxDFF','sum_DFF','NormDFF','StartEndFrame'});

%Group 6 : pulse-sine
PulseSine = cell2table(cell(1,8),'VariableNames',...
    {'FlyNumber', 'Folder', 'Gender', 'stimparam', 'Norm_MaxDFF','sum_DFF','NormDFF','StartEndFrame'});

%Group 7 : sine-pulse
SinePulse = cell2table(cell(1,8),'VariableNames',...
    {'FlyNumber', 'Folder', 'Gender', 'stimparam', 'Norm_MaxDFF','sum_DFF','NormDFF','StartEndFrame'});


%Read xls file with the list of relevant sessions for analysis
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
    Im2P_Analysis_PlaybackContext1_StimGroups
    
    
    %% Group 1 - Pulse_Num
    nTrials = vStim_Group.Pulse_Num;
    if isempty(Pulse_Num.FlyNumber{1,1})
        nIndex = 1;
    else
        nIndex = size(Pulse_Num,1) + 1;
    end
    
    for nTrial = 1:length(nTrials)
        %Find the frame number at StartStim/EndStim
        StartStim = floor(sOneSession.LOGfile{nTrials(nTrial),4}/1000*fps);
        EndStim = length(sOneSession.GreenSignal{ROItoUSE}.DFFinROI{nTrials(nTrial)}) - ceil(sOneSession.LOGfile{nTrials(nTrial),5}/1000*fps);
        if EndStim < StartStim, disp([pwd,', EndStim cant come before StartStim. Returning.']), cd(CurrDir), return, end
        
        
        Pulse_Num.FlyNumber{nIndex,1} = nFlyNumber;
        Pulse_Num.Folder{nIndex,1} = Folder;
        Pulse_Num.Gender{nIndex,1} = Table.Gender{nSession};
        Pulse_Num.stimparam{nIndex,1} = sOneSession.StimParams{nTrials(nTrial)}.pnum;
        Pulse_Num.Norm_MaxDFF{nIndex,1} = sOneSession.GreenSignal{ROItoUSE}.MaxDFF{nTrials(nTrial)}/MaxDFF;
        Pulse_Num.sum_DFF{nIndex,1} =...
            sum(sOneSession.GreenSignal{ROItoUSE}.DFFinROI{nTrials(nTrial)}(StartStim:end))/MaxSumDFF;
        Pulse_Num.NormDFF{nIndex,1} = ...
            sOneSession.GreenSignal{ROItoUSE}.DFFinROI{nTrials(nTrial)}/MaxDFF;
        Pulse_Num.StartEndFrame{nIndex,1} = [StartStim EndStim];
        nIndex = nIndex + 1;
    end
    
    %% Group 2 - Sine150_Dur
    nTrials = vStim_Group.Sine150_Dur;
    if isempty(Sine150_Dur.FlyNumber{1,1})
        nIndex = 1;
    else
        nIndex = size(Sine150_Dur,1) + 1;
    end
    
    for nTrial = 1:length(nTrials)
        %Find the frame numbers at StartStim/EndStim
        StartStim = floor(sOneSession.LOGfile{nTrials(nTrial),4}/1000*fps);
        EndStim = length(sOneSession.GreenSignal{ROItoUSE}.DFFinROI{nTrials(nTrial)}) - floor(sOneSession.LOGfile{nTrials(nTrial),5}/1000*fps);
        if EndStim < StartStim, disp([pwd,', EndStim cant come before StartStim. Returning.']), cd(CurrDir), return, end
        
        Sine150_Dur.FlyNumber{nIndex,1} = nFlyNumber;
        Sine150_Dur.Folder{nIndex,1} = Folder;
        Sine150_Dur.Gender{nIndex,1} = Table.Gender{nSession};
        Sine150_Dur.stimparam{nIndex,1} = sOneSession.StimParams{nTrials(nTrial)}.dur;
        Sine150_Dur.Norm_MaxDFF{nIndex,1} = sOneSession.GreenSignal{ROItoUSE}.MaxDFF{nTrials(nTrial)}/MaxDFF;
        Sine150_Dur.sum_DFF{nIndex,1} =...
            sum(sOneSession.GreenSignal{ROItoUSE}.DFFinROI{nTrials(nTrial)}(StartStim:end))/MaxSumDFF;
        Sine150_Dur.NormDFF{nIndex,1} = ...
            sOneSession.GreenSignal{ROItoUSE}.DFFinROI{nTrials(nTrial)}/MaxDFF;
        Sine150_Dur.StartEndFrame{nIndex,1} = [StartStim EndStim];
        nIndex = nIndex + 1;
    end
    
    %% Group 3 - Sine100_2000_4000
    nTrials = vStim_Group.Sine100_2000_4000;
    if isempty(Sine100_2000_4000.FlyNumber{1,1})
        nIndex = 1;
    else
        nIndex = size(Sine100_2000_4000,1) + 1;
    end
    
    for nTrial = 1:length(nTrials)
        %Find the frame numbers at StartStim/EndStim
        StartStim = floor(sOneSession.LOGfile{nTrials(nTrial),4}/1000*fps);
        EndStim = length(sOneSession.GreenSignal{ROItoUSE}.DFFinROI{nTrials(nTrial)}) - ceil(sOneSession.LOGfile{nTrials(nTrial),5}/1000*fps);
        if EndStim < StartStim, disp([pwd,', EndStim cant come before StartStim. Returning.']), cd(CurrDir), return, end
        
        Sine100_2000_4000.FlyNumber{nIndex,1} = nFlyNumber;
        Sine100_2000_4000.Folder{nIndex,1} = Folder;
        Sine100_2000_4000.Gender{nIndex,1} = Table.Gender{nSession};
        Sine100_2000_4000.stimparam{nIndex,1} = sOneSession.StimParams{nTrials(nTrial)}.dur;
        Sine100_2000_4000.Norm_MaxDFF{nIndex,1} = sOneSession.GreenSignal{ROItoUSE}.MaxDFF{nTrials(nTrial)}/MaxDFF;
        Sine100_2000_4000.sum_DFF{nIndex,1} =...
            sum(sOneSession.GreenSignal{ROItoUSE}.DFFinROI{nTrials(nTrial)}(StartStim:end))/MaxSumDFF;
        Sine100_2000_4000.NormDFF{nIndex,1} = ...
            sOneSession.GreenSignal{ROItoUSE}.DFFinROI{nTrials(nTrial)}/MaxDFF;
        Sine100_2000_4000.StartEndFrame{nIndex,1} = [StartStim EndStim];
        nIndex = nIndex + 1;
    end
    
    %% Group 4 - Sine250_2000_4000
    nTrials = vStim_Group.Sine250_2000_4000;
    if isempty(Sine250_2000_4000.FlyNumber{1,1})
        nIndex = 1;
    else
        nIndex = size(Sine250_2000_4000,1) + 1;
    end
    
    for nTrial = 1:length(nTrials)
        %Find the frame numbers at StartStim/EndStim
        StartStim = floor(sOneSession.LOGfile{nTrials(nTrial),4}/1000*fps);
        EndStim = length(sOneSession.GreenSignal{ROItoUSE}.DFFinROI{nTrials(nTrial)}) - ceil(sOneSession.LOGfile{nTrials(nTrial),5}/1000*fps);
        if EndStim < StartStim, disp([pwd,', EndStim cant come before StartStim. Returning.']), cd(CurrDir), return, end
        
        Sine250_2000_4000.FlyNumber{nIndex,1} = nFlyNumber;
        Sine250_2000_4000.Folder{nIndex,1} = Folder;
        Sine250_2000_4000.Gender{nIndex,1} = Table.Gender{nSession};
        Sine250_2000_4000.stimparam{nIndex,1} = sOneSession.StimParams{nTrials(nTrial)}.dur;
        Sine250_2000_4000.Norm_MaxDFF{nIndex,1} = sOneSession.GreenSignal{ROItoUSE}.MaxDFF{nTrials(nTrial)}/MaxDFF;
        Sine250_2000_4000.sum_DFF{nIndex,1} =...
            sum(sOneSession.GreenSignal{ROItoUSE}.DFFinROI{nTrials(nTrial)}(StartStim:end))/MaxSumDFF;
        Sine250_2000_4000.NormDFF{nIndex,1} = ...
            sOneSession.GreenSignal{ROItoUSE}.DFFinROI{nTrials(nTrial)}/MaxDFF;
        Sine250_2000_4000.StartEndFrame{nIndex,1} = [StartStim EndStim];
        nIndex = nIndex + 1;
    end
    
    
    %% Group 5 - SineFreq
    nTrials = vStim_Group.SineFreq;
    if isempty(SineFreq2.FlyNumber{1,1})
        nIndex = 1;
    else
        nIndex = size(SineFreq2,1) + 1;
    end
    
    for nTrial = 1:length(nTrials)
        %Find the frame numbers at StartStim/EndStim
        StartStim = floor(sOneSession.LOGfile{nTrials(nTrial),4}/1000*fps);
        EndStim = length(sOneSession.GreenSignal{ROItoUSE}.DFFinROI{nTrials(nTrial)}) - ceil(sOneSession.LOGfile{nTrials(nTrial),5}/1000*fps);
        if EndStim < StartStim, disp([pwd,', EndStim cant come before StartStim. Returning.']), cd(CurrDir), return, end
        
        SineFreq2.FlyNumber{nIndex,1} = nFlyNumber;
        SineFreq2.Folder{nIndex,1} = Folder;
        SineFreq2.Gender{nIndex,1} = Table.Gender{nSession};
        SineFreq2.stimparam{nIndex,1} = sOneSession.StimParams{nTrials(nTrial)}.car;
        SineFreq2.Norm_MaxDFF{nIndex,1} = sOneSession.GreenSignal{ROItoUSE}.MaxDFF{nTrials(nTrial)}/MaxDFF;
        SineFreq2.sum_DFF{nIndex,1} =...
            sum(sOneSession.GreenSignal{ROItoUSE}.DFFinROI{nTrials(nTrial)}(StartStim:end))/MaxSumDFF;
        SineFreq2.NormDFF{nIndex,1} = ...
            sOneSession.GreenSignal{ROItoUSE}.DFFinROI{nTrials(nTrial)}/MaxDFF;
        SineFreq2.StartEndFrame{nIndex,1} = [StartStim EndStim];
        nIndex = nIndex + 1;
    end
    
    %% Group 6 - PulseSine
    nTrials = [vStim_Group.Pulse56 vStim_Group.Pulse56Sine100 vStim_Group.Pulse56Sine250];
    if isempty(PulseSine.FlyNumber{1,1})
        nIndex = 1;
    else
        nIndex = size(PulseSine,1) + 1;
    end
    
    
    for nTrial = 1:length(nTrials)
        %Find the frame numbers at StartStim/EndStim
        StartStim = floor(sOneSession.LOGfile{nTrials(nTrial),4}/1000*fps);
        EndStim = length(sOneSession.GreenSignal{ROItoUSE}.DFFinROI{nTrials(nTrial)}) - ceil(sOneSession.LOGfile{nTrials(nTrial),5}/1000*fps);
        if EndStim < StartStim, disp([pwd,', EndStim cant come before StartStim. Returning.']), cd(CurrDir), return, end
        
        PulseSine.FlyNumber{nIndex,1} = nFlyNumber;
        PulseSine.Folder{nIndex,1} = Folder;
        PulseSine.Gender{nIndex,1} = Table.Gender{nSession};
        PulseSine.stimparam{nIndex,1} = sOneSession.LOGfile{nTrials(nTrial),1};
        PulseSine.Norm_MaxDFF{nIndex,1} = sOneSession.GreenSignal{ROItoUSE}.MaxDFF{nTrials(nTrial)}/MaxDFF;
        PulseSine.sum_DFF{nIndex,1} =...
            sum(sOneSession.GreenSignal{ROItoUSE}.DFFinROI{nTrials(nTrial)}(StartStim:end))/MaxSumDFF;
        PulseSine.NormDFF{nIndex,1} = ...
            sOneSession.GreenSignal{ROItoUSE}.DFFinROI{nTrials(nTrial)}/MaxDFF;
        PulseSine.StartEndFrame{nIndex,1} = [StartStim EndStim];
        nIndex = nIndex + 1;
    end
    
    
    %% Group 7 - SinePulse
    nTrials = [vStim_Group.Pulse56 vStim_Group.Sine100 vStim_Group.Sine100Pulse56 vStim_Group.Sine250 vStim_Group.Sine250Pulse56];
    if isempty(SinePulse.FlyNumber{1,1})
        nIndex = 1;
    else
        nIndex = size(SinePulse,1) + 1;
    end
    
    
    for nTrial = 1:length(nTrials)
        %Find the frame numbers at StartStim/EndStim
        StartStim = floor(sOneSession.LOGfile{nTrials(nTrial),4}/1000*fps);
        EndStim = length(sOneSession.GreenSignal{ROItoUSE}.DFFinROI{nTrials(nTrial)}) - ceil(sOneSession.LOGfile{nTrials(nTrial),5}/1000*fps);
        if EndStim < StartStim, disp([pwd,', EndStim cant come before StartStim. Returning.']), cd(CurrDir), return, end
        
        SinePulse.FlyNumber{nIndex,1} = nFlyNumber;
        SinePulse.Folder{nIndex,1} = Folder;
        SinePulse.Gender{nIndex,1} = Table.Gender{nSession};
        SinePulse.stimparam{nIndex,1} = sOneSession.LOGfile{nTrials(nTrial),1};
        SinePulse.Norm_MaxDFF{nIndex,1} = sOneSession.GreenSignal{ROItoUSE}.MaxDFF{nTrials(nTrial)}/MaxDFF;
        SinePulse.sum_DFF{nIndex,1} =...
            sum(sOneSession.GreenSignal{ROItoUSE}.DFFinROI{nTrials(nTrial)}(StartStim:end))/MaxSumDFF;
        SinePulse.NormDFF{nIndex,1} = ...
            sOneSession.GreenSignal{ROItoUSE}.DFFinROI{nTrials(nTrial)}/MaxDFF;
        SinePulse.StartEndFrame{nIndex,1} = [StartStim EndStim];
        nIndex = nIndex + 1;
    end
    
    cd(MasterFolder)
    
end

cd(MasterFolder)
if ~exist('./res','dir'), mkdir('res'),end
cd('res')
save(SaveTo,'Pulse_Num','Sine150_Dur','Sine100_2000_4000',...
    'Sine250_2000_4000','SineFreq2','PulseSine','SinePulse','fps')

cd(CurrDir)



