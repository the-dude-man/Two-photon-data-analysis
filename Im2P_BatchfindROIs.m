function Im2P_BatchfindROIs(MasterFolder,IsOverride)
%Dudi Deutsch, Princeton, Nov 2016

%MasterFolder includes rootFolders, where each rootFolder is one date

if nargin == 1, IsOverride = 0; end%default 

CurrDir = cd(MasterFolder);

%%User input - choose a list of 3 posiible ROI names:
ROIs = {'LPC','PMN2','PC2Cell'};
%%
%%
DateFolders = dir();
DateFolders(~[DateFolders.isdir]) = [];  %remove non-directories
tf = ismember( {DateFolders.name}, {'.', '..'});
DateFolders(tf) = [];  %remove current and parent directory.

for nDate = 1:size(DateFolders,1)
    cd(DateFolders(nDate).name)
    SessionFolders = dir();
    SessionFolders(~[SessionFolders.isdir]) = [];  %remove non-directories
    tf = ismember( {SessionFolders.name}, {'.', '..'});
    SessionFolders(tf) = [];  %remove current and parent directory.
    for nSession = 1:size(SessionFolders,1)
        if strcmp(SessionFolders(nSession).name,'ProbablyJunk')
            continue
        end
        cd(SessionFolders(nSession).name)
        Folder = pwd;
        S = pwd;
        FILESEP = strfind(S,filesep()); FILESEP = FILESEP(end);
        FileName = ['OneSession','_',S(FILESEP+1:end),'.mat'];
        if  ~exist(FileName,'file')
            disp(['Missing file',FileName,'in ',Folder])
            cd ..
            continue
        end
        load(FileName)
        if ~exist('sOneSession','var')
           disp(['Missing structure sOneSession in ',Folder])
           cd ..
           continue
        end
        if ~(isfield(sOneSession,'TiffROI')) || isempty(sOneSession.TiffROI) || IsOverride
        Im2P_findROIs(Folder, IsOverride, ROIs);
        end
        cd ..
    end
    cd ..
end

%%


cd(CurrDir)
end

