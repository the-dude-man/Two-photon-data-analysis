%function vIsCircleOK = CheckMASK(Folderdate)

%The function checks if the MASK is OK in current folder or if not - in a
%previous one. If the mask i9s OK for some videos - prepare for batch
%tracking with FicTrac

warning('off', 'MATLAB:table:RowsAddedNewVars')

%parameters
nSnapshotImage = 500;%This image will be used to check/create a MASK for FicTrac
N_iterateBetweenSnapshots = 4;%the number of times an early and a late image are shown in sequence to check that the camera
%didn't move during session, before making a snapshot
Folder = 'Z:\Dudi\Imaging\2Photon\Dudi_setup\DSX_VR2P_Auditory';
Date_for_CheckMask = '20170426';

clear Allsessions
CurrDir = cd(Folder);

%Find sessions with data to analyze in Folderdate
Files = dir('*.xlsx');
if ~(size(Files,1)==1), disp('More than one excell file in the folder. Returning.'),cd(CurrDir),return,end

XLSfile = fullfile(Folder,Files(1).name);
XLSData = xlsread(XLSfile,1);


%make table: for each session where is the avi and is there a mask file in the same folder
Allsessions = array2table(sortrows(XLSData(:,1:2),[1 2]));
Allsessions.Properties.VariableNames = {'Date','Session'};

for nLine = 1:size(Allsessions,1)
    Date = num2str(Allsessions{nLine,1}); Date = Date(3:end);
    Session = num2str(Allsessions{nLine,2});
    avifilename = [Date,'_',Session,'.avi'];
    Allsessions.avifilename{nLine} = avifilename;
end

%Check if/where is the avi file for each session (can be either in the date folder or in the session subfolder if created)
%and if a mask exist
for nLine = 1:size(Allsessions,1)
    if exist(num2str(Allsessions{nLine,1}),'dir')
        cd(num2str(Allsessions{nLine,1}));
        if exist(Allsessions{nLine,3}{1},'file')
            avifullpath = fullfile(pwd,Allsessions{nLine,3});
            Allsessions.avifilepath{nLine} = avifullpath;
            Mask = dir([Allsessions{nLine,3}{1}(1:end-4),'MASK.*']);
            if size(Mask,1) > 1, disp(['More than one mask file for ',avifullpath,'. Returning.']),return
            elseif size(Mask,1) == 0, Allsessions.Maskfile{nLine} = -1;
            else, Allsessions.Maskfile{nLine} = fullfile(Mask(1).folder,Mask(1).name);
            end
            cd(Folder)
            continue
        elseif exist(Allsessions{nLine,3}{1}(1:end-4),'dir')
            cd(Allsessions{nLine,3}{1}(1:end-4))%one session folder
            if exist(Allsessions{nLine,3}{1},'file')
                avifullpath = fullfile(pwd,Allsessions{nLine,3});
                Allsessions.avifilepath{nLine} = avifullpath;
                Mask = dir([Allsessions{nLine,3}{1}(1:end-4),'MASK.*']);
                if size(Mask,1) > 1, disp(['More than one mask file for ',avifullpath,'. Returning.']),return
                elseif size(Mask,1) == 0, Allsessions.Maskfile{nLine} = -1;
                else, Allsessions.Maskfile{nLine} = fullfile(Mask(1).folder,Mask(1).name);
                end
                cd(Folder)
            end
            cd ..
        end
    end
end

warning('off', 'MATLAB:table:RowsAddedNewVars')

LastMaskFile = [];
for nLine = 1:size(Allsessions,1)
    Allsessions.LastMaskfile{nLine} = -1;
    if ~(Allsessions.Maskfile{nLine} == -1)
        LastMaskFile = Allsessions.Maskfile{nLine};
    elseif ~isempty(LastMaskFile)
        Allsessions.LastMaskfile{nLine} = LastMaskFile;
    end
end

%plot sumarry
disp('Missing avi files:')
for nLine = 1:size(Allsessions,1)
    if isempty(Allsessions.avifilepath{nLine})
        disp(Allsessions.avifilename{nLine})
    end
end
disp('End of list')
disp('===')

disp('Has movie, missing Mask and no previous mask:')
for nLine = 1:size(Allsessions,1)
    if ~isempty(Allsessions.avifilepath{nLine}) && (Allsessions.Maskfile{nLine}(1) == -1) && (Allsessions.LastMaskfile{nLine}(1) == -1)
        disp(Allsessions.avifilename{nLine})
    end
end
disp('End list')
disp('===')

disp('Missing Mask but has previous mask:')
for nLine = 1:size(Allsessions,1)
    if ~isempty(Allsessions.avifilepath{nLine}) && (Allsessions.Maskfile{nLine}(1) == -1) && ~(Allsessions.LastMaskfile{nLine}(1) == -1)
        disp(Allsessions.avifilename{nLine})
    end
end
disp('End list')
disp('===')


%%  check previous masks. If fits to current movie - copy mask file

