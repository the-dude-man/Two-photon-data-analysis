
ROI = {'Ring','LPC'};
Gender = 'F';
CurrDir = pwd;
datafile = 'Z:\Dudi\Imaging\2Photon\Diego_setup\Alldata_Playback.mat';
load(datafile)

clear Intensity DFF_max DFF_sum

nIndex = 1;
for ii = 1:size(mAllData,1)
 if isempty(strfind(mAllData.Folder{ii},'DSX_2P_Intensity')), continue,end 
 if ~any(strcmp(ROI,mAllData.ROIname{ii})), continue,end%check ROI name
 if ~(strcmp(mAllData.Gender,Gender)), continue,end%Check gender
    cd(mAllData.Folder{ii})
Intensity(nIndex) = mAllData.Intensity{ii}(1);
DFF_max(nIndex) =  mAllData.GreenSignal_MaxDFF{ii};
DFF_sum(nIndex) = mAllData.GreenSignal_SumDFF{ii};

nIndex = nIndex +1 ;
end
clear Y YY
figure(1),hold off
X = unique(Intensity);
for nIndex = 1:length(X) 
    Y(nIndex) = mean(DFF_max(Intensity == X(nIndex)));
    YY(nIndex) = mean(DFF_sum(Intensity == X(nIndex)));
end
Y = Y/max(Y); YY= YY/max(YY);

plot(X,Y,'LineWidth',2), hold on
plot(X,YY,'.-','LineWidth',2), legend('max DFF','sum DFF')

cd(CurrDir)