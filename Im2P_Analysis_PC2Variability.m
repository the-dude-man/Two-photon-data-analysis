
datafile = 'Z:\Dudi\Imaging\2Photon\Diego_setup\Alldata_Playback.mat';
IsRedo_mOneROIData = 1;
nOnlyFirstSet = 1;
%ROIname = 'Ring';
ROIname = 'PC2Cell';


%%find sessions with pC2
if ~exist('mOneROIData','var') || IsRedo_mOneROIData
    load(datafile)
    mOneROIData = cell2table(cell(1,10),'VariableNames',...
        {'StimName', 'Fly', 'Folder', 'StimNumber','GreenSignal_FinROI','GreenSignal_DFFinROI','GreenSignal_MaxDFF',...
        'GreenSignal_SumDFF','MaxDFFAllStim','MaxSumDFFAllStim'});
    nIndex = 1;
    nFly = 1;
    for nLine = 1:size(mAllData,1)
        if ~strcmp(mAllData.ROIname(nLine),ROIname) || ~strcmp(mAllData.Gender(nLine),'F') ||...
                ~(mAllData.Intensity{nLine}(1)==4) || ...
                ~isempty(strfind(mAllData.Folder{nLine},'Context')) || (mAllData.StimNumber{nLine}>35 && nOnlyFirstSet)
            continue
        end %only female, ROIname, first 35 trials, intensity = 4
        if nIndex > 1 && ~strcmp(mAllData.Folder{nLine,1},mOneROIData.Folder{nIndex-1,1}), nFly = nFly +1; end
        mOneROIData.StimName{nIndex,1} = mAllData.StimName{nLine};
        mOneROIData.Fly{nIndex,1} = nFly;
        mOneROIData.Folder{nIndex,1} = mAllData.Folder{nLine};
        mOneROIData.StimNumber{nIndex,1} = mAllData.StimNumber{nLine};
        mOneROIData.GreenSignal_FinROI{nIndex,1} = mAllData.GreenSignal_FinROI{nLine};
        mOneROIData.GreenSignal_DFFinROI{nIndex,1} = mAllData.GreenSignal_DFFinROI{nLine};
        mOneROIData.GreenSignal_MaxDFF{nIndex,1} = mAllData.GreenSignal_MaxDFF{nLine};
        mOneROIData.GreenSignal_SumDFF{nIndex,1} = mAllData.GreenSignal_SumDFF{nLine};
        mOneROIData.MaxDFFAllStim{nIndex,1} = mAllData.MaxDFFAllStim{nLine};
        mOneROIData.MaxSumDFFAllStim{nIndex,1} = mAllData.MaxSumDFFAllStim{nLine};
        nIndex = nIndex + 1;
    end
end

%%List the responses from high to low
AllStim = unique(mOneROIData.StimName);

AllResponses = struct('Norm_DFF',[],'Norm_SumDFF',[]);
for StimNum = 1:size(AllStim,1)
    AllResponses(StimNum).Norm_DFF = [];
    AllResponses(StimNum).Norm_SumDFF = [];
end
for nLine = 1:size(mOneROIData,1)
    StimName  = mOneROIData.StimName{nLine,1};
    StimNum = find(strcmp(AllStim,StimName));%StimNum is the index to the stimulus in AllStim, so later I1,I2 are the indexes of stimuli in AllStim
    AllResponses(StimNum).Norm_DFF =...
        [AllResponses(StimNum).Norm_DFF mOneROIData.GreenSignal_MaxDFF{nLine}/mOneROIData.MaxDFFAllStim{nLine}];
    AllResponses(StimNum).Norm_SumDFF =...
        [AllResponses(StimNum).Norm_SumDFF mOneROIData.GreenSignal_SumDFF{nLine}/mOneROIData.MaxSumDFFAllStim{nLine}];
end

vMaxDFF = zeros(1,size(AllStim,1)); vMaxSumDFF = zeros(1,size(AllStim,1));
for StimNum = 1:size(AllStim,1)
    vMaxDFF(StimNum) = mean(AllResponses(StimNum).Norm_DFF);
    vMaxSumDFF(StimNum) = mean(AllResponses(StimNum).Norm_SumDFF);
end

[S1,I1] = sort(vMaxDFF,'descend');
[S2,I2] = sort(vMaxSumDFF,'descend');


