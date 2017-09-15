
%females
Sessions = {'20161208_202','20161220_302','20161220_403','20161221_105','20170110_204','20170110_407'};
%males
%Sessions = {'20161220_104','20161215_105'};

%user parameters
%PulseStimName = 'pulse';
%SineStimName = 'SIN_';
PulseStimName = 'pulseTrain_16PDUR_20PPAU_112PNUM_250PCAR';
SineStimName = 'SIN_200_0_4000_100';

Excelfile = 'Z:\Dudi\Imaging\2Photon\Diego_setup\DSX_2P_Playback\DSX_2P_Playback.xlsx';
T = readtable(Excelfile);

vAll_PulseSineRatio = [];
vAllPulseResponse = [];
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
            vPulseMaxDFF(nPulseStim) = sOneSession.GreenSignal{nCell}.MaxDFF{nStim};
        end
        
        vSineMaxDFF = zeros(1,length(vSineIndexes));
        for nSineStim = 1:length(vSineIndexes)
            nStim = vSineIndexes(nSineStim);
            vSineMaxDFF(nSineStim) = sOneSession.GreenSignal{nCell}.MaxDFF{nStim};
        end
        vmeanPulseDFF(nCell) = mean(vPulseMaxDFF);
        vmeanSineDFF(nCell) = mean(vSineMaxDFF);
        
    end
  vAllPulseResponse = [vAllPulseResponse vmeanPulseDFF];
  vAll_PulseSineRatio = [vAll_PulseSineRatio vmeanPulseDFF./vmeanSineDFF]; 
  
end

figure(2), subplot(111), hold off, boxplot(vAll_PulseSineRatio),ylim([0 max(vAll_PulseSineRatio)+1])
xlabel('Female'), ylabel('Pulse/Sine response')

