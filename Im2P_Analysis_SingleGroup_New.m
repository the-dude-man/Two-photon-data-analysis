%The script Im2P_Analysis_SingleGroup is calculating and showing analisys of
%two-photon scanning with the single_group experiment

%parameters
bOverride_mAlldata = 0;%if =1, load datafile even if the variable mAllData already exists in the workspace
nWindow = 5;%smoothing window

ROI = {'Ring','LPC'};
CurrDir = pwd;

if ~bOverride_mAlldata && ~exist('mAllData','var')
    datafile = 'Z:\Dudi\Imaging\2Photon\Diego_setup\Alldata_Playback.mat';
    disp('Loading Alldata_Playback...')
    load(datafile)
    disp('...loading is done')
end

FramesPerSecond = mAllData.FramesPerSecond{1};
%% Collect data into vectors and matrices
%max or summed response
clear IPI IPI_Housed IPI_Gender IPI_FlyNumber DFF_max_IPI DFF_sum_IPI DFF_max_IPI_Norm DFF_sum_IPI_Norm
clear SINEfreq SINEfreq_Housed SINEfreq_Gender DFF_max_SINEfreq DFF_sum_SINEfreq DFF_max_SINEfreq_Norm DFF_sum_SINEfreq_Norm
clear PNUM PNUM_Housed PNUM_Gender PNUM_FlyNumber DFF_max_PNUM DFF_sum_PNUM DFF_max_PNUM_Norm DFF_sum_PNUM_Norm

%traces
clear mDFF_IPIrace mDFF_IPI_NormTrace
clear mDFF_SINETrace mDFF_SINE_NormTrace
clear mDFF_PNUMTrace mDFF_PNUM_NormTrace


IPIindex = 1; SINEindex = 1; PNUMindex = 1;
for ii = 1:size(mAllData,1)
    %check experiment and ROI
    if isempty(strfind(mAllData.Folder{ii},'DSX_SingleGroup')), continue,end
    FrameStartStim = mAllData.FrameStartStim{ii};
    
    if ~any(strcmp(ROI,mAllData.ROIname{ii})), continue,end%check ROI name
    cd(mAllData.Folder{ii})
    
    %pulse train
    if ~isempty(strfind(mAllData.StimName{ii},'pulseTrain')) && isempty(strfind(mAllData.StimName{ii},'PNUM'))
        IPI(IPIindex) = str2num(mAllData.StimName{ii}(12:13));
        IPI_Housed(IPIindex) = mAllData.Housed{ii};
        IPI_Gender(IPIindex) = mAllData.Gender{ii};
        IPI_FlyNumber(IPIindex) = mAllData.FlyNumber(ii);
        
        %max/summed response
        DFF_max_IPI(IPIindex) = mAllData.GreenSignal_MaxDFF{ii};
        DFF_sum_IPI(IPIindex) = mAllData.GreenSignal_SumDFF{ii};
        DFF_max_IPI_Norm(IPIindex) = mAllData.GreenSignal_MaxDFF{ii}/mAllData.MaxDFFAllStim{ii};
        DFF_sum_IPI_Norm(IPIindex) = mAllData.GreenSignal_SumDFF{ii}/mAllData.MaxSumDFFAllStim{ii};
        %traces
        mDFF_IPITrace(IPIindex,1:length(mAllData.GreenSignal_DFFinROI{ii})) = mAllData.GreenSignal_DFFinROI{ii};
        mDFF_IPI_NormTrace(IPIindex,1:length(mAllData.GreenSignal_DFFinROI{ii})) = mAllData.GreenSignal_DFFinROI{ii}/...
            mAllData.MaxDFFAllStim{ii};
        
        IPIindex = IPIindex + 1;
    end
    
    %sine
    if ~isempty(strfind(mAllData.StimName{ii},'SIN'))
        SINE(SINEindex) = str2num(mAllData.StimName{ii}(5:7));
        SINE_Housed(SINEindex) = mAllData.Housed{ii};
        SINE_Gender(SINEindex) = mAllData.Gender{ii};
        SINE_FlyNumber(SINEindex) = mAllData.FlyNumber(ii);
        
        %max/summed response
        DFF_max_SINE(SINEindex) = mAllData.GreenSignal_MaxDFF{ii};
        DFF_sum_SINE(SINEindex) = mAllData.GreenSignal_SumDFF{ii};
        DFF_max_SINE_Norm(SINEindex) = mAllData.GreenSignal_MaxDFF{ii}/mAllData.MaxDFFAllStim{ii};
        DFF_sum_SINE_Norm(SINEindex) = mAllData.GreenSignal_SumDFF{ii}/mAllData.MaxSumDFFAllStim{ii};
        %traces
        mDFF_SINETrace(SINEindex,1:length(mAllData.GreenSignal_DFFinROI{ii})) = mAllData.GreenSignal_DFFinROI{ii};
        mDFF_SINE_NormTrace(SINEindex,1:length(mAllData.GreenSignal_DFFinROI{ii})) = mAllData.GreenSignal_DFFinROI{ii}/...
            mAllData.MaxDFFAllStim{ii};
        
        SINEindex = SINEindex + 1;
    end
    
    %PNUM - pulse number
    if ~isempty(strfind(mAllData.StimName{ii},'PNUM')) && isempty(strfind(mAllData.StimName{ii},'112'))
        Start = strfind(mAllData.StimName{ii},'PPAU') + 5;
        End = strfind(mAllData.StimName{ii},'PNUM') -1;
        PNUM(PNUMindex) = str2num(mAllData.StimName{ii}(Start:End));
        PNUM_Housed(PNUMindex) = mAllData.Housed{ii};
        PNUM_Gender(PNUMindex) = mAllData.Gender{ii};
        PNUM_FlyNumber(PNUMindex) = mAllData.FlyNumber(ii);
        
        %max/summed response
        DFF_max_PNUM(PNUMindex) = mAllData.GreenSignal_MaxDFF{ii};
        DFF_sum_PNUM(PNUMindex) = mAllData.GreenSignal_SumDFF{ii};
        DFF_max_PNUM_Norm(PNUMindex) = mAllData.GreenSignal_MaxDFF{ii}/mAllData.MaxDFFAllStim{ii};
        DFF_sum_PNUM_Norm(PNUMindex) = mAllData.GreenSignal_SumDFF{ii}/mAllData.MaxSumDFFAllStim{ii};
        %traces
        mDFF_PNUMTrace(PNUMindex,1:length(mAllData.GreenSignal_DFFinROI{ii})) = mAllData.GreenSignal_DFFinROI{ii};
        mDFF_PNUM_NormTrace(PNUMindex,1:length(mAllData.GreenSignal_DFFinROI{ii})) = mAllData.GreenSignal_DFFinROI{ii}/...
            mAllData.MaxDFFAllStim{ii};
        
        PNUMindex = PNUMindex + 1;
    end
