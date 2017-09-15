%Missing: Normalization of FinROI and of speed per fly.

load('Z:\Dudi\Imaging\2Photon\Dudi_setup\DSX_VR2P_Auditory\mAllData_VR_New.mat')


%control parameter
binary = 0;%binarize the prediction or not
bNormalizePerFly = 1;
ABS = 1;
SaveToFolder = 'C:\Users\Dudi\Dropbox\My Documents\PostDoc\Post doc- Research\Experiments\ImagingOnBall\';
%parameters to use for GLM
ITER = 10;
width = 48;
%frames per second in the movie (and in FicTrac output)
fps = 60;



%list of fly indexes (not the most compact code here, but anyhow..)
AllFlies = struct('Folder',[]);
AllFlies.Folder{1} = mAllData.Folder{1};
nFly = 2;
AllFrames = 0;
for nLine = 2:size(mAllData,1)
    if ~strcmp(mAllData.Folder{nLine},mAllData.Folder{nLine-1})
        AllFlies.Folder{nFly} = mAllData.Folder{nLine};
        nFly = nFly + 1;
    end
    AllFrames = AllFrames + size(mAllData.FicTracSpeed{nLine},1);
end

vFlies = zeros(1,size(mAllData,1));
nIndex = 1;
for nLine = 1:size(mAllData,1)
    if nLine == 1
        nFly = 1;
    elseif ~strcmp(mAllData.Folder{nLine},mAllData.Folder{nLine-1})
        nFly = nFly + 1;
    end
    
    vFlies(nLine) = nFly;
end


