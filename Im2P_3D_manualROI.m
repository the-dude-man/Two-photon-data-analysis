
%user parameters
Folder = 'Z:\Diego\DudiData\20170428\20170428_5';
IsOverrideData = 0;

%load data (red channel)
reddatafile = [Folder,filesep(),Folder(end-9:end),'_1_refdata.mat'];
savefile = [Folder,filesep(),Folder(end-9:end),'_1_ROIdata.mat'];
if ~exist('Data','var') || IsOverrideData == 1
load(reddatafile)
end
XYZ = mean(Data,4);

LastROI = 1;
ROIdata = struct('CENTERS', [],'RADII', [], 'ROINUMBER', [], 'LastROI', []);

for Z = 1:size(XYZ,3)
    index = 1;
    XY = XYZ(:,:,Z);%one Z-plane
    figure(1)
    subplot(121), hold off
    imagesc(double(XY)), hold on
    colormap(gray), axis equal
    subplot(122), hold off
    imagesc(double(XY)), hold on
    colormap(gray), axis equal
    title(['Plane ',num2str(Z)])
    
    centers = []; borders = []; radii = []; ROInumber = [];
    
    while 1
        clear X Y
        
        IsLast = input('No more cells to mark in this plane? If yes, press Y+enter. ','s');
        if ~isempty(IsLast) && (strcmp(IsLast,'y') || strcmp(IsLast,'y'))
            ROIdata.CENTERS{Z} = centers;
            ROIdata.RADII{Z} = radii;
            ROIdata.ROINUMBER{Z} = ROInumber;
            break
        end
        figure(1)
        if Z > 1 && ~isempty(ROIdata.CENTERS{Z-1})
            subplot(121),hold off
            imagesc(double(XY)), hold on
            colormap(gray), axis equal
            title(['Last ROI number is: ',num2str(LastROI)])
            viscircles(ROIdata.CENTERS{Z-1},ROIdata.RADII{Z-1},'LineStyle','--','color','b')
            for ROI = 1:size(ROIdata.CENTERS{Z-1},1)
               text(ROIdata.CENTERS{Z-1}(ROI,1)-3,ROIdata.CENTERS{Z-1}(ROI,2)-3,...
                   num2str(ROIdata.ROINUMBER{Z-1}(ROI)),'color',[1 0 1],...
            'FontSize',max(ROIdata.RADII{Z-1}(ROI)/4,14)) 
            end
        end
        subplot(122)
        title(['Plane ',num2str(Z),'.     Mark circle (center, edge).'])
        [X, Y] = getpts(gcf);
        title(['Plane ',num2str(Z)])
        
        centers(index,:) = [X(1) Y(1)];
        borders(index,:) = [X(2) Y(2)];
        
        radii(index) = sqrt((borders(index,1)-centers(index,1))^2+(borders(index,2)-...
            centers(index,2))^2);
        
        viscircles(centers(:,:),radii(:,:))
        prompt = 'ROInumber? ';
        ROInumber(index) = input(prompt);
        LastROI = max(LastROI,ROInumber(index));
        text(centers(index,1)-3,centers(index,2)-3,num2str(ROInumber(index)),'color',[1 0 0],...
            'FontSize',max(radii(index)/4,14))
        
        
        index = index + 1;
    end
end

ROIdata.LastROI = LastROI;

save(savefile,'ROIdata')