end

%remove zeros from Traces
%IPI
mDFF_IPITrace = removezeros(mDFF_IPITrace);
mDFF_IPI_NormTrace = removezeros(mDFF_IPI_NormTrace);
%SINE
mDFF_SINETrace = removezeros(mDFF_SINETrace);
mDFF_SINE_NormTrace = removezeros(mDFF_SINE_NormTrace);
%PNUM
mDFF_PNUMTrace = removezeros(mDFF_PNUMTrace);
mDFF_PNUM_NormTrace = removezeros(mDFF_PNUM_NormTrace);



%%now building a single matrix per stimulus type
sAllResults_IPI = cell(2,2,2);
sAllResults_SINE = cell(2,2,2);
sAllResults_PNUM = cell(2,2,2);

Housing = 'SG';%S - single housed, G = group housed
for HousedIndex = 1:2
    Housed = Housing(HousedIndex);
    Genders = 'MF';%M - male, F - female
    for GenderIndex = 1:2
        Gender = Genders(GenderIndex);
        Normalization = [0 1];
        for NormIndex = 1:2
            Normalize = Normalization(NormIndex);
            %IPI
            Unique_Flies = unique(IPI_FlyNumber(IPI_Housed == Housed & IPI_Gender == Gender));
            Unique_IPI = unique(IPI);
            
            for nIPI = 1:length(Unique_IPI)
                oneIPI = Unique_IPI(nIPI);
                for nFly = 1:length(Unique_Flies)
                    oneFly = Unique_Flies(nFly);
                    if Normalize == 0
                        sAllResults_IPI{HousedIndex,GenderIndex,NormIndex}.mflyresponses_maxDFF(nFly,nIPI) =...
                            mean(DFF_max_IPI(IPI_Gender == Gender &...
                            IPI_Housed == Housed & IPI_FlyNumber == oneFly & IPI == oneIPI));
                        sAllResults_IPI{HousedIndex,GenderIndex,NormIndex}.mflyresponses_sumDFF(nFly,nIPI) =...
                            mean(DFF_sum_IPI(IPI_Gender == Gender &...
                            IPI_Housed == Housed & IPI_FlyNumber == oneFly & IPI == oneIPI));
                        temp = mean(mDFF_IPITrace(IPI_Gender == Gender &...
                            IPI_Housed == Housed & IPI_FlyNumber == oneFly & IPI == oneIPI,:),1);
                        sAllResults_IPI{HousedIndex,GenderIndex,NormIndex}.IPITrace_mean(nFly,nIPI,1:length(temp)) = temp;
                    else
                        sAllResults_IPI{HousedIndex,GenderIndex,NormIndex}.mflyresponses_maxDFF(nFly,nIPI) =...
                            mean(DFF_max_IPI_Norm(IPI_Gender == Gender &...
                            IPI_Housed == Housed & IPI_FlyNumber == oneFly & IPI == oneIPI));
                        sAllResults_IPI{HousedIndex,GenderIndex,NormIndex}.mflyresponses_sumDFF(nFly,nIPI) =...
                            mean(DFF_sum_IPI_Norm(IPI_Gender == Gender &...
                            IPI_Housed == Housed & IPI_FlyNumber == oneFly & IPI == oneIPI));
                        temp = mean(mDFF_IPI_NormTrace(IPI_Gender == Gender &...
                            IPI_Housed == Housed & IPI_FlyNumber == oneFly & IPI == oneIPI,:),1);
                        sAllResults_IPI{HousedIndex,GenderIndex,NormIndex}.IPITrace_mean(nFly,nIPI,1:length(temp)) = temp;
                    end
                end
            end
            
            %Sine frequency
            Unique_Flies = unique(SINE_FlyNumber(SINE_Housed == Housed & SINE_Gender == Gender));
            Unique_SINE = unique(SINE);
            
            for nSINE = 1:length(Unique_SINE)
                oneSINE = Unique_SINE(nSINE);
                for nFly = 1:length(Unique_Flies)
                    oneFly = Unique_Flies(nFly);
                    if Normalize == 0
                        sAllResults_SINE{HousedIndex,GenderIndex,NormIndex}.mflyresponses_maxDFF(nFly,nSINE) =...
                            mean(DFF_max_SINE(SINE_Gender == Gender &...
                            SINE_Housed == Housed & SINE_FlyNumber == oneFly & SINE == oneSINE));
                        sAllResults_SINE{HousedIndex,GenderIndex,NormIndex}.mflyresponses_sumDFF(nFly,nSINE) =...
                            mean(DFF_sum_SINE(SINE_Gender == Gender &...
                            SINE_Housed == Housed & SINE_FlyNumber == oneFly & SINE == oneSINE));
                        temp = mean(mDFF_SINETrace(SINE_Gender == Gender &...
                            SINE_Housed == Housed & SINE_FlyNumber == oneFly & SINE == oneSINE,:),1);
                        sAllResults_SINE{HousedIndex,GenderIndex,NormIndex}.SINETrace_mean(nFly,nSINE,1:length(temp)) = temp;
                    else
                        sAllResults_SINE{HousedIndex,GenderIndex,NormIndex}.mflyresponses_maxDFF(nFly,nSINE) =...
                            mean(DFF_max_SINE_Norm(SINE_Gender == Gender &...
                            SINE_Housed == Housed & SINE_FlyNumber == oneFly & SINE == oneSINE));
                        sAllResults_SINE{HousedIndex,GenderIndex,NormIndex}.mflyresponses_sumDFF(nFly,nSINE) =...
                            mean(DFF_sum_SINE_Norm(SINE_Gender == Gender &...
                            SINE_Housed == Housed & SINE_FlyNumber == oneFly & SINE == oneSINE));
                        temp = mean(mDFF_SINE_NormTrace(SINE_Gender == Gender &...
                            SINE_Housed == Housed & SINE_FlyNumber == oneFly & SINE == oneSINE,:),1);
                        sAllResults_SINE{HousedIndex,GenderIndex,NormIndex}.SINETrace_mean(nFly,nSINE,1:length(temp)) = temp;
                    end
                end
            end
            
            
            
            %pulse number
            Unique_Flies = unique(PNUM_FlyNumber(PNUM_Housed == Housed & PNUM_Gender == Gender));
            Unique_PNUM = unique(PNUM);
            
            for nPNUM = 1:length(Unique_PNUM)
                onePNUM = Unique_PNUM(nPNUM);
                for nFly = 1:length(Unique_Flies)
                    oneFly = Unique_Flies(nFly);
                    if Normalize == 0
                        sAllResults_PNUM{HousedIndex,GenderIndex,NormIndex}.mflyresponses_maxDFF(nFly,nPNUM) =...
                            mean(DFF_max_PNUM(PNUM_Gender == Gender &...
                            PNUM_Housed == Housed & PNUM_FlyNumber == oneFly & PNUM == onePNUM));
                        sAllResults_PNUM{HousedIndex,GenderIndex,NormIndex}.mflyresponses_sumDFF(nFly,nPNUM) =...
                            mean(DFF_sum_PNUM(PNUM_Gender == Gender &...
                            PNUM_Housed == Housed & PNUM_FlyNumber == oneFly & PNUM == onePNUM));
                        temp = mean(mDFF_PNUMTrace(PNUM_Gender == Gender &...
                            PNUM_Housed == Housed & PNUM_FlyNumber == oneFly & PNUM == onePNUM,:),1);
                        sAllResults_PNUM{HousedIndex,GenderIndex,NormIndex}.PNUMTrace_mean(nFly,nPNUM,1:length(temp)) = temp;
                    else
                        sAllResults_PNUM{HousedIndex,GenderIndex,NormIndex}.mflyresponses_maxDFF(nFly,nPNUM) =...
                            mean(DFF_max_PNUM_Norm(PNUM_Gender == Gender &...
                            PNUM_Housed == Housed & PNUM_FlyNumber == oneFly & PNUM == onePNUM));
                        sAllResults_PNUM{HousedIndex,GenderIndex,NormIndex}.mflyresponses_sumDFF(nFly,nPNUM) =...
                            mean(DFF_sum_PNUM_Norm(PNUM_Gender == Gender &...
                            PNUM_Housed == Housed & PNUM_FlyNumber == oneFly & PNUM == onePNUM));
                        temp = mean(mDFF_PNUM_NormTrace(PNUM_Gender == Gender &...
                            PNUM_Housed == Housed & PNUM_FlyNumber == oneFly & PNUM == onePNUM,:),1);
                        sAllResults_PNUM{HousedIndex,GenderIndex,NormIndex}.PNUMTrace_mean(nFly,nPNUM,1:length(temp)) = temp;
                    end
                end
            end
            %end of pulse number
            
        end
    end
