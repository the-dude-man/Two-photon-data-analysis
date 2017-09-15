
function Im2P_FiguresPlayback
%Parameters
if ismac
    datafile1 = '/Volumes/murthy/Dudi/Imaging/2Photon/Diego_setup/DSX_2P_Playback/res/AllPlaybackcontext1_res_Ring';
    datafile2 = '/Volumes/murthy/Dudi/Imaging/2Photon/Diego_setup/DSX_2P_PlaybackContext1/res/AllPlaybackcontext1_res_LPC';
else
    datafile1 = 'Z:\Dudi\Imaging\2Photon\Diego_setup\DSX_2P_Playback\res\AllPlaybackcontext1_res_Ring';
    datafile2 = 'Z:\Dudi\Imaging\2Photon\Diego_setup\DSX_2P_PlaybackContext1\res\AllPlaybackcontext1_res_LPC';
end
bNormalize = 1;
FIG1 = 1;%first figures
nGender = 'F';%Temporary - for the sine-pulse, pulse-sine figures

load(datafile1)
load(datafile2)

%% IPI
figureNumber = FIG1;

TITLES = {'Ca response -  IPI (male)','Ca response -  IPI (female)'};

XLABEL = 'IPI [ms]';
data = IPI;
islogx = 0;
Im2P_PlotTuning(data,TITLES, XLABEL, bNormalize,islogx, figureNumber, fps)

%% Pulse carrier frequency
figureNumber = FIG1+1;

TITLES = {'Ca response -  Pulse carrier frequency (male)','Ca response -  Pulse carrier frequency (female)'};

XLABEL = 'Pulse carrier freq [Hz]';
data = PulseCarrier;
islogx = 0;
Im2P_PlotTuning(data,TITLES, XLABEL, bNormalize,islogx, figureNumber, fps)

%% Pulse_Num fig
figureNumber = FIG1+2;
TITLES = {'Ca response -  pulse number (male)','Ca response - pulse number (female)'};
XLABEL = 'Number of pulses';
data = Pulse_Num;
islogx = 1;
Im2P_PlotTuning(data,TITLES, XLABEL, bNormalize,islogx, figureNumber, fps)

%% Intensity
figureNumber = FIG1+3;
TITLES = {'Ca response -  Intensity (male)','Ca response -  Intensity (female)'};
XLABEL = 'Pulse Intensity [mm/sec]';
data = Intensity;
islogx = 1;
Im2P_PlotTuning(data,TITLES, XLABEL, bNormalize,islogx, figureNumber, fps)

%% Sine dur fig
figureNumber = FIG1+4;
TITLES = {'Ca response -  sine duration (male)','Ca response - sine duration (female)'};
XLABEL = 'Sine duration [ms]';
data = Sine150_Dur;
islogx = 1;
Im2P_PlotTuning(data,TITLES, XLABEL, bNormalize,islogx, figureNumber, fps)


%% Sine freq tuning - 1
figureNumber = FIG1+5;
TITLES = {'Ca response -  sine frequency (male)','Ca response -  sine frequency (female)'};
XLABEL = 'Sine frequency [Hz]';
data = SineFreq1;
islogx = 0;
Im2P_PlotTuning(data,TITLES, XLABEL, bNormalize,islogx, figureNumber, fps)

%% Sine freq tuning - 2
figureNumber = FIG1+6;
TITLES = {'Ca response -  sine frequency (male)','Ca response -  sine frequency (female)'};
XLABEL = 'Sine frequency [Hz]';
data = SineFreq2;
islogx = 0;
Im2P_PlotTuning(data,TITLES, XLABEL, bNormalize,islogx, figureNumber, fps)

%Pulse duration and pause
figureNumber = FIG1+7;
figure(figureNumber)
TITLES = {'Ca response - Pulse parameters (male)','Ca response -  Pulse parameters (female)'};
XLABEL = 'Pulse duration [ms]';
YLABEL = 'Pulse pause [ms]';
data = Pulse_PauseDur;
mdata = cell2mat(data.stimparam);
vPauses = unique(mdata(:,1));
vDurations = unique(mdata(:,2));

