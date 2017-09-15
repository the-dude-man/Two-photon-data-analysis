
Folder = 'Z:\Dudi\Imaging\2Photon\Dudi_setup\DSX_VR2P_Auditory';
Date = '20170425';
Session = '210';

nSnapshotImage = 500;

%find avi
AVIFILE = [Folder,filesep(),Date,filesep,Date(3:end),'_',Session,'.avi'];
%read avi
if exist(AVIFILE,'file') > 0
v = VideoReader(AVIFILE);
else 
    disp('AVIFILE not found')
    return
end
%make snap
snapfilename = [Folder,filesep(),Date,filesep,Date(3:end),'_',Session,'Snap.png'];
[Folder,filesep(),Date,filesep,Date(3:end),'_',Session,'.avi'];
FRAME = read(v,nSnapshotImage);
imwrite(FRAME,snapfilename)



