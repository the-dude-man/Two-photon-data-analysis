
%Parameters
TopFolder = 'Z:\Dudi\Imaging\2Photon\Dudi_setup\';
Folders = {[TopFolder, 'DSX_VR2P_Auditory']};
SaveTo = fullfile(Folders{1},'mAllData_VR_New.mat');
mAllData = cell2table(cell(1,16),'VariableNames',...
    {'StimName', 'Folder', 'Gender', 'StimNumber', 'FramesPerSecond', 'SamplesPerSeconds', 'FrameStartStim', 'ROIname','ROISide',...
    'GreenSignal_FinROI','GreenSignal_DFFinROI','RedSignal','GreenSignal_MaxDFF','GreenSignal_SumDFF','MaxDFFAllStim','MaxSumDFFAllStim'});

nLine = 1;

for nFolder = 1:size(Folders,2)
    MasterFolder = Folders{nFolder};
    CurrDir = cd(MasterFolder);
    
    
    XLSfile = dir('DSX*.xlsx*');
    if isempty(XLSfile) || size(XLSfile,1)>1
        disp('Need exactly 1 excell file in the master folder. Returning.')
        cd(CurrDir), return
    end
    
    XLSfile = fullfile(MasterFolder,XLSfile(1).name);
    Table = readtable(XLSfile);
    vSessions = find(Table.USE==1);%number of session in the table to go over
    
    for nSession = vSessions'
        Use = Table.USE(nSession);
        Date = Table.Date(nSession);
        Session = Table.Session(nSession);
        Folder = fullfile(MasterFolder,num2str(Date),[num2str(Date),'_',num2str(Session)]);
        cd(Folder)
        File_OneSession = dir('*OneSession*'); File_OneSession = File_OneSession(1).name;
        if ~exist(File_OneSession,'file')
            disp(['No structure sOneSession for folder ',Folder,' . Skipping.'])
            cd(MasterFolder), continue
        end
        
        nGender = Table.Gender{nSession};
        
        if any(strcmp(Table.Properties.VariableNames,'Housed')) && ~isempty(Table.Housed{nSession})
            nHoused = Table.Housed{nSession};
        else%default
            nHoused = 'S';
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
        
        disp(['Extracting data from session ',Folder])
        
        %Speeds from FicTrac
        x = sOneSession.FicTracOUT(:,1);
        y = sOneSession.FicTracOUT(:,1:4);
        qx = 1:sOneSession.FicTracOUT(end,1);
        SPEEDS_FromFicTrac = interp1(x,y,qx);
        
        
        %Find number of stimuli types and how many trials to take
        AllStim = size(sOneSession.stimAll,2);
        sOneSession.LastStimToUse = min(size(sOneSession.GreenSignal{1}.DFFinROI,2), Use*AllStim);
        
        %Frames per second
        SamplesPerSeconds = sOneSession.LOGfile{2,2};
        FramesPerSecond = SamplesPerSeconds/median(diff(sOneSession.SamplesStart_ImFrames(:,1)));
        for ROItoUSE = 1:size(sOneSession.GreenSignal,2)
            
            %Find max DFF for normalization
            MaxDFF = 0;
            for nStim = 1:sOneSession.LastStimToUse
                if  MaxDFF < sOneSession.GreenSignal{ROItoUSE}.MaxDFF{nStim}, MaxDFF = sOneSession.GreenSignal{ROItoUSE}.MaxDFF{nStim};end
            end
            
            %find MaxSum_DFF
            MaxSumDFF = 0;
            
            for nStim = 1:sOneSession.LastStimToUse
                StartStim = floor(sOneSession.LOGfile{nStim,4}/1000*FramesPerSecond);
                if  MaxSumDFF < sum(sOneSession.GreenSignal{ROItoUSE}.DFFinROI{nStim}(StartStim:end))
                    MaxSumDFF = sum(sOneSession.GreenSignal{ROItoUSE}.DFFinROI{nStim}(StartStim:end));
                end
            end
            
            for nStim = 1:sOneSession.LastStimToUse
                FrameStartStim = floor(sOneSession.LOGfile{nStim,4}/1000*FramesPerSecond);
                ROIname = sOneSession.ROIname{1};
                if strcmp(ROIname,'LPC'), ROIname = 'Ring';end
                
                mAllData.Folder{nLine,1} = sOneSession.Folder;
                mAllData.StimName{nLine,1} =  sOneSession.LOGfile{nStim,1}{1};
                mAllData.Intensity{nLine,1} =  sOneSession.LOGfile.intensity{nStim,1};
                mAllData.Gender{nLine,1} = nGender;
                mAllData.Housed{nLine,1} = nHoused;
                mAllData.StimNumber{nLine,1} = nStim;
                mAllData.FramesPerSecond{nLine,1} = FramesPerSecond;
                mAllData.SamplesPerSeconds{nLine,1} = SamplesPerSeconds;
                mAllData.FrameStartStim{nLine,1} = FrameStartStim;
                mAllData.ROIname{nLine,1} = ROIname;
                mAllData.ROISide{nLine,1} = sOneSession.ROISide{1};
                mAllData.Stim{nLine,1} = sOneSession.stimAll{sOneSession.stimOrder(nStim)}(:,1);
                mAllData.GreenSignal_FinROI{nLine} = sOneSession.GreenSignal{ROItoUSE}.FinROI{nStim};
                mAllData.GreenSignal_DFFinROI{nLine} = sOneSession.GreenSignal{ROItoUSE}.DFFinROI{nStim};
                mAllData.RedSignal{nLine} = sOneSession.RedSignal{ROItoUSE}.FinROI{nStim};
                mAllData.GreenSignal_MaxDFF{nLine,1} = sOneSession.GreenSignal{ROItoUSE}.MaxDFF{nStim};
                mAllData.GreenSignal_SumDFF{nLine,1} =...
                    sum(sOneSession.GreenSignal{ROItoUSE}.DFFinROI{nStim}(FrameStartStim:end));
                mAllData.MaxDFFAllStim{nLine,1} = MaxDFF;
                mAllData.MaxSumDFFAllStim{nLine,1} = MaxSumDFF;
                
                %% Add stim ON/OFF times
                
                STIMON_sample = find(sOneSession.stimAll{nStim}(:,1)>0,1);
                STIMOFF_sample = find(sOneSession.stimAll{nStim}(STIMON_sample:end,1)>0,1,'Last')+STIMON_sample;
                
                %Find the ImFrame number when StimOn
                SamplesStart_ImFrames_OneSession = sOneSession.SamplesStart_ImFrames(sOneSession.SamplesStart_ImFrames(:,2)==nStim,:);
                %stim ON
                SampleFromStimON = abs((SamplesStart_ImFrames_OneSession(:,1) - SamplesStart_ImFrames_OneSession(1,1)) - STIMON_sample);
                STIMON_ImFrame = find(SampleFromStimON == min(SampleFromStimON),1);
                %stim OFF
                SampleFromStimOFF = abs((SamplesStart_ImFrames_OneSession(:,1) - SamplesStart_ImFrames_OneSession(1,1)) - STIMOFF_sample);
                STIMOFF_ImFrame = find(SampleFromStimOFF == min(SampleFromStimOFF),1);
                
                %Find the frames in the fictrac output [OneSession.FicTracOUT(:,1)] that correspont to STIMON / STIMOFF
                %fictrac frame at Start session
                SampleAtStartTrial = sOneSession.StartStim(nStim);
                temp = abs(SampleAtStartTrial - sOneSession.Samples_AVIFrames(:,2));
                StartTrial_FicTracFrame = sOneSession.Samples_AVIFrames(find(temp == min(temp),1),1);
                %fictrac frame at End Session
                SampleAtEndTrial = sOneSession.StartStim(nStim) + size(sOneSession.stimAll{sOneSession.stimOrder(nStim)},1);
                temp = abs(SampleAtEndTrial - sOneSession.Samples_AVIFrames(:,2));
                EndTrial_FicTracFrame = sOneSession.Samples_AVIFrames(find(temp == min(temp),1),1);
                
                %Stim ON
                SampleAtStartStim = sOneSession.StartStim(nStim)+STIMON_sample;
                temp = abs(SampleAtStartStim - sOneSession.Samples_AVIFrames(:,2));
                STIMON_FicTracFrame = sOneSession.Samples_AVIFrames(find(temp == min(temp),1),1);
                %Stim OFF
                SampleAtEndStim = sOneSession.StartStim(nStim)+STIMOFF_sample;
                temp = abs(SampleAtEndStim - sOneSession.Samples_AVIFrames(:,2));
                STIMOFF_FicTracFrame = sOneSession.Samples_AVIFrames(find(temp == min(temp),1),1);
                
                
                mAllData.STIMON_sample{nLine,1} = STIMON_sample;
                mAllData.STIMOFF_sample{nLine,1} = STIMOFF_sample;
                
                mAllData.STIMON_ImFrame{nLine,1} = STIMON_ImFrame;
                mAllData.STIMOFF_ImFrame{nLine,1} = STIMOFF_ImFrame;
                
                mAllData.StartTrial_FicTracFrame{nLine,1} = StartTrial_FicTracFrame;
                mAllData.EndTrial_FicTracFrame{nLine,1} = EndTrial_FicTracFrame;
                mAllData.STIMON_FicTracFrame{nLine,1} = STIMON_FicTracFrame;
                mAllData.STIMOFF_FicTracFrame{nLine,1} = STIMOFF_FicTracFrame;
                START = find(sOneSession.FicTracOUT(:,1)>=StartTrial_FicTracFrame,1);
                END = find(sOneSession.FicTracOUT(:,1)<=EndTrial_FicTracFrame,1,'Last');
                mAllData.FicTracSpeed{nLine,1} = SPEEDS_FromFicTrac(START:END,:);
                
                %%
                
                
                nLine = nLine + 1;
            end
            cd(MasterFolder)
        end
    end
    
    cd(MasterFolder)
    %if ~exist('./res','dir'), mkdir('res'),end
    %cd('res')
    save(SaveTo,'mAllData')
    
    cd(CurrDir)
    
end