for GENDER = 1:2%1 - male, 2 - female
    %     sDurPause = struct('Dur',[],'Pause',[],'NormDFF',[]);
    %     for nIndex1 = 1:length(vDurations)
    %         for nIndex2 = 1:length(vPauses)
    %             sDurPause.NormDFF{nIndex1,nIndex2} = [];
    %         end
    %     end
    
    if GENDER == 1, nGender = 'M'; else, nGender = 'F'; end
    sDurPause = struct('Dur',[],'Pause',[],'Norm_MaxDFF',[],'sum_DFF',[]);
    
    for nIndex1 = 1:length(vDurations)
        for nIndex2 = 1:length(vPauses)
            sDurPause(nIndex1,nIndex2).Norm_MaxDFF = [];
            sDurPause(nIndex1,nIndex2).sum_DFF = [];
        end
    end
    
    
    for nLine = 1:size(data,1)
        if ~(strcmp(data.Gender{nLine},nGender)), continue,end
        nPause = data.stimparam{nLine}(1);
        nDuration = data.stimparam{nLine}(2);
        nIndex1 = find(vDurations == nDuration);
        nIndex2 = find(vPauses == nPause);
        
        sDurPause(nIndex1,nIndex2).Dur = nDuration;
        sDurPause(nIndex1,nIndex2).Pause = nPause;
        sDurPause(nIndex1,nIndex2).Norm_MaxDFF = [sDurPause(nIndex1,nIndex2).Norm_MaxDFF data.Norm_MaxDFF{nLine}];
        sDurPause(nIndex1,nIndex2).sum_DFF = [sDurPause(nIndex1,nIndex2).sum_DFF data.sum_DFF{nLine}];
        
    end
    X = zeros(length(vDurations),length(vPauses));
    Y = zeros(length(vDurations),length(vPauses));
    Z1 = zeros(length(vDurations),length(vPauses));
    Z2 = zeros(length(vDurations),length(vPauses));
    
    for nIndex1 = 1:length(vDurations)
        for nIndex2 = 1:length(vPauses)
            X(nIndex1,nIndex2) = vDurations(nIndex1);
            Y(nIndex1,nIndex2) = vPauses(nIndex2);
            Z1(nIndex1,nIndex2) = mean(sDurPause(nIndex1,nIndex2).Norm_MaxDFF);
            Z2(nIndex1,nIndex2) = mean(sDurPause(nIndex1,nIndex2).sum_DFF);
        end
    end
    
    para = zeros(length(vDurations),2);
    resp1 = zeros(length(vDurations),1); resp2 = zeros(length(vDurations),1);
    nIndex = 1;
    for nIndex1 = 1:length(vDurations)
        for nIndex2 = 1:length(vPauses)
            if isnan(Z1(nIndex1,nIndex2)),continue,end
            para(nIndex,1:2) = [X(nIndex1,nIndex2) Y(nIndex1,nIndex2)];
            resp1(nIndex,1) = Z1(nIndex1,nIndex2);
            resp2(nIndex,1) = Z2(nIndex1,nIndex2);
            nIndex = nIndex + 1;
        end
    end
    
    subplot(2,2,2*GENDER-1)
    [~, ~, ~, ~] = Im2P_plotPPF(para, resp1);
    xlabel(XLABEL), ylabel(YLABEL)
    title([TITLES(GENDER),' MaxDFF'])
    axis tight; axis equal
    ax = gca;
    ax.XTick = vDurations; ax.YTick = vPauses;
    subplot(2,2,2*GENDER)
    [~, ~, ~, ~] = Im2P_plotPPF(para, resp2);
    xlabel(XLABEL), ylabel(YLABEL)
    title([TITLES(GENDER),' sum DFF'])
    axis tight; axis equal
    ax = gca;
    ax.XTick = vDurations; ax.YTick = vPauses;
end


%% PulseSine
LongestStim = 0;
for stim = 1:size(PulseSine.NormDFF)
    if ~strcmp(PulseSine.Gender{stim},nGender),continue,end
    if LongestStim < size(PulseSine.NormDFF{stim},2)
        LongestStim = size(PulseSine.NormDFF{stim},2);
    end