for nLine = 1:size(Allsessions,1)
    if ~(~isempty(Allsessions.avifilepath{nLine}) && (Allsessions.Maskfile{nLine}(1) == -1) && ~(Allsessions.LastMaskfile{nLine}(1) == -1))
        continue
    end
    %has movie, no mask, but do have a previous mask
    MASKFILE = Allsessions.LastMaskfile{nLine};
    AVIFILE = Allsessions.avifilepath{nLine}{1};
    
    MASK = imread(MASKFILE);
    v = VideoReader(AVIFILE);
    FRAME1 = read(v,nSnapshotImage);
    
    ApproxLastFrame = v.Duration * v.FrameRate;
    FRAME2 = read(v,ApproxLastFrame-600);
    
    figure(1),clf,figure(1)
    subplot(121)
    imshow(FRAME1),hold on,h = imshow(MASK); h.AlphaData = 0.5; title('Early frame')
    subplot(122)
    imshow(FRAME2),hold on,h = imshow(MASK); h.AlphaData = 0.5; title('Late frame')
    
    prompt = 'Good mask for this movie? y/n [y]: ';
    str = input(prompt,'s');
    if isempty(str)
        str = 'y';
    end
    
    [MoveToFolder,~,~] = fileparts(Allsessions.avifilepath{nLine}{1});
    [~,~,ext] = fileparts(Allsessions.LastMaskfile{nLine});
    
    if strcmp(str,'y')
        newfilename = [Allsessions.avifilepath{nLine}{1}(1:end-4),'MASK',ext];
        copyfile(Allsessions.LastMaskfile{nLine},newfilename)
        Allsessions.Maskfile{nLine} = newfilename;
    else
        disp('Cant use previous mask, returning.')
        cd(CurrDir)
        break
    end
    
end

%If still no mask (but there is a movie) - check that no motion during
%session and add a snap image
for nLine = 1:size(Allsessions,1)
    if isempty(Allsessions.avifilepath{nLine}) || ~(Allsessions.Maskfile{nLine}(1) == -1)
        continue
    end
    
    snapfilename = [Allsessions.avifilepath{nLine}{1}(1:end-4),'Snap.png'];
    if exist(snapfilename,'file') 
        continue
    end
    
    %has movie, and no mask
    AVIFILE = Allsessions.avifilepath{nLine}{1};
    
    v = VideoReader(AVIFILE);
    FRAME1 = read(v,nSnapshotImage);
    
    ApproxLastFrame = v.Duration * v.FrameRate;
    FRAME2 = read(v,ApproxLastFrame-600);
    
    figure(1),clf,figure(1)
    for ii = 1:N_iterateBetweenSnapshots
    imshow(FRAME1)
    title('Make sure the ball didnt move during session')
    pause(0.8)
    imshow(FRAME2)
    pause(0.8)
    end
    
    disp(['Movie: ',Allsessions.avifilepath{nLine}{1}])
    prompt = 'Make a snap? y/n [y]: ';
    str = input(prompt,'s');
    if isempty(str)
        str = 'y';
    end
    
    [MoveToFolder,~,~] = fileparts(Allsessions.avifilepath{nLine}{1});
    
    if strcmp(str,'y')
        imwrite(FRAME1,snapfilename)
    end
end





%% below are some leftovers to use in other scripts/functions -  


% detecting the cycle in the mask file (can be used to update the VFOV)
% [centers, radii] = imfindcircles(imread(MASKFILE), [300 400], ...
%     'Sensitivity', 0.95, ...
%     'EdgeThreshold', 0.10, ...
%     'Method', 'PhaseCode', ...
%     'ObjectPolarity', 'Bright');
% if isempty(radii), disp('cant detect circle in MASK file'), cd(CurrDir),return, end
% figure(1), subplot(121),hold off
% imshow(imread(MASKFILE)), hold on, viscircles(centers,radii)



% Prepare files for FicTrac (need to rewrite, but can use some pieces from here)

% copyfile('../FicTracFiles/calibration-transform.dat','./')
% copyfile('../FicTracFiles/exp_config.txt','./')
% vSessionsWithGoodMASK = vSessions(vIsCircleOK==1);
%
% %Text to copy paste for running
% for Index = 1:length(vSessionsWithGoodMASK)
%     nSession = vSessionsWithGoodMASK(Index);
%     AVIfiles = dir(['*',num2str(nSession),'.avi']);
%     AVItoTrack = [AVItoTrack AVIfiles(1).name];
%     if ~(Index == length(vSessionsWithGoodMASK))
%         AVItoTrack = [AVItoTrack ','];
%     end
% end


% replaceLine = 5;
% myformat = '%s \n';
% tmp = strfind(MASKFILE,filesep()); tmp = tmp(end);
% newData = ['mask_fn             .',filesep(),MASKFILE(tmp+1:end)];
%
% fileID = fopen('exp_config.txt','r+');
% for k=1:(replaceLine-1);
%     fgetl(fileID);
% end
%
% fseek(fileID,0,'cof');
%
% fprintf(fileID, myformat, newData);
% fclose(fileID);


%write batch.txt: the cmd to use for runnig FicTrac in btch mode (run in Ubuntu inside the VM)
% cd(FicTracPath)
% if exist('batch.txt','file'), delete('batch.txt'), end
% fileID = fopen('batch.txt','w');
% TXT1 = 'Make sure you are in the FicTrac folder, and then run: ';
% TXT2 = ['.',filesep(),'run_fictrac.sh "',pwd,'exp_config.txt','" "',AVItoTrack,'"'];
%
% fprintf(fileID,'%s\r\n',TXT1);
% fprintf(fileID,'%s\r\n',TXT2);
% fclose(fileID);




