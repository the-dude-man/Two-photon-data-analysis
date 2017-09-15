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
clear PULSEtrain  PULSEtrain_Housed  PULSEtrain_Gender DFF_max_PULSEtrain DFF_sum_PULSEtrain DFF_max_PULSEtrain_Norm DFF_sum_PULSEtrain_Norm

%traces
clear mDFF_IPITrace mDFF_IPI_NormTrace


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
end

%remove zeros from Traces
mDFF_IPITrace = removezeros(mDFF_IPITrace);
mDFF_IPI_NormTrace = removezeros(mDFF_IPI_NormTrace);


%%now building a single matrix per stimulus type
sAllResults_IPI = cell(2,2,2);

Housing = 'SG';%S - single housed, G = group housed
for HousedIndex = 1:2
    Housed = Housing(HousedIndex);
    Genders = 'MF';%M - male, F - female
    for GenderIndex = 1:2
        Gender = Genders(GenderIndex);
        Normalization = [0 1];
        for NormIndex = 1:2
            Normalize = Normalization(NormIndex);
            %IPI - mean
            %number of flies, number of stimuli:
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
            %...
            %pulse number
            %...
            
        end
    end
end

cd(CurrDir)


%% figures
SingleHoused_Color = [0 0 0];
GroupHoused_Color = [1 0 0];

Genders = 'MF';%M - male, F - female
for GenderIndex = 1:2
    Gender = Genders(GenderIndex);
    %IPI
    hfig = figure(GenderIndex);%IPI tuning
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

