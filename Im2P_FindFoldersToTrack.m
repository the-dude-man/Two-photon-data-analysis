function Im2P_FindFoldersToTrack(MasterFolder, IsOverride)
%MasterFolder = 'Z:\Dudi\Imaging\2Photon\Diego_setup\DSX_2P_Playback';

% sFolders = Im2P_FindFoldersToTrack(MasterFolder,IsOverride) returns the
% list of folders ready for tracking under MasterFolder. IsOverride=0 (default) means:
% do only folders that are not done yet.

if nargin == 0, IsOverride = 0; end
prefixCluster = 'jukebox/murthy';

CurrDir = cd(MasterFolder);

fileID = fopen('FoldersToProcess.txt','wt');

Dates = dir;

for nDate = 1:size(Dates,1)
    cd(MasterFolder);
    if ~isempty(strfind(Dates(nDate).name,'.')), continue,end % ignore '.','..'
    cd(Dates(nDate).name)
    Folders = dir;
    for nFolder = 1:size(Folders,1)
        cd(MasterFolder)
        cd(Dates(nDate).name)
        if ~isempty(strfind(Folders(nFolder).name,'.')) || ~isempty(strfind(Folders(nFolder).name,'ProbablyJunk')), continue,end % ignore '.','..'
        cd(Folders(nFolder).name)
        MatFiles = dir('OneSession*.mat'); MatFiles = MatFiles.name;
        load(MatFiles)
        Is_TiffROI = isfield(sOneSession,'TiffROI');
        if ~Is_TiffROI
            disp(['No TiffROI defined for ',pwd,' - need to define ROI/s manually before processing.'])
            continue
        elseif ~all(size(sOneSession.TiffROI) == size(sOneSession.ROIname))
            disp(['Sizes of TiffROI and ROIname do not match for ',pwd])
            continue
        elseif isfield(sOneSession,'GreenSignal') && ~isempty(sOneSession.GreenSignal) && ~IsOverride
            continue
        else 
            Directory = pwd;
            S = strfind(Directory,filesep());
            Directory(S) = '/';
            Directory = ['/',prefixCluster,'/',Directory(S(1)+1:end)];
            disp(Directory)
            fprintf(fileID,'%s\n',Directory);
        end
        %if Is_DFF || ~Is_TiffROI  || ~Is_AllROI_DFFcalculated%fix Is_DFF to ~Is_DFF     
    end
end

cd(MasterFolder)

fprintf(fileID,'\n%s\n',['List of folders to process for MasterFolder ',MasterFolder,', list created on ',datestr(clock)]);
fclose(fileID);
cd(CurrDir)
return

end