for After = [0 1 2]
    bHoldOn = 0;
    for Axis = 2:4%2/3/4 for X/Y/Z = fRS/fFV/fLS
        
        if Axis == 2
            COLOR = [0,0,1];
        elseif Axis == 3
            COLOR = [0,0,0];
        elseif Axis == 4
            COLOR = [0,1,0];
        end
        
        Allfilts = zeros(ITER,width);
        AllPredictors = zeros(ITER,1);
        
        for itteration = 1:ITER
            disp(itteration)
            %memory allocation
            SSraw = zeros(size(mAllData,1),width);
            y = zeros(size(mAllData,1),1);
            
            Sbefore = zeros(1,size(mAllData,1));
            Safter = zeros(1,size(mAllData,1));
            
            for nLine = 1:size(mAllData,1)
                SmoothFinROI =  movmean(mAllData.GreenSignal_FinROI{nLine},7);
                DeltaFinROI = SmoothFinROI - mean(SmoothFinROI(1:200));
                
                if ABS == 1
                    FicTracSpeed = abs(mAllData.FicTracSpeed{nLine}(:,Axis));
                else
                    FicTracSpeed = mAllData.FicTracSpeed{nLine}(:,Axis);
                end
                
                %for GLM
                if After == 0
                    SSraw(nLine,1:width) = FicTracSpeed(300-width:300-1);
                elseif After == 1
                    SSraw(nLine,1:width) = FicTracSpeed(301:300+width);
                elseif After == 2
                    SSraw(nLine,1:2*width) = FicTracSpeed(300-(width):300+(width)-1);
                end
                y(nLine,1) = max(DeltaFinROI);
            end
            
            
            if bNormalizePerFly == 1
                for nFly = unique(vFlies)
                    y(vFlies==nFly) = y(vFlies==nFly)/max(y(vFlies==nFly));
                end
            end
            
            %is binarry == 1, make the response vector binary
            if binary == 1, y = y>median(y); end
            %
            
            disp(['Size of SSraw is ',num2str(size(SSraw,1)),'*',num2str(size(SSraw,2)),', size of y is ',num2str(size(y,1)),'*',num2str(size(y,2))])
            
            disp('Fitting GLM...')
            [filt,binPred,relDevRed] = DudiGLM(SSraw,y);
            disp('Done')
            
            Allfilts(itteration,1:length(filt)) = filt./norm(filt);
            %AllPredictors(itteration,1) = mean(y==binPred);
            AllPredictors(itteration,1) = relDevRed;
        end
        
        %% plot results
        
        meanFilt = mean(Allfilts);
        hfig = figure(1);
        
        
        h_splot = subplot(3,1,After+1);
        if bHoldOn == 0
            hold off
        end
        %Color - 1=red, 2=blue, 3=black, 4=green, 5=grey, 6=purple
        if After == 0          
            My_errorbar(-(1:width)*(1000/fps),mean(Allfilts),std(Allfilts),Axis)
            hold on, legend off
            plot(-(1:width)*(1000/fps),mean(Allfilts),'Color',COLOR,'LineWidth',2)
        elseif After == 1
            My_errorbar((1:width)*(1000/fps),mean(Allfilts),std(Allfilts),Axis)
            hold on, legend off
            plot((1:width)*(1000/fps),mean(Allfilts),'Color',COLOR,'LineWidth',2)
        elseif After == 2
            My_errorbar((-width:width-1)*(1000/fps),mean(Allfilts),std(Allfilts),Axis)
            hold on, legend off
            plot((-(width):(width)-1)*(1000/fps),mean(Allfilts),'Color',COLOR,'LineWidth',2)
        end
        axis tight
        
        if bHoldOn ==0
            X1 = h_splot.XLim(1) + 0.1*(diff(h_splot.XLim));
            %X2 = X1 + 0.06*(diff(h_splot.XLim));
            Y1 = h_splot.YLim(1) + 0.8*(diff(h_splot.YLim)) ;
            delta = diff(h_splot.YLim);
        end
        Y2 = Y1 - delta/10*Axis;
        bHoldOn = 1;
        if Axis == 2
            text(X1,Y2,['|RS|',',RelDevRad = ',num2str(round(mean(AllPredictors),2))],'Color',COLOR,'FontSize',16)
        elseif Axis == 3
            text(X1,Y2,['|FV|',',RelDevRad = ',num2str(round(mean(AllPredictors),2))],'Color',COLOR,'FontSize',16)
        elseif Axis == 4
            text(X1,Y2,['|LS|',',RelDevRad = ',num2str(round(mean(AllPredictors),2))],'Color',COLOR,'FontSize',16)
        end
        legend off
        
        if After == 1, xlabel('Time after stim onset[ms]')
        elseif After == 0, xlabel('Time before stim onset[ms]')
        end
        if After == 1 && ABS
            TITLE = '2PVR-GLM-absSpeedAfter';
        elseif After == 1&& ~ABS
            TITLE = '2PVR-GLM-SpeedAfter';
        elseif After == 0 && ABS
            TITLE = '2PVR-GLM-absSpeedBefore';
        elseif After == 0 && ~ABS
            TITLE = '2PVR-GLM-SpeedBefore';        
        elseif After == 2 && ABS
            TITLE = '2PVR-GLM-absSpeedBeforeAfter';
        elseif After == 2 && ~ABS
            TITLE = '2PVR-GLM-SpeedBeforeAfter';
        end
        
        box off
        
        title(TITLE)
        hfig.Color = 'w';
        set(gca,'FontSize',16)
                
        
        if Axis == 2 && After
            figname = '2PVR_GLM_fRS_After';
        elseif Axis == 2 && ~After
            figname = '2PVR_GLM_fRS_Before';
        elseif Axis == 3 && After
            figname = '2PVR_GLM_fFV_After';
        elseif Axis == 3 && ~After
            figname = '2PVR_GLM_fFV_Before';
        elseif Axis == 4 && After
            figname = '2PVR_GLM_fLS_After';
        elseif Axis == 4 && ~After
            figname = '2PVR_GLM_fLS_Before';
        end
        
        filename = [SaveToFolder,figname,'.fig'];
        savefig(hfig,filename)
        SaveTo = [SaveToFolder,figname];
        save2pdf(SaveTo,hfig,2400)
        
    end
end