end

cd(CurrDir)


%% figures
SingleHoused_Color = [0 0 0];
GroupHoused_Color = [1 0 0];
Genders = 'MF';%M - male, F - female

%IPI
for GenderIndex = 1:2
    Gender = Genders(GenderIndex);
    hfig = figure(GenderIndex);%IPI tuning
    clf(hfig)
    hfig.Color = [1 1 1];
    subplot(221),hold off
    SingleFly_IPI = sAllResults_IPI{1,GenderIndex,1}.mflyresponses_sumDFF;
    errorbar(Unique_IPI,mean(SingleFly_IPI),std(SingleFly_IPI)/...
        sqrt(size(SingleFly_IPI,1)),'LineWidth',2,'Color',SingleHoused_Color)
    hold on
    GroupFly_IPI = sAllResults_IPI{2,GenderIndex,1}.mflyresponses_sumDFF;
    errorbar(Unique_IPI,mean(GroupFly_IPI),std(GroupFly_IPI)/...
        sqrt(size(GroupFly_IPI,1)),'LineWidth',2,'Color',GroupHoused_Color)
    lgd = legend('Single housed','Group housed');
    lgd.EdgeColor = [1 1 1];
    box off
    xlabel('IPI - Inter Pulse Interval [ms]','FontSize',16)
    ylabel('Integral {\Delta}F/F','FontSize',16)
    haxis = gca;
    haxis.XTick = Unique_IPI;
    haxis.FontSize = 16;
    
    %statistics
    S = SingleFly_IPI(:,3:5); S = reshape(S,[],1);
    G = GroupFly_IPI(:,3:5); G = reshape(G,[],1);
    [~,P] = ttest2(S,G);
    if GenderIndex == 1%males
        Y = [-0.2 -0.6];
    else%females
        Y = [23 21];
    end
    text(16,Y(1),'Response to IPI > 36ms (ttest) - ','FontSize',14)
    text(16,Y(2),['P = ',num2str(round(P,5))],'FontSize',14)
    if strcmp(Gender,'M')
        title('Male, IPI tuning')
    else
        title('Female, IPI tuning')
    end
    
    subplot(222),hold off%ratio between max response to 36IPI vs 56IPI
    delta = 0.006;
    
    SingleRatio = sAllResults_IPI{1,GenderIndex,1}.mflyresponses_sumDFF(:,2)./sAllResults_IPI{1,GenderIndex,1}.mflyresponses_sumDFF(:,3);
    GroupRatio = sAllResults_IPI{2,GenderIndex,1}.mflyresponses_sumDFF(:,2)./sAllResults_IPI{2,GenderIndex,1}.mflyresponses_sumDFF(:,3);
    
    X_single = linspace(-delta,delta,length(SingleRatio));
    Rperm = randperm(length(X_single));
    X_single = 1 + X_single(Rperm);
    
    X_group = linspace(-delta,delta,length(GroupRatio));
    Rperm = randperm(length(X_group));
    X_group = 1 + 18*delta + X_group(Rperm);
    
    plot(X_single,SingleRatio,'o','MarkerSize',10,'MarkerEdgeColor',SingleHoused_Color,'MarkerFaceColor',SingleHoused_Color)%single housed
    hold on
    plot(X_group,GroupRatio,'o','MarkerSize',10,'MarkerEdgeColor',GroupHoused_Color,'MarkerFaceColor',GroupHoused_Color)%group housed
    box off
    h = gca;
    h.XTick = [1 1 + 18*delta];
    h.XTickLabel = {'Single housed','Group housed'};
    h.XLim = [h.XTick(1)-5*delta h.XTick(2)+5*delta];
    box off
    ylabel('Response ratio (36IPI/56IPI)','FontSize',16)
    haxis = gca;
    haxis.FontSize = 16;
    
    subplot(223),hold off
    %Traces - single housed
    COLORS =  parula(length(Unique_IPI));
    PARAM_NAME = 'IPI';%used for the legend
    
    TraceLength = size(squeeze(sAllResults_IPI{1,GenderIndex,1}.IPITrace_mean(:,1,:)),2);
    for nIPI = 1:length(Unique_IPI)
        SingleFly_IPI_Trace = squeeze(sAllResults_IPI{1,GenderIndex,1}.IPITrace_mean(:,nIPI,:));
        shadedErrorBar((1:TraceLength)/FramesPerSecond,mean(movmean(SingleFly_IPI_Trace,nWindow,2)),...
            std(movmean(SingleFly_IPI_Trace,nWindow,2))/sqrt(TraceLength),{'color',COLORS(nIPI,:)}),hold on
    end
    box off
    xlabel('Time [seconds]','FontSize',16)
    ylabel('{\Delta}F/F','FontSize',16)
    haxis = gca;
    haxis.FontSize = 16;
    
    subplot(224),hold off
    %Traces - group housed
    TraceLength = size(squeeze(sAllResults_IPI{2,GenderIndex,1}.IPITrace_mean(:,1,:)),2);
    
    for nIPI = 1:length(Unique_IPI)
        GroupFly_IPI_Trace = squeeze(sAllResults_IPI{2,GenderIndex,1}.IPITrace_mean(:,nIPI,:));
        shadedErrorBar((1:TraceLength)/FramesPerSecond,mean(movmean(GroupFly_IPI_Trace,nWindow,2)),...
            std(movmean(GroupFly_IPI_Trace,nWindow,2))/sqrt(TraceLength),{'color',COLORS(nIPI,:)}),hold on
    end
    box off
    xlabel('Time [seconds]','FontSize',16)
    ylabel('{\Delta}F/F','FontSize',16)
    haxis = gca;
    haxis.FontSize = 16;
    
    %yaxis - same for subplots 223, 224
    MIN1 = min(min(mean(squeeze(sAllResults_IPI{1,GenderIndex,1}.IPITrace_mean(:,:,:)))));
    MIN2 = min(min(mean(squeeze(sAllResults_IPI{2,GenderIndex,1}.IPITrace_mean(:,:,:)))));
    MIN = floor(100*min(MIN1,MIN2))/100;
    MAX1 = max(max(mean(squeeze(sAllResults_IPI{1,GenderIndex,1}.IPITrace_mean(:,:,:)))));
    MAX2 = max(max(mean(squeeze(sAllResults_IPI{2,GenderIndex,1}.IPITrace_mean(:,:,:)))));
    MAX = ceil(100*max(MAX1,MAX2))/100;
    subplot(223), set(gca,'Ylim',[MIN 1.05*MAX])
    axis_handle = gca;
    addlegend(COLORS,PARAM_NAME,Unique_IPI,axis_handle)
    plot([FrameStartStim FrameStartStim]/FramesPerSecond,[axis_handle.YLim],'--k')
    plot([FrameStartStim FrameStartStim]/FramesPerSecond,[axis_handle.YLim],'--k')
    subplot(224), set(gca,'Ylim',[MIN 1.05*MAX])
    axis_handle = gca;
    addlegend(COLORS,PARAM_NAME,Unique_IPI,axis_handle)
    plot([FrameStartStim FrameStartStim]/FramesPerSecond,[axis_handle.YLim],'--k')
    
