%Im2P_CreateFilesForFicTrac checks if the las mask is correct, and if not - asks the
%user to create a new mask. Create a new folder for FicTrac input/output
%file for this date

function Im2P_CreateFilesForFicTrac(CheckMask)
%CheckMask must be 0 or 1
if ~(CheckMask == 0 || CheckMask == 1)
    disp('CheckMask must be 0 or 1. Returning')
    return
end


%FicTrac main folder path
FicTracPath = 'Z:\Dudi\temp';
CurrDir = cd(FicTracPath);
%Upload the last mask and snap files

%MASK
MASKfiles = dir('*mask*.png');
DateModified = zeros(1,size(MASKfiles,1));
for nMaskFile = 1:size(MASKfiles,1)
    DateModified(nMaskFile) = datenum(MASKfiles(nMaskFile).date);
end
MaskFile = fullfile(pwd,MASKfiles(DateModified == max(DateModified)).name);
MASK = imread(MaskFile);
if size(MASK,3) == 3%if the image file is a true RGB image file, convert
MASK = rgb2gray(MASK);
end

if CheckMask
    %SNAP
    SNAPfiles = dir('*snap*');
    DateModified = zeros(1,size(SNAPfiles,1));
    for nSnapFile = 1:size(SNAPfiles,1)
        DateModified(nSnapFile) = datenum(SNAPfiles(nSnapFile).date);
    end
    
    SnapFile = fullfile(pwd,SNAPfiles(DateModified == max(DateModified)).name);
    SNAP = rgb2gray(imread(SnapFile));
    
    %show snap with transparent mask overlaid
    figure(1); clf
    colormap(gray)          
    C = imfuse(SNAP,MASK,'blend');
    imshow(C)
  
    %Updated mask by user if needed
    prompt = 'Mask OK? Y/N [Y]: ';
    while 1
        IsOK = input(prompt,'s');
        if isempty(IsOK)
            IsOK = 'Y';
        end
        if strcmpi(IsOK,'N') || strcmpi(IsOK,'Y'), break, end
        disp('Wrong input value, Y/N only')
    end
else
    IsOK = 'Y';
end

%create new mask
if strcmpi(IsOK,'N')
    MaskOK = 0;
    imageSizeX = size(SNAP,2);
    imageSizeY = size(SNAP,1);
    [columnsInImage, rowsInImage] = meshgrid(1:imageSizeX, 1:imageSizeY);
    while 1
        %user defines ball circle
        disp('Define ball borders')
        fig = figure(1); clf(fig)
        imshow(SNAP)
        [x, y] = getpts(fig);
        [xc,yc,R,~] = circfit(x,y);
        BallPixels = (rowsInImage - yc).^2 ...
            + (columnsInImage - xc).^2 <= R.^2;
        BallMASK = BallPixels;% circlePixels is white - mask on
        
        %user defines glare circle
        disp('Define glare borders')
        fig = figure(1); clf(fig)
        imshow(SNAP)
        [x, y] = getpts(fig);
        [xc,yc,R,~] = circfit(x,y);
        
        glarePixels = (rowsInImage - yc).^2 ...
            + (columnsInImage - xc).^2 <= R.^2; % circlePixels is a 2D "logical" array.
        GlareMASK = 1 - glarePixels;%so that the glare is black - mask off
        
        %user defines ball holder
        while 1
            disp('Define holder rectangle (4 points)')
            fig = figure(1); clf(fig)
            imshow(SNAP)
            [x, y] = getpts(fig);
            if length(x) == 4
                break
            else
                disp('4 points please..')
            end
        end
        %fix x,y such that:
        %(1) straight line under the ball (in any image orientation)
        %(2) black all the way to the bottom (just in case the bottom was marked wrongly)
        if all(x>xc)%air stream axis: left
            [~,idx] = sort(x);
            x(idx(1:2)) = min(x(idx(1:2)));
            x(idx(3:4)) = size(SNAP,2);
        elseif all(x<xc)%air stream axis: right
            [~,idx] = sort(x);
            x(idx(3:4)) = max(x(idx(3:4)));
            x(idx(1:2)) = 1;
        elseif all(y<yc)%air stream axis: up
            [~,idx] = sort(y);
            y(idx(1:2)) = min(y(idx(1:2)));
            y(idx(3:4)) = size(SNAP,1);
            
        elseif all(y>yc)%air stream axis: down
            [~,idx] = sort(y);
            y(idx(3:4)) = max(y(idx(3:4)));
            y(idx(1:2)) = 1;
        else%don't change coordinates, but possibly something's wrong
            disp('ball orientation unclear, cant fix ball holder coordinates.')
        end
        
        BallHolder = poly2mask(x, y, size(SNAP,1), size(SNAP,2));
        BallHolderMASK = 1 - BallHolder; %so that the ball holder is black - mask off
        
        %make mask
        MASK = BallMASK & GlareMASK & BallHolderMASK;
        
        fig = figure(1); clf(fig)
        C = imfuse(SNAP,MASK,'blend');
        imshow(C)
        
        prompt = 'Mask OK? Y/N [Y]: ';
        while 1
            IsOK = input(prompt,'s');
            if isempty(IsOK)
                IsOK = 'Y';
            end
            if strcmpi(IsOK,'N') || strcmpi(IsOK,'Y'), break, end
            disp('Wrong input value, Y/N only')
        end
        
        if strcmpi(IsOK,'y'), MaskOK = 1; end
        
        if MaskOK == 1
            MASK_filename = fullfile(pwd,'online_MASK.png');%will be updated and used for FicTrac online tracking
            imwrite(MASK,MASK_filename)
            break
        end
    end
