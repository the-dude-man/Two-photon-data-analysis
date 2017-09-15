
%Missing: Normalization of FinROI and of speed per fly.
load('Z:\Dudi\Imaging\2Photon\Dudi_setup\DSX_VR2P_Auditory\mAllData_VR.mat')

Axis = 2;%2-X, 3-Y, 4-Z

figure(1)

L = inf;
FF = zeros(1,size(mAllData,1));
for nLine = 1:size(mAllData,1)
    L = min(L,length(mAllData.FicTracSpeed{nLine}(:,2)));
    SmoothFinROI =  movmean(mAllData.GreenSignal_FinROI{nLine},11);
    DeltaFinROI = SmoothFinROI - mean(SmoothFinROI(1:200));
    FF(nLine) = max(DeltaFinROI);
end


MAXResponse = zeros(1,size(mAllData,1)); Sbefore = zeros(1,size(mAllData,1)); Safter = zeros(1,size(mAllData,1));
for nLine = 1:size(mAllData,1)
    %Stim
    subplot(311),hold off
    plot(mAllData.Stim{nLine}),axis tight
    title('Stimulus')
    box off
    xlabel('Sample(10KHz)')
    %FinROI (green channel)
    subplot(312),hold off
    SmoothFinROI =  movmean(mAllData.GreenSignal_FinROI{nLine},7);
    DeltaFinROI = SmoothFinROI - mean(SmoothFinROI(1:200));
    %DeltaFinROI = mAllData.GreenSignal_FinROI{nLine} - mean(mAllData.GreenSignal_FinROI{nLine}(1:200));
    plot(DeltaFinROI),axis tight
    if max(DeltaFinROI)>3
        title('Strong response')
    else
        title('Weak response')
    end
    box off
    xlabel('Imaging frame (~55Hz)')
    %SpeedOnBall
    subplot(313),hold off
    X = (mAllData.FicTracSpeed{nLine}(:,1)-mAllData.FicTracSpeed{nLine}(1,1)+1);
    FicTracSpeed = mAllData.FicTracSpeed{nLine}(:,Axis);
    plot(X,FicTracSpeed), axis tight
    box off
    ylim([-0.2 0.2])
    title('Speed')
    xlabel('Tracking frame (60Hz)')
    
    disp(nLine)
    pause
end