end

%Sine
for GenderIndex = 1:2
    Gender = Genders(GenderIndex);
    hfig = figure(GenderIndex+2);%SINE freq tuning
    clf(hfig)
    hfig.Color = [1 1 1];
    subplot(221),hold off
    SingleFly_SINE = sAllResults_SINE{1,GenderIndex,1}.mflyresponses_sumDFF;
    errorbar(Unique_SINE,mean(SingleFly_SINE),std(SingleFly_SINE)/...
        sqrt(size(SingleFly_SINE,1)),'LineWidth',2,'Color',SingleHoused_Color)
    hold on
    GroupFly_SINE = sAllResults_SINE{2,GenderIndex,1}.mflyresponses_sumDFF;
    errorbar(Unique_SINE,mean(GroupFly_SINE),std(GroupFly_SINE)/...
        sqrt(size(GroupFly_SINE,1)),'LineWidth',2,'Color',GroupHoused_Color)
    lgd = legend('Single housed','Group housed');
    lgd.EdgeColor = [1 1 1];
    box off
    xlabel('sine frequency [Hz]','FontSize',16)
    ylabel('Integral {\Delta}F/F','FontSize',16)
    haxis = gca;
    haxis.XTick = Unique_SINE;
    haxis.FontSize = 16;
    
    if strcmp(Gender,'M')
        title('Male, Sine frequence tuning')
    else
        title('Female, Sine frequence tuning')
    end
    
    
    subplot(223),hold off
    %Traces - single housed
    COLORS =  parula(length(Unique_SINE));
    PARAM_NAME = 'SINE';%used for the legend
    
    TraceLength = size(squeeze(sAllResults_SINE{1,GenderIndex,1}.SINETrace_mean(:,1,:)),2);
    for nSINE = 1:length(Unique_SINE)
        SingleFly_SINE_Trace = squeeze(sAllResults_SINE{1,GenderIndex,1}.SINETrace_mean(:,nSINE,:));
        shadedErrorBar((1:TraceLength)/FramesPerSecond,mean(movmean(SingleFly_SINE_Trace,nWindow,2)),...
            std(movmean(SingleFly_SINE_Trace,nWindow,2))/sqrt(TraceLength),{'color',COLORS(nSINE,:)}),hold on
    end
    box off
    xlabel('Time [seconds]','FontSize',16)
    ylabel('{\Delta}F/F','FontSize',16)
    haxis = gca;
    haxis.FontSize = 16;
    
    subplot(224),hold off
    %Traces - group housed
    TraceLength = size(squeeze(sAllResults_SINE{2,GenderIndex,1}.SINETrace_mean(:,1,:)),2);
    
    for nSINE = 1:length(Unique_SINE)
        GroupFly_SINE_Trace = squeeze(sAllResults_SINE{2,GenderIndex,1}.SINETrace_mean(:,nSINE,:));
        shadedErrorBar((1:TraceLength)/FramesPerSecond,mean(movmean(GroupFly_SINE_Trace,nWindow,2)),...
            std(movmean(GroupFly_SINE_Trace,nWindow,2))/sqrt(TraceLength),{'color',COLORS(nSINE,:)}),hold on
    end
    box off
    xlabel('Time [seconds]','FontSize',16)
    ylabel('{\Delta}F/F','FontSize',16)
    haxis = gca;
    haxis.FontSize = 16;
    
    %yaxis - same for subplots 223, 224
    MIN1 = min(min(mean(squeeze(sAllResults_SINE{1,GenderIndex,1}.SINETrace_mean(:,:,:)))));
    MIN2 = min(min(mean(squeeze(sAllResults_SINE{2,GenderIndex,1}.SINETrace_mean(:,:,:)))));
    MIN = floor(100*min(MIN1,MIN2))/100;
    MAX1 = max(max(mean(squeeze(sAllResults_SINE{1,GenderIndex,1}.SINETrace_mean(:,:,:)))));
    MAX2 = max(max(mean(squeeze(sAllResults_SINE{2,GenderIndex,1}.SINETrace_mean(:,:,:)))));
    MAX = ceil(100*max(MAX1,MAX2))/100;
    subplot(223), set(gca,'Ylim',[MIN 1.05*MAX])
    axis_handle = gca;
    addlegend(COLORS,PARAM_NAME,Unique_SINE,axis_handle)
    plot([FrameStartStim FrameStartStim]/FramesPerSecond,[axis_handle.YLim],'--k')
    plot([FrameStartStim FrameStartStim]/FramesPerSecond,[axis_handle.YLim],'--k')
    subplot(224), set(gca,'Ylim',[MIN 1.05*MAX])
    axis_handle = gca;
    addlegend(COLORS,PARAM_NAME,Unique_SINE,axis_handle)
    plot([FrameStartStim FrameStartStim]/FramesPerSecond,[axis_handle.YLim],'--k')
    