end

mPulse56 = zeros(1,LongestStim); nIndex1 = 1;
mPulse56Sine100 = zeros(1,LongestStim); nIndex2 = 1;
mPulse56Size250 = zeros(1,LongestStim); nIndex3 = 1;

for stim = 1:size(PulseSine.NormDFF)
    if ~strcmp(PulseSine.Gender{stim},nGender),continue,end
    if strcmp(PulseSine.stimparam{stim},'pulseTrain_16PDUR_20PPAU_56PNUM_250PCAR')
        mPulse56(nIndex1,1:length(PulseSine.NormDFF{stim})) =...
            PulseSine.NormDFF{stim};nIndex1 = nIndex1 + 1;
    elseif strcmp(PulseSine.stimparam{stim},'pulseTrain_16PDUR_20PPAU_56PN_250CAR__sine_2000DUR_100CAR')
        mPulse56Sine100(nIndex2,1:length(PulseSine.NormDFF{stim})) =...
            PulseSine.NormDFF{stim};nIndex2 = nIndex2 + 1;
    elseif strcmp(PulseSine.stimparam{stim},'pulseTrain_16PDUR_20PPAU_56PN_250CAR__sine_2000DUR_250CAR')
        mPulse56Size250(nIndex3,1:length(PulseSine.NormDFF{stim})) =...
            PulseSine.NormDFF{stim};nIndex3 = nIndex3 + 1;
    end
end

figure(FIG1+8); clf
h = gcf; h.Color = [1 1 1 ];
subplot(221), hold off
plot((1:size(mPulse56,2))/fps,mean(mPulse56),'k','LineWidth',2), hold on
plot((1:size(mPulse56Sine100,2))/fps,mean(mPulse56Sine100),'r','LineWidth',2)
plot((1:size(mPulse56Size250,2))/fps,mean(mPulse56Size250),'b','LineWidth',2)


title('Female - PulseSine')
legend('PulseTrain56','PulseTrain56Sine100Hz','PulseTrain56Sine250Hz')
box off
xlabel('Time [sec]','FontSize',16)
ylabel('Norm \delta F/F','FontSize',16)
axis tight

ax = gca;
ax.FontSize = 12;
ax.XMinorTick = 'off';

