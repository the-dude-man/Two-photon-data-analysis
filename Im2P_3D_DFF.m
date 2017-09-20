%%   user parameters

%session data
Folder = 'Z:\Diego\DudiData\20170428\20170428_5';

%flags
IsOverrideData = 0;
PlotIndividualCells = 0;
OneStackPerCell = 0;%for each cell, calculate DFF only for one plane - the plane with largest cell radius

StrongResponse = [2 20 22 23 25 34 36 38 39];
WeakResponse = [3 17 26 28 32 33 35 41];
respondingcells = zeros(1,ROIdata.LastROI);
respondingcells(StrongResponse) = 2;
respondingcells(WeakResponse) = 1;



% respondingcells = [2 2 2 2 0 1 0 0 2 0 0 0 0 0 1 0 0 2];%20170428_3
%[0 1 2 0 1 0 0 0 2 1 1 0 2 0] %20170421_3


%load data
filename = [Folder,filesep(),Folder(end-9:end),'_1_'];
greendatafile = [filename,'rawdata.mat'];%4D structure with green channel data
refdatafile = [filename,'refdata.mat'];%4D ... red channel
binfile = [filename,'bin.mat'];%stimulus data
metadata = [filename,'metadata.mat'];%imaging and stimulus meta data (e.g., pixel size)
ROIfile = [filename,'ROIdata.mat'];%the file that has the corrdinated of all the cells
%from manual annotation

load(ROIfile)
load(binfile)
load(metadata)
if ~exist('Data','var') || IsOverrideData == 1
    load(greendatafile)
    refdata = load(refdatafile);
end

if ~isempty(respondingcells) && length(respondingcells)~=ROIdata.LastROI
   respondingcells  = zeros(1,ROIdata.LastROI);
end

fps = size(Data,4)/(size(data,1)/10000);
PixelSize = iDat.MetaData{3};


%% for each cell - get all the pixels
[rNum,cNum,~,~] = size(Data);


nNumberOfCells = 0;
for Z = 1:size(ROIdata.ROINUMBER,2)
    if isempty(ROIdata.ROINUMBER{Z}), continue,end
    nNumberOfCells = max(nNumberOfCells,max(ROIdata.ROINUMBER{Z}));
end

sAllCells = struct;
for nCell = 1:nNumberOfCells
    F_InROI = zeros(1,size(Data,4));%size(Data,4) = number of time points
    Pixels_InROI = 0;
    CellMaxRadius = 0;
    OneCellAllCenters = []; OneCellAllRadiuses = [];
    clear CellCoordinates_atMaxRadius
    for Z = 1:size(ROIdata.ROINUMBER,2)
        F_InROI_onestack = zeros(1,size(Data,4));
        if isempty(ROIdata.ROINUMBER{Z}), continue,end
        nIndex = find(ROIdata.ROINUMBER{Z} == nCell);
        if isempty(nIndex), continue, end
        
        
        x = ROIdata.CENTERS{Z}(nIndex,1);
        y = ROIdata.CENTERS{Z}(nIndex,2);
        radius = ROIdata.RADII{Z}(nIndex);
        if size(x,1)>1, x = x(1); y = y(1); radius = radius(1);end
        OneCellAllCenters = [OneCellAllCenters;[x y]];
        OneCellAllRadiuses = [OneCellAllRadiuses radius];
        
        [xx,yy] = ndgrid((1:rNum)-y,(1:cNum)-x);
        mask = (xx.^2 + yy.^2)<radius(1)^2;
        [yCoordinates, xCoordinates] = find(mask);
        for ii = 1:length(yCoordinates)
            F_InROI_onestack = F_InROI_onestack + ...
                reshape(Data(yCoordinates(ii),xCoordinates(ii),Z,:),[1, size(Data,4)]);
        end
        %F_InROI_onestack = reshape(sum(sum(Data(yCoordinates,xCoordinates,Z,:),1),2),1,size(Data,4));
        %SizeData = size(DataInROI);
        %F_InROI_onestack = sum(reshape(DataInROI, prod(SizeData([1 2 3])), []));
        
        F_InROI = F_InROI + F_InROI_onestack;%if OneStackPerCell == 1, this will
        %be override later
        Pixels_InROI = Pixels_InROI + length(xCoordinates);
        if ROIdata.RADII{Z}(nIndex) > CellMaxRadius
            CellMaxRadius = ROIdata.RADII{Z}(nIndex);
            CellCoordinates_atMaxRadius = ROIdata.CENTERS{Z}(nIndex,:);
            CellZ_atMaxRadius = Z;
            if OneStackPerCell == 1,F_InROI = F_InROI_onestack;end
        end

    end
    sAllCells(nCell).F_InROI = F_InROI;
    sAllCells(nCell).Pixels_InROI = Pixels_InROI;
    sAllCells(nCell).CellCoordinates_atMaxRadius = CellCoordinates_atMaxRadius;
    sAllCells(nCell).CellMaxRadius = CellMaxRadius;
    sAllCells(nCell).CellZ_atMaxRadius = CellZ_atMaxRadius;
    sAllCells(nCell).OneCellAllCenters = OneCellAllCenters;
    sAllCells(nCell).OneCellAllRadiuses = OneCellAllRadiuses;