end


%PNUM - pulse number
for GenderIndex = 1:2
    Gender = Genders(GenderIndex);
    hfig = figure(GenderIndex+4);%PNUM freq tuning
    clf(hfig)
    hfig.Color = [1 1 1];
    subplot(221),hold off
    SingleFly_PNUM = sAllResults_PNUM{1,GenderIndex,1}.mflyresponses_sumDFF;
    errorbar(Unique_PNUM,mean(SingleFly_PNUM),std(SingleFly_PNUM)/...
        sqrt(size(SingleFly_PNUM,1)),'LineWidth',2,'Color',SingleHoused_Color)
    hold on
    GroupFly_PNUM = sAllResults_PNUM{2,GenderIndex,1}.mflyresponses_sumDFF;
    errorbar(Unique_PNUM,mean(GroupFly_PNUM),std(GroupFly_PNUM)/...
        sqrt(size(GroupFly_PNUM,1)),'LineWidth',2,'Color',GroupHoused_Color)
    lgd = legend('Single housed','Group housed');
    lgd.EdgeColor = [1 1 1];
    box off
    xlabel('Number of pulses','FontSize',16)
    ylabel('Integral {\Delta}F/F','FontSize',16)
    haxis = gca;
    haxis.XScale = 'log';
    haxis.XTick = Unique_PNUM;
    haxis.FontSize = 16;
    
    %statistics
    S = SingleFly_PNUM(:,3:5); S = reshape(S,[],1);
    G = GroupFly_PNUM(:,3:5); G = reshape(G,[],1);
    [~,P] = ttest2(S,G);
    if GenderIndex == 1%males
        Y = [-0.2 -0.6];
    else%females
        Y = [23 21];
    end
    if strcmp(Gender,'M')
        title('Male, pulse number response')
    else
        title('Female, pulse number response')
    end
    
    
    subplot(223),hold off
    %Traces - single housed
    COLORS =  parula(length(Unique_PNUM));
    PARAM_NAME = 'PNUM';%used for the legend
    
    TraceLength = size(squeeze(sAllResults_PNUM{1,GenderIndex,1}.PNUMTrace_mean(:,1,:)),2);
    for nPNUM = 1:length(Unique_PNUM)
        SingleFly_PNUM_Trace = squeeze(sAllResults_PNUM{1,GenderIndex,1}.PNUMTrace_mean(:,nPNUM,:));
        shadedErrorBar((1:TraceLength)/FramesPerSecond,mean(movmean(SingleFly_PNUM_Trace,nWindow,2)),...
            std(movmean(SingleFly_PNUM_Trace,nWindow,2))/sqrt(TraceLength),{'color',COLORS(nPNUM,:)}),hold on
    end
    box off
    xlabel('Time [seconds]','FontSize',16)
    ylabel('{\Delta}F/F','FontSize',16)
    haxis = gca;
    haxis.FontSize = 16;
    
    subplot(224),hold off
    %Traces - group housed
    COLORS =  parula(length(Unique_PNUM));
    TraceLength = size(squeeze(sAllResults_PNUM{2,GenderIndex,1}.PNUMTrace_mean(:,1,:)),2);
    
    for nPNUM = 1:length(Unique_PNUM)
        GroupFly_PNUM_Trace = squeeze(sAllResults_PNUM{2,GenderIndex,1}.PNUMTrace_mean(:,nPNUM,:));
        shadedErrorBar((1:TraceLength)/FramesPerSecond,mean(movmean(GroupFly_PNUM_Trace,nWindow,2)),...
            std(movmean(GroupFly_PNUM_Trace,nWindow,2))/sqrt(TraceLength),{'color',COLORS(nPNUM,:)}),hold on
    end
    box off
    xlabel('Time [seconds]','FontSize',16)
    ylabel('{\Delta}F/F','FontSize',16)
    haxis = gca;
    haxis.FontSize = 16;
    
    %yaxis - same for subplots 223, 224
    MIN1 = min(min(mean(squeeze(sAllResults_PNUM{1,GenderIndex,1}.PNUMTrace_mean(:,:,:)))));
    MIN2 = min(min(mean(squeeze(sAllResults_PNUM{2,GenderIndex,1}.PNUMTrace_mean(:,:,:)))));
    MIN = floor(100*min(MIN1,MIN2))/100;
    MAX1 = max(max(mean(squeeze(sAllResults_PNUM{1,GenderIndex,1}.PNUMTrace_mean(:,:,:)))));
    MAX2 = max(max(mean(squeeze(sAllResults_PNUM{2,GenderIndex,1}.PNUMTrace_mean(:,:,:)))));
    MAX = ceil(100*max(MAX1,MAX2))/100;
    subplot(223), set(gca,'Ylim',[MIN 1.05*MAX])
    axis_handle = gca;
    addlegend(COLORS,PARAM_NAME,Unique_PNUM,axis_handle)
    plot([FrameStartStim FrameStartStim]/FramesPerSecond,[axis_handle.YLim],'--k')
    plot([FrameStartStim FrameStartStim]/FramesPerSecond,[axis_handle.YLim],'--k')
    subplot(224), set(gca,'Ylim',[MIN 1.05*MAX])
    axis_handle = gca;
    addlegend(COLORS,PARAM_NAME,Unique_PNUM,axis_handle)
    plot([FrameStartStim FrameStartStim]/FramesPerSecond,[axis_handle.YLim],'--k')
    
