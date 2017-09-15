
%Parameters
TopFolder = 'Z:\Dudi\Imaging\2Photon\Diego_setup\';
Folders = {[TopFolder, 'DSX_2P_Playback'],[TopFolder, 'DSX_2P_PlaybackContext1'],...
    [TopFolder, 'DSX_2P_Intensity'],[TopFolder, 'DSX_SingleGroup']};
SaveTo = 'Z:\Dudi\Imaging\2Photon\Diego_setup\Alldata_Playback';


%Folders = {[TopFolder, 'DSX_fraser']};
%SaveTo = 'Z:\Dudi\Imaging\2Photon\Diego_setup\DSX_fraser\Alldata_Playback_fraser';

mAllData = cell2table(cell(1,16),'VariableNames',...
    {'StimName', 'Folder', 'Gender', 'StimNumber', 'FramesPerSecond', 'SamplesPerSeconds', 'FrameStartStim', 'ROIname','ROISide',...
    'GreenSignal_FinROI','GreenSignal_DFFinROI','RedSignal','GreenSignal_MaxDFF','GreenSignal_SumDFF','MaxDFFAllStim','MaxSumDFFAllStim'});

nLine = 1;
nFly = 1;
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
    nSessions = find(Table.Date>0 & Table.Session>0,1,'Last');
    
    for nSession = 1:nSessions
        Use = Table.Use(nSession);
        if isnan(Use) || ~Use, continue,end
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
                
                mAllData.StimName{nLine,1} =  sOneSession.LOGfile{nStim,1}{1};
                mAllData.Intensity{nLine,1} =  sOneSession.LOGfile.intensity{nStim,1};
                mAllData.Folder{nLine,1} = sOneSession.Folder;
                mAllData.Gender{nLine,1} = nGender;
                mAllData.Housed{nLine,1} = nHoused;
                mAllData.StimNumber{nLine,1} = nStim;
                mAllData.FramesPerSecond{nLine,1} = FramesPerSecond;
                mAllData.SamplesPerSeconds{nLine,1} = SamplesPerSeconds;
                mAllData.FrameStartStim{nLine,1} = FrameStartStim;
                mAllData.ROIname{nLine,1} = ROIname;
                mAllData.ROISide{nLine,1} = sOneSession.ROISide{1};
                mAllData.GreenSignal_FinROI{nLine} = sOneSession.GreenSignal{ROItoUSE}.FinROI{nStim};
                mAllData.GreenSignal_DFFinROI{nLine} = sOneSession.GreenSignal{ROItoUSE}.DFFinROI{nStim};
                mAllData.RedSignal{nLine} = sOneSession.RedSignal{ROItoUSE}.FinROI{nStim};
                mAllData.GreenSignal_MaxDFF{nLine,1} = sOneSession.GreenSignal{ROItoUSE}.MaxDFF{nStim};
                mAllData.GreenSignal_SumDFF{nLine,1} =...
                    sum(sOneSession.GreenSignal{ROItoUSE}.DFFinROI{nStim}(FrameStartStim:end));
                mAllData.MaxDFFAllStim{nLine,1} = MaxDFF;
                mAllData.MaxSumDFFAllStim{nLine,1} = MaxSumDFF;
                mAllData.Stimulus{nLine,1} = sOneSession.stimAll{sOneSession.stimOrder(nStim)}(:,1);
                %add fly serial number
                if ~(nLine == 1) && ~strcmp(mAllData.Folder{nLine},mAllData.Folder{nLine-1})
                    nFly = nFly + 1;
                end
                mAllData.FlyNumber(nLine) = nFly;
                
                nLine = nLine + 1;
            end
            cd(MasterFolder)
        end
    end
    
end


cd(MasterFolder)
save(SaveTo,'mAllData','-v7.3')

cd(CurrDir)
