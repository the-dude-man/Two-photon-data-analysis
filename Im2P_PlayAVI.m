
%user parameters
AVIFILE = 'Z:\Dudi\Imaging\2Photon\Dudi_setup\DSX_VR2P_Auditory\20170425\20170425_210\170425_210.avi';
nStart = 44357;
nEnd = 44363;

if exist(AVIFILE,'file') > 0
v = VideoReader(AVIFILE);
else 
    disp('AVIFILE not found')
    return
end

figure(1),subplot(111),hold off
for nFrame = nStart:nEnd
FRAME = read(v,nFrame);
FRAME = imrotate(FRAME,-90);
FRAME = FRAME(25:235,285:675,:);
imagesc(FRAME)
title(nFrame)
pause
end