end



%Summary plot for sine/oulse number
hfig = figure(7); clf(hfig), hfig.Color = [1 1 1];
for GenderIndex = 1:2
    Gender = Genders(GenderIndex);
    subplot(2,2,2*GenderIndex-1), hold off
SingleFly_SINE = sAllResults_SINE{1,GenderIndex,1}.mflyresponses_sumDFF;
errorbar(Unique_SINE,mean(SingleFly_SINE),std(SingleFly_SINE)/...
    sqrt(size(SingleFly_SINE,1)),'LineWidth',2,'Color',SingleHoused_Color)
hold on
GroupFly_SINE = sAllResults_SINE{2,GenderIndex,1}.mflyresponses_sumDFF;
errorbar(Unique_SINE,mean(GroupFly_SINE),std(GroupFly_SINE)/...
    sqrt(size(GroupFly_SINE,1)),'LineWidth',2,'Color',GroupHoused_Color)
lgd = legend('Single housed','Group housed');
lgd.EdgeColor = [1 1 1];
box off
xlabel('sine frequency [Hz]','FontSize',16)
ylabel('Integral {\Delta}F/F','FontSize',16)
haxis = gca;
haxis.XTick = Unique_SINE;
haxis.FontSize = 16;
    
    if strcmp(Gender,'M')
        title('Male, Sine frequence tuning')
    else
        title('Female, Sine frequence tuning')
    end
    
