
function Im2P_Redo_CreateFolders_OnePerSession(rootFolder)

currDir = cd(rootFolder);
Directories = dir;
Directories(~[Directories.isdir]) = [];%leave only directories


for nDir = 1:size(Directories,1)
    Directory = Directories(nDir).name;
    if strcmp(Directory,'.') ||  strcmp(Directory,'..'), continue,end
    cd(Directory)
    Files = dir;
    for nFile = 1:size(Files,1)
        FileName = fullfile(rootFolder,Directory,Files(nFile).name);
        if strcmp(Files(nFile).name,'.') || strcmp(Files(nFile).name,'..'),continue,end
        movefile(FileName,rootFolder)
    end
    cd ..
    rmdir(Directory)
end

OneSessionFiles = dir('*OneSession*');
for File = 1:size(OneSessionFiles,1)
    delete(OneSessionFiles(File).name);
end

if exist(currDir,'dir'),cd(currDir),end
end