end



%create a folder for the current date and session
prompt = 'Session number? ';
while 1
    SessionNumber = input(prompt,'s');%I do it this way to prevent error for non numeric input
    SessionNumber = str2double(SessionNumber);
    if ~isnan(SessionNumber), break, end
    disp('Input must be a number')
end

DATE = char(datetime('now','Format','yyMMdd'));
Folder = [DATE,'_',num2str(SessionNumber)];

if isdir(Folder)
    prompt = ['Folder ',Folder,' already exist,override? Y/N [Y]: '];
    while 1
        IsContinue = input(prompt,'s');
        if isempty(IsContinue)
            IsContinue = 'Y';
        end
        if strcmpi(IsContinue,'N') || strcmpi(IsContinue,'Y'), break, end
        disp('Wrong input value - Y/N only')
    end
    
    if strcmpi(IsContinue,'N'), return, end
else
    mkdir(Folder)
end

%At this point the mask is updated and a folder was created for the session
config_filename = fullfile(pwd,'configOnline.txt');%will be updated and used for FicTrac online tracking
copyof_config_filename = fullfile(pwd,Folder,['configOnline_',DATE,'_',num2str(SessionNumber),'.txt']);%will be saved in the session folder

%MASK_filename is defined earlier as MASK_filename = fullfile(pwd,'online_MASK.png');%will be updated and used for FicTrac online tracking
copyof_MASK_filename = fullfile(pwd,Folder,['MASK_',DATE,'_',num2str(SessionNumber),'.png']);%will be saved in the session folder

calibration_filename = fullfile(pwd,'calibration-transform.dat');%will be updated and used for FicTrac online tracking
copyof_calibration_filename = fullfile(pwd,Folder,'calibration-transform.dat');%will be saved in the session folder

%modify config file
output_fn = ['.\',Folder,'\output_',DATE,'_',num2str(SessionNumber)];
mask_fn = ['.\',Folder,'\MASK_',DATE,'_',num2str(SessionNumber),'.png'];
transform_fn = ['.\',Folder,'\calibration-transform.dat'];

%previous file: read
fid = fopen(config_filename);
%new file: right
new_fid = fopen(copyof_config_filename,'wt');

while 1
    tline = fgets(fid);
    if ~isempty(strfind(tline,'output_fn'))
        newline = ['output_fn           ',output_fn];
        fprintf(new_fid, '%s\n',newline);
    elseif ~isempty(strfind(tline,'mask_fn'))
        newline = ['mask_fn             ',mask_fn];
        fprintf(new_fid, '%s\n',newline);
    elseif ~isempty(strfind(tline,'transform_fn'))
        newline = ['transform_fn        ',transform_fn];
        fprintf(new_fid, '%s\n',newline);
    elseif ~isempty(strfind(tline,'do_socket_out'))
        newline = 'do_socket_out      0';
        fprintf(new_fid, '%s\n',newline);
        break
    else
        fprintf(new_fid, '%s',tline);
    end
end

fclose(fid);
fclose(new_fid);

%copy files
copyfile(MASK_filename,copyof_MASK_filename)
copyfile(calibration_filename,copyof_calibration_filename)


cd(CurrDir)

end
