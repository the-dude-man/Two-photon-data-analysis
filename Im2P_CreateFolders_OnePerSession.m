function Im2P_CreateFolders_OnePerSession(rootFolder, IsOverride)

if nargin == 1, IsOverride = 0; end

currDir = cd(rootFolder);
Files = dir;
Slash = strfind(rootFolder,filesep()); Slash = Slash(end);
MasterFolder = rootFolder(1:Slash);

%The excell file with the list of relevant experiments (excluding tests etc.)
XLSfiles = dir('../*.xlsx');
if isempty(XLSfiles), disp('No xls file with session info.Returning.'),return,end
XLSfile = [];
for ii = 1:size(XLSfiles,1)
    XLSfile = fullfile(MasterFolder,XLSfiles(ii).name);
    if isempty(strfind(XLSfile,'old')) && isempty(strfind(XLSfile,'Old'))
        break%found the xls file
    end
end
if isempty(XLSfile), disp('No xls file with session info. Returning.'),return,end

%Check if there are files directly under root directory
IsFiles = 0;
for nFile = 1:size(Files,1)
    if ~Files(nFile).isdir && ~strcmp(Files(nFile).name,'Thumbs.db'),IsFiles = 1; break,end%file under root directory
end

%find what are the relevant sessions from the excell table
[data,~,raw] = xlsread(XLSfile,1);
Slash = strfind(rootFolder,'\'); Slash = Slash(end);
Date = str2double(rootFolder(Slash+1:end));
Sessions = data(data(:,1)==Date,2);

if IsFiles == 1%create subfolders and move the files into the subfolders
    for nFile = 1:size(Files,1)
        FileName = Files(nFile).name;
        if strcmp(Files(nFile).name,'.') ||  strcmp(Files(nFile).name,'..') || isdir(FileName) ||...
                strcmp(FileName,'Thumbs.db'), continue,end
        
        UnderScores = strfind(FileName,'_');
        if isempty(UnderScores), continue, end
        Session = str2double(FileName(UnderScores(1)+1:UnderScores(1)+3));
        
        if ~isempty(find(Sessions==Session,1))
            SubFolder = fullfile(rootFolder,[rootFolder(end-7:end),'_',num2str(Session)]);
            if ~exist(SubFolder,'dir')
                mkdir(SubFolder)
            end
            movefile(FileName,SubFolder)
        else
            if ~exist('ProbablyJunk','dir')
                mkdir('ProbablyJunk')
            end
            movefile(FileName,'ProbablyJunk')
        end
    end
end

%% Create OneSession structure and add some info

Directories = dir;
Directories(~[Directories.isdir]==0);
for nDir = 1:size(Directories,1)
    if strcmp(Directories(nDir).name,'.') || strcmp(Directories(nDir).name,'.') ||...
            strcmp(Directories(nDir).name,'Thumbs.db'),  continue,end
    Dirname = Directories(nDir).name;
    
    UnderScores = strfind(Dirname,'_');
    if isempty(UnderScores), continue, end
    Date = str2double(rootFolder(Slash+1:end));
    Session = str2double(Dirname(UnderScores(1)+1:UnderScores(1)+3));
    FileName_OneSession = ['OneSession_',num2str(Date),'_',num2str(Session),'.mat'];
    
    cd(Dirname)
    FullPath = fullfile(pwd,FileName_OneSession);
    
    if exist(FileName_OneSession,'file') && ~IsOverride
        cd ..
        continue
    end
    
    sOneSession = struct('Folder',[],'Info_from_Excell',[]);
    nLine = find(data(:,1) == Date & data(:,2) == Session) + 1;
    Table = cell2table(raw(nLine+1,1:end-1));
    Table.Properties.VariableNames = raw(1,1:end-1);
    sOneSession.Folder = pwd;
    sOneSession.Info_from_Excell = Table;
    
    save(FullPath,'sOneSession')
    cd ..
end

%%

%rescue MASK and exp_config from junk
if isdir('ProbablyJunk')
    cd ProbablyJunk
    Files = dir('*MASK*');
    for nFile = 1:size(Files,1)
        movefile(Files(nFile).name,'../')
    end
    Files = dir('*exp_config*');
    for nFile = 1:size(Files,1)
        movefile(Files(nFile).name,'../')
    end
end

%Go over folders
cd(rootFolder)
subFolders = dir;
dirFlags = [subFolders.isdir];
subFolders = subFolders(dirFlags);
for nSubfolder = 1:size(subFolders,1)
    if ~isempty(strfind(subFolders(nSubfolder).name,'.')) ||...
            strcmp(subFolders(nSubfolder).name,'ProbablyJunk'), continue,end
    cd(subFolders(nSubfolder).name)
    SubFolder = pwd;
    Im2P_SampleTIFFandAVI_forROI(SubFolder);%Add sample tiff and avi images to sOneSession
    cd ..
end




cd(currDir)