end

for GenderIndex = 1:2
    Gender = Genders(GenderIndex);
    subplot(2,2,2*GenderIndex),hold off
    SingleFly_PNUM = sAllResults_PNUM{1,GenderIndex,1}.mflyresponses_sumDFF;
    errorbar(Unique_PNUM,mean(SingleFly_PNUM),std(SingleFly_PNUM)/...
        sqrt(size(SingleFly_PNUM,1)),'LineWidth',2,'Color',SingleHoused_Color)
    hold on
    GroupFly_PNUM = sAllResults_PNUM{2,GenderIndex,1}.mflyresponses_sumDFF;
    errorbar(Unique_PNUM,mean(GroupFly_PNUM),std(GroupFly_PNUM)/...
        sqrt(size(GroupFly_PNUM,1)),'LineWidth',2,'Color',GroupHoused_Color)
    lgd = legend('Single housed','Group housed');
    lgd.EdgeColor = [1 1 1];
    box off
    xlabel('Number of pulses','FontSize',16)
    ylabel('Integral {\Delta}F/F','FontSize',16)
    haxis = gca;
    haxis.XScale = 'log';
    haxis.XTick = Unique_PNUM;
    haxis.FontSize = 16;
    
    %statistics
    S = SingleFly_PNUM(:,3:5); S = reshape(S,[],1);
    G = GroupFly_PNUM(:,3:5); G = reshape(G,[],1);
    [~,P] = ttest2(S,G);
    if GenderIndex == 1%males
        Y = [-0.2 -0.6];
    else%females
        Y = [23 21];
    end
    if strcmp(Gender,'M')
        title('Male, pulse number response')
    else
        title('Female, pulse number response')
    end
end

