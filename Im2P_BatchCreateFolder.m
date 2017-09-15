function Im2P_BatchCreateFolder(MasterFolder,IsOverride)
%Dudi Deutsch, Princeton, Nov 2016

%MasterFolder includes rootFolders, where each rootFolder is one date

if nargin == 1, IsOverride = 0; end%default 

CurrDir = cd(MasterFolder);

Directories = dir;
Directories = Directories([Directories.isdir] == 1);

for nDir = 1:size(Directories,1) 
if ~isempty(strfind(Directories(nDir).name,'.')),continue,end

rootFolder = fullfile(pwd,Directories(nDir).name);
cd(rootFolder)

Files = dir; 
N_Files = length(Files([Files.isdir]==0))-2;

if N_Files>0 || IsOverride == 1
disp(['Creating folders for rootFolder ',rootFolder])
Im2P_Redo_CreateFolders_OnePerSession(rootFolder)
Im2P_CreateFolders_OnePerSession(rootFolder)
else
disp(['One session folders already exist and no IsOverride chosen for folder ',rootFolder])
end
cd ..
end
cd(CurrDir)
end