%%
figure(1),clf; figure(2),clf
for nFlyNumber = 1:mOneROIData.Fly{end}
    
    AllResponses = struct('Norm_DFF',[],'Norm_SumDFF',[]);
    for StimNum = 1:size(AllStim,1)
        AllResponses(StimNum).Norm_DFF = [];
        AllResponses(StimNum).Norm_SumDFF = [];
    end
    for nLine = 1:size(mOneROIData,1)
        if ~(mOneROIData.Fly{nLine,1} == nFlyNumber), continue,end
        StimName  = mOneROIData.StimName{nLine,1};
        StimNum = find(strcmp(AllStim,StimName));
        AllResponses(StimNum).Norm_DFF =...
            [AllResponses(StimNum).Norm_DFF mOneROIData.GreenSignal_MaxDFF{nLine}/mOneROIData.MaxDFFAllStim{nLine}];
        AllResponses(StimNum).Norm_SumDFF =...
            [AllResponses(StimNum).Norm_SumDFF mOneROIData.GreenSignal_SumDFF{nLine}/mOneROIData.MaxSumDFFAllStim{nLine}];
    end
    
    figure(1)
    subplot(3,4,nFlyNumber),hold off
    for ii = 1:length(I1)
        StimNum = I1(ii);
        for jj = 1:size(AllResponses(StimNum).Norm_DFF,2)
            plot(ii,AllResponses(StimNum).Norm_DFF(jj),'ko'),hold on
        end
        M = mean(AllResponses(StimNum).Norm_DFF);
        S = std(AllResponses(StimNum).Norm_DFF);
        %plot([ii ii],[M-S M+S],'r-','LineWidth',3), hold on
    end
    title(['Fly ',num2str(nFlyNumber)])
    ylabel('Norm peak \deltaF/F')
    ylim([0 1])
    
    figure(2)
    subplot(3,4,nFlyNumber),hold off
    for ii = 1:length(I2)
        StimNum = I2(ii);
        for jj = 1:size(AllResponses(StimNum).Norm_SumDFF,2)
            plot(ii,AllResponses(StimNum).Norm_SumDFF(jj),'ko'),hold on
        end
        M = mean(AllResponses(StimNum).Norm_SumDFF);
        S = std(AllResponses(StimNum).Norm_SumDFF);
        %plot([ii ii],[M-S M+S],'r-','LineWidth',3), hold on
    end
    title(['Fly ',num2str(nFlyNumber)])
    ylabel('Norm sum \deltaF/F')
    ylim([0 1])
end


%all flies together
%Selected = I1([2 8 10 14 18 26 27 28]);
Selected = I1([2 12 22 28]);
%Selected = I1;
figure(3),clf

AllResponses = struct('Norm_DFF',[],'Norm_SumDFF',[]);
for StimNum = 1:size(AllStim,1)
    AllResponses(StimNum).Norm_DFF = [];
    AllResponses(StimNum).Norm_SumDFF = [];
end
for nLine = 1:size(mOneROIData,1)
    StimName  = mOneROIData.StimName{nLine,1};
    StimNum = find(strcmp(AllStim,StimName));
    AllResponses(StimNum).Norm_DFF =...
        [AllResponses(StimNum).Norm_DFF mOneROIData.GreenSignal_MaxDFF{nLine}/mOneROIData.MaxDFFAllStim{nLine}];
    AllResponses(StimNum).Norm_SumDFF =...
        [AllResponses(StimNum).Norm_SumDFF mOneROIData.GreenSignal_SumDFF{nLine}/mOneROIData.MaxSumDFFAllStim{nLine}];
end

figure(3), subplot(121),hold off
for ii = 1:length(Selected)
    StimNum = Selected(ii);
    for jj = 1:size(AllResponses(StimNum).Norm_DFF,2)
        plot(ii,AllResponses(StimNum).Norm_DFF(jj),'ko'),hold on
    end
    M = mean(AllResponses(StimNum).Norm_DFF);
    S = std(AllResponses(StimNum).Norm_DFF)/sqrt(length(AllResponses(StimNum).Norm_DFF));
    h = plot(ii,M,'rd','MarkerSize',12);
    h.MarkerFaceColor = [1 0 0];
    plot([ii ii],[M-S M+S],'r-','LineWidth',3), hold on
end
title(['Variability between cells, ','Peak \deltaF/F'])
ylabel('Peak \deltaF/F')
ylim([0 1])

figure(3), subplot(122),hold off
for ii = 1:length(Selected)
    StimNum = Selected(ii);
    for jj = 1:size(AllResponses(StimNum).Norm_SumDFF,2)
        plot(ii,AllResponses(StimNum).Norm_SumDFF(jj),'ko'),hold on
    end
    M = mean(AllResponses(StimNum).Norm_SumDFF);
    S = std(AllResponses(StimNum).Norm_SumDFF)/sqrt(length(AllResponses(StimNum).Norm_SumDFF));
    h = plot(ii,M,'rd','MarkerSize',12);
    h.MarkerFaceColor = [1 0 0];
    plot([ii ii],[M-S M+S],'r-','LineWidth',3), hold on
end
title(['Variability between cells, ','Sum \deltaF/F'])
ylabel('Sum \deltaF/F')
ylim([0 1])

