
%user parameters
PulseStimName = 'pulseTrain_16PDUR_20PPAU_112PNUM_250PCAR';
SineStimName = 'SIN_200_0_4000_100';

Excelfile = 'Z:\Dudi\Imaging\2Photon\Diego_setup\DSX_2P_Playback\DSX_2P_Playback.xlsx';
T = readtable(Excelfile);
SamplesPerSeconds = sOneSession.LOGfile{2,2};
fps = SamplesPerSeconds/median(diff(sOneSession.SamplesStart_ImFrames(:,1)));


%% sessions
femaleSessions = {'20161208_202','20161220_302','20161220_403','20161221_105','20170110_204','20170110_407'};
maleSessions = {'20161220_104','20161215_105'};

femaleDFF = [];
maleDFF = [];
for Gender = 1:2
    if Gender == 1, Sessions = femaleSessions; elseif Gender == 2, Sessions = maleSessions; end
    for nSession = 1:size(Sessions,2)
        Folder = ['Z:\Dudi\Imaging\2Photon\Diego_setup\DSX_2P_Playback\',Sessions{nSession}(1:end-4),'\',Sessions{nSession}];
        
        S = strfind(Folder,'\');
        E = strfind(Folder,'_');
        Date = Folder(S(end)+1:E(end)-1);
        Session = Folder(E(end)+1:end);
        nLine = find(T.Date == str2num(Date) & T.Session == str2num(Session));
        USE = T.Use(nLine);
        
        CurrDir = cd(Folder);
        
        vDatfile = dir('*vDat.mat*'); vDatfile = vDatfile(1).name;
        load(vDatfile)
        OneSessionfile = dir('OneSession*'); OneSessionfile = OneSessionfile(1).name;
        disp(Folder)
        disp('loading sOneSession')
        load(OneSessionfile)
        
        SessionsToUse = min(size(sOneSession.stimAll,2) * USE,size(sOneSession.GreenSignal{1}.MaxDFF,2));
        
        %find indexes of pulse (36IPI) and sine (200Hz)
        vPulseIndexes = [];
        vSineIndexes = [];
        MaxDFF = 0;
        
        for nStim = 1:SessionsToUse
            if ~isempty(strfind(rDat.log.stimFileName{nStim},PulseStimName))
                vPulseIndexes = [vPulseIndexes nStim];
            end
        end
        for nStim = 1:SessionsToUse
            if ~isempty(strfind(rDat.log.stimFileName{nStim},SineStimName))
                vSineIndexes = [vSineIndexes nStim];
            end
        end
        
        NumberOfCells = size(sOneSession.GreenSignal,2);
        
        vMaxDFF = zeros(1,NumberOfCells);
        vmeanPulseDFF = zeros(1,NumberOfCells);
        vmeanSineDFF = zeros(1,NumberOfCells);
        for nCell = 1:NumberOfCells
            for nStim = 1:SessionsToUse
                vMaxDFF(nCell) = max(vMaxDFF(nCell),sOneSession.GreenSignal{nCell}.MaxDFF{nStim});
            end
            
            vPulseMaxDFF = zeros(1,length(vPulseIndexes));
            for nPulseStim = 1:length(vPulseIndexes)
                nStim = vPulseIndexes(nPulseStim);
                if Gender == 1
                    femaleDFF = [femaleDFF;sOneSession.GreenSignal{nCell}.DFFinROI{nStim}(1:160)];
                elseif Gender == 2
                    maleDFF = [maleDFF;sOneSession.GreenSignal{nCell}.DFFinROI{nStim}(1:160)];
                end
            end
            
        end
        
    end
end



XX = [1:160]/fps;
fig = figure(1); subplot(111), hold off
plot(XX,mean(femaleDFF),'r','LineWidth',2), hold on
plot(XX,mean(maleDFF),'b','LineWidth',2)
My_errorbar(XX,mean(femaleDFF),std(femaleDFF)/sqrt(size(femaleDFF,1)),1)
My_errorbar(XX,mean(maleDFF),std(maleDFF)/sqrt(size(maleDFF,1)),2)
plot(XX,mean(femaleDFF),'k','LineWidth',2)
plot(XX,mean(maleDFF),'k','LineWidth',2)
lg = legend('Female','Male','location','NW'); box off, fig.Color = [1 1 1]; lg.EdgeColor = [1 1 1];
xlabel('Time [seconds]'), ylabel('{\delta}F/F'), title('Mean response to 4 second pulse train with IPI = 36ms')
ax = gca; ax.FontSize = 24; ylim([-0.2 0.7])
plot([5 9],[-0.1 -0.1],'k','LineWidth',6)


