

function sOneSession = Im2P_Check_timestamps(Folder, IsOverride)
%Folder = 'Z:\Dudi\Imaging\2Photon\Dudi_setup\20160816\20160816_105';

if nargin == 1, IsOverride = 0; end

disp('Running the function Im2P_Check_timestamps')

%parameters
nBigJump = 10;
IsSave = 1;

CurrDir = cd(Folder);

%Name of file to save (and to check if alredy exists)
S = pwd;
FILESEP = strfind(S,filesep()); FILESEP = FILESEP(end);
FileName = ['OneSession','_',S(FILESEP+1:end),'.mat'];

%OneSession structure already made for this folder?
if exist(FileName,'file')
    load(FileName)
else
    disp(['Missing structure sOneSession for folder ',Folder,' Returning.'])
    sOneSession = -1;
    return
end
    
    
if isfield(sOneSession,'JumpsInAVI_report') && ~isempty(sOneSession.JumpsInAVI_report) && ~IsOverride
    disp('The field JumpsInAVI_report already exists and is not empty. Override sets to: No. Returning.')
    return  
end
    


Files = dir('*.h5');
aviFiles = dir('*.avi');

if size(Files,1) ~= 1 || size(aviFiles,1) == 0 || size(aviFiles,1) > 2
 disp('No AVI/h5 or more than one. Returning.')
 cd(CurrDir)
 return
end

% for ii = 1:size(aviFiles,1)
%  aviFilename = aviFiles(ii).name;   
%  if ~isempty(strfind(aviFiles(1).name,'debug')),continue,end
% end


%V = VideoReader(aviFilename);
%fps = V.FrameRate;

filename = Files(1).name;
timeStamps = h5read(filename, '/timeStamps');

actualFrameTimes = Im2P_stamps2times( timeStamps )*1000; % use frame embedded time stamps - more accurate!
fps = 1000/median(diff(actualFrameTimes));
sOneSession.AVIframe_Times = actualFrameTimes;
%%
D = diff(actualFrameTimes);
Jumps = find(diff(actualFrameTimes)>(1000/fps)*1.1); Jumps = Jumps(2:end);
PercentJumps = length(Jumps)/length(actualFrameTimes-1)*100;
BigJumps = find(diff(actualFrameTimes)>(1000/fps)*nBigJump); BigJumps = BigJumps(2:end);
PercentBigJumps = length(BigJumps)/length(actualFrameTimes-1)*100;
IndexMaxJump = find(diff(actualFrameTimes) == max(diff(actualFrameTimes)));
MaxJump = unique(actualFrameTimes(IndexMaxJump+1) - actualFrameTimes(IndexMaxJump));

disp(filename)
disp(['Frame rate: ',num2str(fps)])
S1 = ['Any jumps in ',num2str(PercentJumps),'% of the recorded frames'];
disp(S1)
S2 = ['Jump > ',num2str(nBigJump),' frames in ',num2str(PercentBigJumps),'% of the recorded frames'];
disp(S2)
Missing = sum((D(Jumps)-1000/fps)); AllMovie = (actualFrameTimes(end) - actualFrameTimes(1));%all in ms
S5 = [num2str(Missing/AllMovie*100),'% of the movie is missing'];
disp(S5)
if ~isempty(BigJumps)
S3 = ['The biggest jump is for ',num2str(MaxJump/1000),' sec, in recorded frame ',num2str(IndexMaxJump)];
disp(S3)
S4 = 'Big jumps in: ';
end
disp('=====')

%write jump info into txt file
if isempty(BigJumps)
TEXT = sprintf('%s\n%s\n%s\n%s\n',filename,S1,S2,S5);
else
TEXT = sprintf('%s\n%s\n%s\n%s\n%s\n%s\n',filename,S1,S2,S5,S4,num2str(BigJumps));
end

disp(TEXT)
sOneSession.JumpsInAVI_report = TEXT;
if IsSave == 1
save(FileName,'sOneSession')
end

cd(CurrDir)