%% variability between cells - R^2 between normalized traces of pairs of cells in the same fly
if ~strcmp(ROIname,'PC2Cell'), return, end
vFlies = unique(cell2mat(mOneROIData.Fly(:)));
mTraces = struct('Folder',[],'StimName',[],'mResponseAllCells',[],'mCorr',[],'vCorr',[],'vNormPeakResponse',[]);
for nFly = vFlies'
    mOneFly = mOneROIData(cell2mat(mOneROIData.Fly(:))==nFly,:);
    vAllStim = cell2mat(mOneFly.StimNumber(:));
    vStimNumber = unique(vAllStim);
    if mod(length(cell2mat(mOneFly.StimNumber(:))),length(vStimNumber))~=0
        disp('Number of stimuli is not the same for each cell - must be some mistake.')
        return
    end
    nCells = length(cell2mat(mOneFly.StimNumber(:)))/length(vStimNumber);
    sFlyTraces = zeros(nCells,nIndex);
    for nStim = vStimNumber'
        nSameStimDifferentCells = find(vAllStim == nStim);
        if ~(length(nSameStimDifferentCells) == nCells),disp('Number of repeats doesnt match number of cells'),return,end
        for nCell = 1:nCells
            nLine = nSameStimDifferentCells(nCell);
            mTraces(nFly,nStim).Folder = mOneFly.Folder{nLine};
            mTraces(nFly,nStim).StimName = mOneFly.StimName{nLine};
            mTraces(nFly,nStim).mResponseAllCells(nCell,1:length(mOneFly.GreenSignal_DFFinROI{nLine})) =...
                mOneFly.GreenSignal_DFFinROI{nLine}/mOneFly.MaxDFFAllStim{nLine};%Response is normalized to the max response over all stim for a given cell
            mTraces(nFly,nStim).vNormPeakResponse(nCell) =...
                mOneFly.GreenSignal_MaxDFF{nLine}/mOneFly.MaxDFFAllStim{nLine};
        end
    end
end

% add correlation between pairs of cells
for nFly = 1:size(mTraces,1)
    for nSelectedStim = 1:size(AllStim,1)
        sSelectedStim = AllStim{nSelectedStim};
        for nStim = 1:size(mTraces,2)
            if strcmp(mTraces(nFly,nStim).StimName,sSelectedStim),break,end
        end
        MCORR = corrcoef(mTraces(nFly,nStim).mResponseAllCells');
        mTraces(nFly,nStim).mCorr = MCORR;
        V = zeros(1,sum(1:size(MCORR,1)-1));
        nIndex = 1;
        for nLine = 1:size(MCORR,1)-1
            V(nIndex:nIndex+size(MCORR,2)-nLine - 1) = MCORR(nLine,nLine+1:size(MCORR,2));
            nIndex = nIndex + size(MCORR,2)-nLine;
        end
        mTraces(nFly,nStim).vCorr = V;%simply putting all the correlations between pairs in one row
        %now, for the selected stim - make example figures, including
        %correlation. Than sum correlations
        %ToMala: example movie - different cells. Example trajectories (same
        %movie) and statistics (for the selected stimuli).
    end
end


mCorrOneStim = struct('corr',[]);
for nSelectedStim = I1 %order from largest to smallest peak response
    nIndex = 1;
    sSelectedStim = AllStim{nSelectedStim};
    for nFly = 1:size(mTraces,1)
        for nStim = 1:size(mTraces,2)
            if strcmp(mTraces(nFly,nStim).StimName,sSelectedStim),break,end
        end
        
        %temporary exclude a fly with a lot of motion (in the future need to remove this recording alltogether)
        if strcmp(mTraces(nFly,nStim).Folder,'Z:\Dudi\Imaging\2Photon\Diego_setup\DSX_2P_Playback\20161221\20161221_105'), continue,end%motion
        if strcmp(mTraces(nFly,nStim).Folder,'Z:\Dudi\Imaging\2Photon\Diego_setup\DSX_2P_Playback\20170110\20170110_204'), continue,end%motion
        
        %If ANY cell has a clear response - look at the correlation between the cells 
        if max(max(mTraces(nFly,nStim).mResponseAllCells,[],2)) < 0.5, continue, end
        
        mCorrOneStim(nSelectedStim).corr(nIndex:nIndex+length(mTraces(nFly,nStim).vCorr)-1) = mTraces(nFly,nStim).vCorr;
        %temp
        if mean(mTraces(nFly,nStim).vCorr) < 0.85
            disp([num2str(mean(mTraces(nFly,nStim).vCorr)) ,',Folder: ',mTraces(nFly,nStim).Folder])
            disp(sSelectedStim)
        end
        %temp
        nIndex = nIndex + length(mTraces(nFly,nStim).vCorr);
    end
end

%plot
figure(4),clf
nLastIndex = 8;
for nIndex = 1:nLastIndex
    nSelectedStim = I1(nIndex);
    L = length(mCorrOneStim(nSelectedStim).corr);
    x = nIndex + 0.1*rand(1,L);
    y = mCorrOneStim(nSelectedStim).corr.^2;
    plot(x,y,'.','MarkerSize',10), hold on
    ylim([0 1.05]), xlim([0.5 nLastIndex+0.5])
    title('Pairwise correlation of Calcium response in pC2 cells')
    ylabel('R^{2}'), xlabel('Stimulus number [ordered by mean response amplitude]')
    box off
    h = gca;
    h.XTick = 1:nLastIndex;
    h.YTick = 0:0.2:1;
    h.FontSize = 16;
    hf = gcf;
    hf.Color = 'white';
end


