%Statistics of fly walk

load('Z:\Dudi\Imaging\2Photon\Dudi_setup\DSX_VR2P_Auditory\mAllData_VR.mat')

%parameters
ballRadius = 6.35;%mm
fps = 60;%frames per second

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


mAllVelocities = zeros(AllFrames,3);
nIndex = 1;
for nLine = 1:size(mAllData,1)
    if nLine == 1
        nFly = 1;
    elseif ~strcmp(mAllData.Folder{nLine},mAllData.Folder{nLine-1})
        nFly = nFly + 1;
    end
    TrackingFrames_OneStimulus = size(mAllData.FicTracSpeed{nLine},1);
    
    mAllVelocities(nIndex:nIndex+TrackingFrames_OneStimulus-1,1) = nFly;
    mAllVelocities(nIndex:nIndex+TrackingFrames_OneStimulus-1,2:4) = mAllData.FicTracSpeed{nLine}(:,2:4);
    nIndex = nIndex + TrackingFrames_OneStimulus;
end


%%figures
%figure(1) - velocities - all flies
h = figure(1);
for Axis = 1:3
    hfig = subplot(3,2,2*Axis-1);
    VEL = mAllVelocities(:,Axis + 1);
    
    switch Axis
        case 1%rotational speed
            AXIS = 'fRS';
            VEL = VEL*(180/pi);
            MIN = prctile(VEL,0.5); MAX = prctile(VEL,99.5); delta = (MAX - MIN)/100;
            hist(VEL,MIN:delta:MAX);          
            xlabel('Velocity [deg/sec]')
        case 2
            AXIS = 'fFV';%forward velocity
            VEL = VEL*ballRadius*fps;%pixel/frame * mm/pixel * frame/second = mm/second;
            MIN = prctile(VEL,0.5); MAX = prctile(VEL,99.5); delta = (MAX - MIN)/100;
            hist(VEL,MIN:delta:MAX);
            xlabel('Velocity [mm/sec]')
        case 3
            AXIS = 'fLS';%lateral speed
            VEL = VEL*ballRadius*fps;%pixel/frame * mm/pixel * frame/second = mm/second;
            MIN = prctile(VEL,0.5); MAX = prctile(VEL,99.5); delta = (MAX - MIN)/100;
            hist(VEL,MIN:delta:MAX);
            xlabel('Velocity [mm/sec]')
    end
    
    LIM = min(abs(prctile(VEL,1)),prctile(VEL,99));
    xlim([-LIM LIM]);
    title([AXIS,' - all flies'])
    ylabel('#frames')
    set(gca,'FontSize',16)
    h.Color = 'w';
    box off
    %add text - mean/std
    htext1 = text(hfig.XLim(1) + 0.08*(hfig.XLim(2)-hfig.XLim(1)), 0.82*hfig.YLim(2),...
        ['mean abs vel = ',num2str(round(mean(abs(VEL)),2))]);
    htext2 = text(hfig.XLim(1) + 0.08*(hfig.XLim(2)-hfig.XLim(1)), 0.7*hfig.YLim(2),...
        ['mean/std = ',num2str(round(mean(VEL)/std(VEL)*1000)),' *10^{-3}']);
    htext1.FontSize = 16; htext2.FontSize = 16;
end

%figure(2) - velocities of single flies
h = figure(2);
for Axis = 1:3
    hfig = subplot(3,2,2*Axis-1); hold off
    V_mean = zeros(1,size(AllFlies.Folder,2));
    V_std = zeros(1,size(AllFlies.Folder,2));
    for nFly = 1:size(AllFlies.Folder,2)
        V_mean(nFly) = mean(mAllVelocities(mAllVelocities(:,1)==nFly,Axis+1));
        V_std(nFly) = std(mAllVelocities(mAllVelocities(:,1)==nFly,Axis+1));
    end
    
    switch Axis
        case 1%rotational speed
            AXIS = 'fRS';
            V_mean = V_mean*(180/pi); V_std = V_std*(180/pi);
            errorbar(1:length(V_mean),V_mean,V_std,'LineStyle','none','LineWidth',2),hold on
            plot([0 length(V_mean)+1],[0 0],':k')
            ylabel('Velocity [deg/sec]')
        case 2
            AXIS = 'fFV';%forward velocity
            V_mean = V_mean*ballRadius*fps;%pixel/frame * mm/pixel * frame/second = mm/second;
            V_std = V_std*(180/pi);
            errorbar(1:length(V_mean),V_mean,V_std,'LineStyle','none','LineWidth',2),hold on
            plot([0 length(V_mean)+1],[0 0],':k')
            ylabel('Velocity [mm/sec]')
        case 3
            AXIS = 'fLS';%lateral speed
            V_mean = V_mean*ballRadius*fps;%pixel/frame * mm/pixel * frame/second = mm/second;
            V_std = V_std*(180/pi);
            errorbar(1:length(V_mean),V_mean,V_std,'LineStyle','none','LineWidth',2),hold on
            plot([0 length(V_mean)+1],[0 0],':k')
            ylabel('Velocity [mm/sec]')
    end
    title([AXIS,' - all flies'])
    h.Color = 'w';
    box off
    xlabel('Fly number')
end
%figure(3) - velocities over time
h = figure(3);
hold off
for Axis = 1:3
   VEL = abs(mAllVelocities(:,Axis + 1));
   Vel_firstHalf = zeros(round(length(VEL)/2),1);
   nIndex_firstHalf = 1;
   Vel_secondHalf = zeros(length(VEL)-length(Vel_firstHalf),1);
   nIndex_secondHalf = 1;
   for nFly = 1:size(AllFlies.Folder,2)
       Vel_oneFly = VEL(mAllVelocities(:,1)==nFly);
       
       temp = Vel_oneFly(1:round(length(Vel_oneFly)/2));
       Vel_firstHalf(nIndex_firstHalf:nIndex_firstHalf+length(temp)-1) = temp;
       nIndex_firstHalf = nIndex_firstHalf + length(temp);
       
       temp = Vel_oneFly(round(length(Vel_oneFly)/2)+1:end);
       Vel_secondHalf(nIndex_secondHalf:nIndex_secondHalf+length(temp)-1) = temp;
       nIndex_secondHalf = nIndex_secondHalf + length(temp);
   end
   %bar(3*Axis-2,mean(Vel_firstHalf))
   errorbar(3*Axis-2,mean(Vel_firstHalf),std(Vel_firstHalf),'-sb','LineStyle','non','MarkerSize',10,...
    'MarkerEdgeColor','red','MarkerFaceColor','red'),hold on
   
   %bar(3*Axis-1,mean(Vel_secondHalf))
   errorbar(3*Axis-1,mean(Vel_secondHalf),std(Vel_secondHalf),'-sk','LineStyle','non','MarkerSize',10,...
    'MarkerEdgeColor','red','MarkerFaceColor','red')
   
end

