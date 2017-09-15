
%This script shows the correlation between the calcium response and the fly mean speed in X/Y/Z over different windows after stim on

load('Z:\Dudi\Imaging\2Photon\Dudi_setup\DSX_VR2P_Auditory\mAllData_VR.mat')

%control parameter
Axis = 4;%2/3/4 for X/Y/Z (RS, FV, LS)
vWindow = 2:52;%in units of frames, where one frame is (1000/60)ms
bNormalizePerFly = 1;%Normalize the calcium response to the max response per fly
SaveToFolder = 'C:\Users\Dudi\Dropbox\My Documents\PostDoc\Post doc- Research\Group meetings\06302017 - Dudi 9th data presentation\';

figure(1)


%Find the max response for each fly
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


%% calculate correlations
for After = 0:1%if After = 0, looks before the stimulus, is After = 1, looks after.
    for ABS = 0:1%if ABS = 1, looking at the absolute speed, if ABS = 0, not
        
        PP = zeros(1,length(vWindow));
        RR = zeros(1,length(vWindow));
        for ii = 1:length(vWindow)
            disp([num2str(ii),' out of ',num2str(length(vWindow)),' windows.'])
            
            MAXResponse = zeros(1,size(mAllData,1)); Sbefore = zeros(1,size(mAllData,1)); Safter = zeros(1,size(mAllData,1));
            
            for nLine = 1:size(mAllData,1)
                SmoothFinROI =  movmean(mAllData.GreenSignal_FinROI{nLine},7);
                DeltaFinROI = SmoothFinROI - mean(SmoothFinROI(1:200));
                MAXResponse(nLine) = max(DeltaFinROI);
                
                if ABS == 1
                    FicTracSpeed = abs(mAllData.FicTracSpeed{nLine}(:,Axis));
                else
                    FicTracSpeed = mAllData.FicTracSpeed{nLine}(:,Axis);
                end
                Sbefore(nLine) = mean(FicTracSpeed(300-vWindow(ii):300-1));
                Safter(nLine) = mean(FicTracSpeed(301:301+vWindow(ii)));% - mean(Y(240:300));
                
            end
            
            if bNormalizePerFly == 1
              for nFly = unique(vFlies)
               MAXResponse(vFlies==nFly) = MAXResponse(vFlies==nFly)/max(MAXResponse(vFlies==nFly));    
              end
            end
            
            if After == 1
                [R, P] = corrcoef(Safter,MAXResponse);
            elseif After == 0
                [R, P] = corrcoef(Sbefore,MAXResponse);
            end
            PP(ii) = P(1,2);
            RR(ii) = R(1,2);
            
        end
        
        
        hfig = figure(1);
        subplot(2,2,2*ABS+After+1),hold off
        X = vWindow*1000/60;
        if After == 0, X = -X; end
        plot(X,PP,'LineWidth',2), hold on
        if ~After
            xlabel('Time before stim on [ms]')
        else
            xlabel('Time after stim on [ms]')
        end
        
        ylabel('P-value')
        
        if Axis == 2 && ABS == 1
            title(['|fRS|, ', 'best R = ',num2str(RR(PP == min(PP)))])
        elseif Axis == 3  && ABS == 1
            title(['|fFV|, ', 'best R = ',num2str(RR(PP == min(PP)))])
        elseif Axis == 4  && ABS == 1
            title(['|fLS|, ', 'best R = ',num2str(RR(PP == min(PP)))])
        elseif Axis == 2 && ABS == 0
            title(['fRS, ', 'best R = ',num2str(RR(PP == min(PP)))])
        elseif Axis == 3  && ABS == 0
            title(['fFV, ', 'best R = ',num2str(RR(PP == min(PP)))])
        elseif Axis == 4  && ABS == 0
            title(['fLS, ', 'best R = ',num2str(round(RR(PP == min(PP)),2))])
        end
        
        if ~bNormalizePerFly
        ylim([0 1])
        yticks(0:0.2:1)
        end
        if After == 1
            plot([0 1000],[0.05 0.05],':k')
        else
            plot([-1000 0],[0.05 0.05],':k')
        end
        box off
        hfig.Color = [1 1 1];
        set(gca,'FontSize',16)
        if After == 1
            xticks(0:200:max(X))
        else
            xticks(-1000:200:max(X))
        end
        
        if Axis == 2
            figname = '2PVR_Correlation_fRS';
        elseif Axis == 3
            figname = '2PVR_Correlation_fFV';
        elseif Axis == 4
            figname = '2PVR_Correlation_fLS';
        end
    end
end

filename = [SaveToFolder,figname,'.fig'];
savefig(hfig,filename)
SaveTo = [SaveToFolder,figname];
save2pdf(SaveTo,hfig,2400)


