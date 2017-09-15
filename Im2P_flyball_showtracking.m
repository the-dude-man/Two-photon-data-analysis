
%files
VideoFile = 'Z:\Dudi\Imaging\2Photon\Dudi_setup\DSX_VR2P_Auditory\20170511\20170511_102\170511_102.avi';
TrackingFile = [VideoFile(1:end-3) 'dat'];
debugvideofile = [VideoFile(1:end-4) '-debug.avi'];


%flags
ShowSpeed = 0;%if =0, show trajectory, not speed

%Parameters
nStart = 19750;nEnd = nStart+1000;
nIgnorefirstFrames = 0;%35;%for whatever reason the first 25 frames in vr (defined below) are just 'frame 1' freezed.
nShowWindow = 300;
nSlideWindow = 2;
XTickSteps = 20;
nDelayBetweenImages = 0;%seconds

%BallDiameter = 25.4/2;%in mm
%fps = 30;%framrs per second


%read video and tracking file
vr = VideoReaderFFMPEG(debugvideofile);
Tr = load(TrackingFile);

%Show trajectory or speed

X = movmean(Tr(:,2),nSlideWindow);
Y = movmean(Tr(:,3),nSlideWindow);
Z = movmean(Tr(:,4),nSlideWindow);
if ShowSpeed == 1
X = diff(X);
Y = diff(Y);
Z = diff(Z);
end

%find jumps in tracking
Jumps = find(diff(Tr(:,23))<0);

%show video and tracking files
h = figure(2);clf
h.Color = 'w';
nHalfWindow = round(nShowWindow/2);
vFrames = Tr(:,1);

for nIndex = nStart:nEnd%this is the index number in Tr. If there are no missing frames in the tracking than it is also the frmame number
    %but in the more general case, nFrame = Tr(nIndex,1)
    nFrame = Tr(nIndex,1);
    nStartWindow = max(1,nFrame-nHalfWindow); nEndWindow = min(nFrame+nHalfWindow,length(X));
    JumpsInWindow = Jumps(Jumps>=nStartWindow & Jumps<=nEndWindow);
    
    subplot(121),hold off
    plot(vFrames,X), hold on
    plot(vFrames,Y)
    plot(vFrames,Z)
    ax = gca;
    ax.XLim = [nStartWindow nEndWindow];
    plot([nFrame nFrame],ax.YLim,':m','LineWidth',2)
    legend('X','Y','Z','current frame')
    xlabel('Frame number in debug.avi')
    
    
    %ax.XTick = 1:XTickSteps:nEndWindow-nStartWindow+1;
    %ax.XTickLabel = nStartWindow:XTickSteps:nEndWindow;
    
    
    if ~isempty(JumpsInWindow)
        plot(JumpsInWindow-(nFrame-nHalfWindow)+1,0,'dm','MarkerSize',16)
    end
    
    
    
    subplot(122),hold off
    FRAME = read(vr,nFrame+nIgnorefirstFrames);
    imshow(FRAME),axis equal, hold on
    %add arrow
    DX = X(nFrame)-X(nFrame-1);
    DY = Y(nFrame)-Y(nFrame-1);
    p1 = [512 467];                         % First Point
    p2 = [p1(1)-10^4*DY p1(2)+10^4*DX];                         % Second Point
    dp = p2-p1;                         % Difference
    %quiver(p1(1),p1(2),dp(1),dp(2),0,'LineWidth',3)
    
    
    title(num2str(nFrame))
    %pause(nDelayBetweenImages)
    pause
end