subplot(223), hold off
plot((1:size(mPulse56,2))/fps,mPulse56','k','LineWidth',2), hold on
plot((1:size(mPulse56Sine100,2))/fps,mPulse56Sine100','r','LineWidth',2)
plot((1:size(mPulse56Size250,2))/fps,mPulse56Size250','b','LineWidth',2)


%% SinePulse
LongestStim = 0;
for stim = 1:size(SinePulse.NormDFF)
    if ~strcmp(SinePulse.Gender{stim},nGender),continue,end
    if LongestStim < size(SinePulse.NormDFF{stim},2)
        LongestStim = size(SinePulse.NormDFF{stim},2);
    end
end

mSine100 = zeros(1,LongestStim); nIndex1 = 1;
mSine100Pulse56 = zeros(1,LongestStim); nIndex2 = 1;
mSine250 = zeros(1,LongestStim); nIndex3 = 1;
mSine250Pulse56 = zeros(1,LongestStim); nIndex4 = 1;
for stim = 1:size(SinePulse.NormDFF)
    if ~strcmp(SinePulse.Gender{stim},nGender),continue,end
    if strcmp(SinePulse.stimparam{stim},'SIN_100_0_2000_100')
        mSine100(nIndex1,1:length(SinePulse.NormDFF{stim})) =...
            SinePulse.NormDFF{stim};nIndex1 = nIndex1 + 1;
    elseif strcmp(SinePulse.stimparam{stim},'sine_2000DUR_100CAR__pulseTrain_16PDUR_20PPAU_56PN_250CAR')
        mSine100Pulse56(nIndex2,1:length(SinePulse.NormDFF{stim})) =...
            SinePulse.NormDFF{stim};nIndex2 = nIndex2 + 1;
    elseif strcmp(SinePulse.stimparam{stim},'SIN_250_0_2000_100')
        mSine250(nIndex3,1:length(SinePulse.NormDFF{stim})) =...
            SinePulse.NormDFF{stim};nIndex3 = nIndex3 + 1;
    elseif strcmp(SinePulse.stimparam{stim},'sine_2000DUR_250CAR__pulseTrain_16PDUR_20PPAU_56PN_250CAR')
        mSine250Pulse56(nIndex4,1:length(SinePulse.NormDFF{stim})) =...
            SinePulse.NormDFF{stim};nIndex4 = nIndex4 + 1;
    end
    
end

figure(FIG1+8)
subplot(222), hold off
plot((1:size(mSine100,2))/fps,mean(mSine100),'k','LineWidth',2), hold on
plot((1:size(mSine100Pulse56,2))/fps,mean(mSine100Pulse56),':k','LineWidth',2)
plot((1:size(mSine250,2))/fps,mean(mSine250),'r','LineWidth',2)
plot((1:size(mSine250Pulse56,2))/fps,mean(mSine250Pulse56),':r','LineWidth',2)



title('Female - SinePulse')
legend('Sine100','Sine100Pulse56','Sine250','Sine250Pulse56')
set(gca,'xTick',0:40:160)
box off
xlabel('Time [sec]','FontSize',16)
ylabel('Norm \delta F/F','FontSize',16)
axis tight

ax = gca;
ax.FontSize = 12;
ax.XMinorTick = 'off';

subplot(224), hold off
plot((1:size(mSine100,2))/fps,mSine100','k','LineWidth',2), hold on
plot((1:size(mSine100Pulse56,2))/fps,mSine100Pulse56',':k','LineWidth',2)
plot((1:size(mSine250,2))/fps,mSine250','r','LineWidth',2)
plot((1:size(mSine250Pulse56,2))/fps,mSine250Pulse56',':r','LineWidth',2)

end


%% local function - plots

function Im2P_PlotTuning(data,TITLES, XLABEL, bNormalize,islogx, figureNumber,fps)

%for each session and parameter - make an average
vAllFlyNumbers = cell2mat(data.FlyNumber);
vAllStimParam = cell2mat(data.stimparam);
TEMPdata = data(1,:);
nIndex = 1;
for nFlyNumber = unique(vAllFlyNumbers)'
    for nStimParam = unique(vAllStimParam)'
        vLines = find(vAllFlyNumbers == nFlyNumber & vAllStimParam == nStimParam);
        if isempty(vLines),continue,end
        MIN = inf;
        for LINE = 1:size(data(vLines,:).NormDFF,1),MIN = min(MIN,length(data(vLines,:).NormDFF{LINE}));end
        MAT = zeros(1,1);
        for LINE = 1:size(data(vLines,:).NormDFF,1)
            MAT(LINE,1:MIN) =   data(vLines,:).NormDFF{LINE}(1:MIN);
        end
        
        TEMPdata.FlyNumber{nIndex,1} = nFlyNumber;
        TEMPdata.Folder{nIndex,1} = data.Folder{vLines(1)};
        TEMPdata.Gender{nIndex,1} = data.Gender{vLines(1)};
        TEMPdata.stimparam{nIndex,1} = nStimParam;
        TEMPdata.Norm_MaxDFF{nIndex,1} = mean(cell2mat(data(vLines,:).Norm_MaxDFF));
        TEMPdata.sum_DFF{nIndex,1} = mean(cell2mat(data(vLines,:).sum_DFF));
        TEMPdata.NormDFF{nIndex,1} = mean(MAT,1);
        TEMPdata.StartEndFrame{nIndex,1} = data.StartEndFrame{vLines(1)};
        nIndex = nIndex + 1;
    end
end

data = TEMPdata;

figure(figureNumber),clf

vParameter = unique(cell2mat(data.stimparam));


%Plot mean trace
YlimTraces = [inf -inf;inf -inf];
XlimTraces = [inf -inf;inf -inf];

for GENDER = 1:2%1 - male, 2 - female
    if GENDER == 1, nGender = 'M'; else, nGender = 'F'; end
    subplot(2,2,2+GENDER), hold off
    COLORS = jet(length(vParameter));
    LEGEND = cell(1,length(vParameter));
    TITLE = TITLES(GENDER);
    
    for nParamIndex = 1:length(vParameter)
        nPARAMETER = vParameter(nParamIndex);
        mTraces = zeros(1,1);
        nIndex = 1;
        
        
        for nLine = 1:size(data.stimparam,1)
            if ~(strcmp(data.Gender(nLine),nGender)), continue,end
            if ~(data.stimparam{nLine} == nPARAMETER), continue, end
            if data.StartEndFrame{nLine}(1)-42>0, START = data.StartEndFrame{nLine}(1)-42; else, START = 1;end
            if length(data.NormDFF{nLine}) - data.StartEndFrame{nLine}(2)>85
                END = length(data.NormDFF{nLine}) - 85;
            else
                END = length(data.NormDFF{nLine});
            end
            mTraces(nIndex,1:length(START:END)) = data.NormDFF{nLine}(START:END);
            stimONOFF = data.StartEndFrame{nLine} - START + 1;
            nIndex = nIndex + 1;
        end
        X = (1:size(mTraces,2))/fps;
        plot(X,mean(mTraces),'color',COLORS(nParamIndex,:)),hold on
        LEGEND{nParamIndex} = num2str(nPARAMETER);
    end
    
    axis tight
    h = legend(LEGEND); h.EdgeColor = [1 1 1];
    ax = gca;
    if ~(all(size(mTraces) == [1 1])), YlimTraces(GENDER,1:2) = ax.YLim; XlimTraces(GENDER,1:2) = ax.XLim;end
    ax.FontSize = 12;
    title(TITLE)
    h = gcf; h.Color = [1 1 1 ]; box off
    xlabel('Time [sec]'), ylabel('Norm \delta F/F','FontSize',16)
    
end

%Plot tuning
YLIM = zeros(2,2);
for GENDER = 1:2%1 - male, 2 - female
    if GENDER == 1, nGender = 'M'; else, nGender = 'F'; end
    TITLE = TITLES(GENDER);
    vParameter = zeros(1,size(data.stimparam,1));
    for nLine = 1:size(data.stimparam,1)
        vParameter(nLine) =  data.stimparam{nLine};
    end
    vParameter = unique(vParameter);
    
    sMale = struct('vParameter',[],'Norm_MaxDFF',[],'sum_DFF',[]);
    for nIndex = 1:length(vParameter)
        sMale.Norm_MaxDFF{nIndex} = [];
        sMale.sum_DFF{nIndex} = [];
    end
    sFemale = struct('vParameter',[],'Norm_MaxDFF',[],'sum_DFF',[]);
    for nIndex = 1:length(vParameter)
        sFemale.Norm_MaxDFF{nIndex} = [];
        sFemale.sum_DFF{nIndex} = [];
    end
    
    for nLine = 1:size(data.stimparam,1)
        nPARAMETER = data.stimparam{nLine};
        nIndex = find(vParameter == nPARAMETER);
        if  strcmp(data.Gender{nLine},'M')
            sMale.vParameter{nIndex} = nPARAMETER;
            sMale.Norm_MaxDFF{nIndex} = [sMale.Norm_MaxDFF{nIndex} data.Norm_MaxDFF{nLine}];
            sMale.sum_DFF{nIndex} = [sMale.sum_DFF{nIndex} data.sum_DFF{nLine}];
        elseif strcmp(data.Gender{nLine},'F')
            sFemale.vParameter{nIndex} = nPARAMETER;
            sFemale.Norm_MaxDFF{nIndex} = [sFemale.Norm_MaxDFF{nIndex} data.Norm_MaxDFF{nLine}];
            sFemale.sum_DFF{nIndex} = [sFemale.sum_DFF{nIndex} data.sum_DFF{nLine}];
        end
    end
    
    
    figure(figureNumber)
    X = zeros(1,length(vParameter));
    Y1 = zeros(1,length(vParameter));
    E1 = zeros(1,length(vParameter));
    Y2 = zeros(1,length(vParameter));
    E2 = zeros(1,length(vParameter));
    if strcmp(nGender,'M')%male
        for nIndex = 1:length(vParameter)
            X(nIndex) = vParameter(nIndex);
            Y1(nIndex) = mean(sMale.Norm_MaxDFF{nIndex});
            E1(nIndex) = std(sMale.Norm_MaxDFF{nIndex})/sqrt(length(sMale.Norm_MaxDFF{nIndex}));
            Y2(nIndex) = mean(sMale.sum_DFF{nIndex});
            E2(nIndex) = std(sMale.sum_DFF{nIndex})/sqrt(length(sMale.sum_DFF{nIndex}));
        end
    else %female
        for nIndex = 1:length(vParameter)
            X(nIndex) = vParameter(nIndex);
            Y1(nIndex) = mean(sFemale.Norm_MaxDFF{nIndex});
            E1(nIndex) = std(sFemale.Norm_MaxDFF{nIndex})/sqrt(length(sFemale.Norm_MaxDFF{nIndex}));
            Y2(nIndex) = mean(sFemale.sum_DFF{nIndex});
            E2(nIndex) = std(sFemale.sum_DFF{nIndex})/sqrt(length(sFemale.sum_DFF{nIndex}));
        end
    end
    
    
    if bNormalize == 1, E1 = E1/max(Y1); Y1 = Y1/max(Y1); Y2 = Y2/max(Y2); E2 = E2/max(Y2); Y2 = Y2/max(Y2); end
    
    %     if islogx == 0
    subplot(2,2,1)
    if GENDER == 1, hold off, else, hold on, end
    h = errorbar(X,Y1,E1,'o-','LineWidth',2);
    h.CapSize = 0;
    h.MarkerSize = 1;
    if GENDER == 1, h.Color = 'cyan'; else, h.Color = 'magenta'; end
    subplot(2,2,2)
    if GENDER == 1, hold off, else, hold on, end
    h = errorbar(X,Y2,E2,'o-','LineWidth',2);
    h.CapSize = 0;
    h.MarkerSize = 1;
    if GENDER == 1, h.Color = 'cyan'; else, h.Color = 'magenta'; end
    ax = gca;
    YLIM(GENDER,1:2) = ax.YLim;
    
end

%plot properties
for SUBPLOT = 1:2
    subplot(2,2,SUBPLOT)
    par = strfind(TITLE,'('); %remove the gender from the title for subplots 1,2
    title(TITLE{1}(1:par{1}-1))
    h = legend('Male','Female','location','NW'); h.EdgeColor = [1 1 1];
    box off, axis tight
    xlabel(XLABEL,'FontSize',16)
    
    if SUBPLOT == 1
        ylabel('Norm max \delta F/F','FontSize',16)
    else
        ylabel('Norm sum \delta F/F','FontSize',16)
    end
    
    if islogx
        set(gca,'xTick',vParameter,'XScale','log')
    else
        set(gca,'xTick',vParameter)
    end
    ax = gca;
    ax.FontSize = 12;
    ax.XMinorTick = 'off';
end

%Same y-axis limits for both genders
YYLIM(1) = min(YLIM(1:2,1)); YYLIM(2) = max(YLIM(1:2,2));
subplot(221), ylim(YYLIM), subplot(222), ylim(YYLIM)

YYlimTraces(1) = min(YlimTraces(1:2,1)); YYlimTraces(2) = max(YlimTraces(1:2,2));
XXlimTraces(1) = min(XlimTraces(1:2,1)); XXlimTraces(2) = min(XlimTraces(1:2,2));
subplot(223), xlim(XXlimTraces), ylim(YYlimTraces)
plot([stimONOFF(1) stimONOFF(2)]/fps,[YYlimTraces(1) YYlimTraces(1)],'r','LineWidth',3)
subplot(224), xlim(XXlimTraces), ylim(YYlimTraces)
plot([stimONOFF(1) stimONOFF(2)]/fps,[YYlimTraces(1) YYlimTraces(1)],'r','LineWidth',3)

end
