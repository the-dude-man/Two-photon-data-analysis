function Im2P_ROIs_OneDate(rootFolder)
CurrDir = cd(rootFolder);

subFolders = dir;
dirFlags = [subFolders.isdir];
subFolders = subFolders(dirFlags);
for nSubfolder = 1:size(subFolders,1)
    if ~isempty(strfind(subFolders(nSubfolder).name,'.')) ||...
            strcmp(subFolders(nSubfolder).name,'ProbablyJunk'), continue,end
    cd(subFolders(nSubfolder).name)
    Folder = pwd;
    Im2P_findROIs(Folder);%User defines ROIs (in Tif, in AVI)
    cd ..
end

cd(CurrDir)
end