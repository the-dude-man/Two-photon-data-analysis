Mas
function sOneSession = Im2P_VisualizeSession(Folder)
%Dudi Deutsch, Princeton, Nov 2016

%If the Folder path is taken from the cluster, modify it to the local path
LocalDrive_Bucket = 'Z:';
User = 'Dudi';
if ~isempty(strfind(Folder,'/'))%name from cluster (therefore unix)
    Slash = strfind(Folder,'/'); Folder(Slash) = filesep();% change '/' to '\'
    Folder(1:strfind(Folder,User)-2) = []; Folder = [LocalDrive_Bucket, Folder ];    
end



%Load sOneSession if exist
CurrDir = cd(Folder);
S = pwd;
FILESEP = strfind(S,filesep()); FILESEP = FILESEP(end);
FileName = ['OneSession','_',S(FILESEP+1:end),'.mat'];

if exist(FileName,'file')
    load(FileName)
else
    disp([FileName,' is missing. Returning.'])
    sOneSession = -1;
    return
end

NumberOfStim = sOneSession.NumberOfTifs;
SamplesPerSeconds = sOneSession.LOGfile{2,2};
fps = SamplesPerSeconds/median(diff(sOneSession.SamplesStart_ImFrames(:,1)));

%%Calculate DF/F in ROI
MaxDFF = 0;
DFF_Green = cell(1,NumberOfStim);
DFF_Red = cell(1,NumberOfStim);
MaxIndex = min(size(sOneSession.GreenSignal{1}.FinROI,2),size(sOneSession.LOGfile,1));
for Stim = 1:MaxIndex
    FrameStartStim = round(sOneSession.LOGfile{Stim,4}/1000*fps);%converst miliseconds to frame number  
    Green = sOneSession.GreenSignal{1}.FinROI{Stim};
    DFF_Green{Stim} = (Green - mean(Green(1:FrameStartStim-1)))./ mean(Green(1:FrameStartStim-1));
    Red = sOneSession.RedSignal{1}.FinROI{Stim};
    DFF_Red{Stim} = (Red - mean(Red(1:FrameStartStim-1)))./ mean(Red(1:FrameStartStim-1));
    MaxDFF = max(MaxDFF,max(DFF_Green{Stim}));
end

mVisDFF = zeros(NumberOfStim,length(DFF_Red{Stim}));
fig = figure(1); subplot(121), hold off
fig.Color = [1 1 1];
for Stim = 1:MaxIndex
    VisDFF = DFF_Green{Stim};
    VisDFF = VisDFF-min(VisDFF);
    VisDFF(isnan(VisDFF)) = 0;
    mVisDFF(Stim,1:length(VisDFF)) = VisDFF*255;   
end

image(mVisDFF), colormap jet
%%

for Stim = 1:MaxIndex
    nStimNumber = sOneSession.stimOrder(Stim);
    vStim = sOneSession.stimAll{nStimNumber}(:,1);
    sStim = sOneSession.LOGfile{Stim,1}{1};
    FrameStartStim = round(sOneSession.LOGfile{Stim,4}/1000*fps);%converst miliseconds to frame number
%     if Stim == 1
%         FirstSample = 1;
%     else
%         FirstSample = sOneSession.SamplesStart_ImFrames(find(sOneSession.SamplesStart_ImFrames(:,3)==Stim-1,1,'Last'),1)+1;
%     end
    
    %LastSample = sOneSession.SamplesStart_ImFrames(find(sOneSession.SamplesStart_ImFrames(:,3)==Stim,1,'Last'),1);
    NumberOfSamples = round(length(DFF_Green{Stim})*SamplesPerSeconds/fps);
    
    disp(['Stim ',num2str(Stim),' out of ',num2str(NumberOfStim)])
    figure(1)
    subplot(222), hold off
    plot(DFF_Green{Stim},'g'),hold on
    plot(DFF_Red{Stim},'r')
    plot([FrameStartStim FrameStartStim],[min([DFF_Green{Stim} DFF_Red{Stim}]) MaxDFF],':k','LineWidth',2)
    TITLE = sprintf('%s%s%s',Folder,'_',num2str(Stim));
    TITLE(strfind(TITLE,'_')) = '-';
    xlabel('Frame'), ylabel('DF/F'),legend('GCaMP6m','tdTomato'),title(TITLE)
    xlim([0 length(DFF_Green{Stim})])
    ylim([min([DFF_Green{Stim} DFF_Red{Stim}]) MaxDFF])
    ax = gca; ax.FontSize = 12; box off
    
    subplot(224),hold off
    plot(vStim,'k')
    xlim([0 NumberOfSamples])
    TITLE = sStim; TITLE(strfind(sStim,'_')) = '-';
    xlabel('Sample'),ylabel('Amplitude'),title(TITLE)
    ax = gca; ax.FontSize = 12; box off

    pause
end

cd(CurrDir)
end