end


%% summary plots
figure(1),subplot(121),hold off
maxproj = sum(max(Data(:,:,3:end,:),[],4),3);
imagesc(maxproj)
colormap(gray), axis equal, axis off

clear centersBright radiiBright
for nCell = 1:size(sAllCells,2)
    radiiBright(nCell) = sAllCells(nCell).CellMaxRadius;
    centersBright(nCell,1:2) = sAllCells(nCell).CellCoordinates_atMaxRadius;
end
hold on
%viscircles(centersBright, radiiBright,'Color','b'); hold off

for nCircle = 1:size(centersBright,1)
    text(centersBright(nCircle,1)-ceil(nCircle/10),centersBright(nCircle,2),num2str(nCircle),'Color','r','FontSize',10)
end
xlabel('ML'),ylabel('DV')

vScale = [0.8 0.4 0.1];
%side view
subplot(122),hold off
for nCell = 1:size(sAllCells,2)
    r = sAllCells(nCell).CellMaxRadius * mean(PixelSize(1:2));
    a=sAllCells(nCell).CellCoordinates_atMaxRadius(1) * PixelSize(1);
    b=sAllCells(nCell).CellCoordinates_atMaxRadius(2) * PixelSize(2);
    c=sAllCells(nCell).CellZ_atMaxRadius * PixelSize(3);
    [x,y,z] = sphere(20);
    h = surf((x*r+a), -(y*r+b), (z*r+c)); hold on
    if isempty(respondingcells)
    scale = 1;%all cells in the same color if unknown which ones are responding
    else
    scale = vScale(respondingcells(nCell)+1);
    end
    h.LineStyle = 'none'; h.FaceColor = scale * ones(1,3); h.EdgeColor = 0.2 * ones(1,3);h.LineStyle = '-.';
    colormap gray, grid off, axis equal
end
xlabel('ML'),ylabel('DV'),zlabel('AP')


%plot all responses
figure(2), hold off
for nCell = 1:size(sAllCells,2)
    N = ceil(sqrt(size(sAllCells,2)+1));
    subplot(N,N,nCell)
    plot(sAllCells(nCell).F_InROI)
    title(['Cell ',num2str(nCell)])
    %box color/width - mark responding cells
    ax = gca;
    if ~isempty(respondingcells) && respondingcells(nCell)>0, ax.XColor = 'red'; ax.YColor = 'red';end
    if ~isempty(respondingcells) && respondingcells(nCell)==2, ax.LineWidth = 3;end
end
subplot(N,N,nCell+1)
plot(data(20:end,3)), axis tight
title('Stimulus')
fig = gcf; fig.Color = [1 1 1];

%plot cell by cell
if PlotIndividualCells
    for nCell = 1:size(sAllCells,2)
        figure(nCell+2)
        subplot(121), imagesc(sum(Data(:,:,sAllCells(nCell).CellZ_atMaxRadius,:),4));
        colormap(gray), axis equal, hold on
        viscircles(sAllCells(nCell).CellCoordinates_atMaxRadius,...
            sAllCells(nCell).CellMaxRadius,'Color','b'); box off, axis off
        title(['Cell ',num2str(nCell),', max radius at plane ',...
            num2str(sAllCells(nCell).CellZ_atMaxRadius)])
        subplot(222)
        plot(sAllCells(nCell).F_InROI/sAllCells(nCell).Pixels_InROI,'k','LineWidth',2)
        axis tight
        xlabel(['Frame number (at,' num2str(round(fps,2)),' frames per second)'])
        ylabel('F/Pixel in ROI')
        subplot(224), plot(data(:,1),'r'), axis tight
        xlabel('Sample (at 10K Hz)')
    end
end






