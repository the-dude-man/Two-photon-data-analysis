function sOneSession = Im2P_OneSession_PreAnalysis(Folder, IsOverride, IsOverrideDFF)
%Dudi Deutsch, Princeton, Nov 2016

%Pipeline for Im2P (imaging with 2P microscope) analysis
%Before running this function, need to run: For each date: Im2P_CreateFolders_OnePerSession.m, for each folder:Im2P_findROIs.m

%Use Im2P_Batch_OneSession_PreAnalysis to run Im2P_OneSession_PreAnalysis for all the folders in the master folder

%default: don't override
if nargin == 1, IsOverride = 0; IsOverrideDFF = 0; 
elseif nargin == 2, IsOverrideDFF = 0; 
end

%If running on the cluster, give each worker access to the Im2P functions
if isunix 
WorkingDirectory = '/jukebox/murthy/Dudi/MatlabProg/Imaging2P';
addpath(genpath(WorkingDirectory))
end

disp(['Running the function Im2P_OneSession_PreAnalysis on folder ',Folder,'. IsOverride is set to ',num2str(IsOverride)])
disp(['Time: ',datestr(datetime('now'))])

%After creating a subfolder for each session, run this pipeline for each session - 

% Before this pipeline, need to run:
% matl(1)
% Im2P_CreateFolders_OnePerSession(rootFolder), or run over all the Masater folder - 
% Im2P_BatchCreateFolder(MasterFolder,Override)
% (2)
% Im2P_findROIs(Folder) - User defines ROIs for AVI and for Tifs,  or run over all the Masater folder - 
% Im2P_BatchfindROIs(MasterFolder,Override)

%TEMP - adding laser ON time 
%Im2P_temp
%TEMP

sOneSession = Im2P_find_LaserONOFF_inAVI(Folder, IsOverride);


if isa(sOneSession,'double') && sOneSession == -1, return, end%missing structure sOneSession

Im2P_sync_samplesTifs(Folder, IsOverride);%Sample number for each TiffFrame


Im2P_Check_timestamps(Folder, IsOverride);%Check timestamps and look for jumps in the avi files

if ~isunix
Im2P_findROIs(Folder, IsOverrideDFF);%in case the ROI is not defined yet(but only when run on PC)
end

Im2P_sync_samplesAvi(Folder, IsOverride);%sample number for each AviFrame


Im2P_AddStimData(Folder, IsOverride);%Adds the info regarding stimuli


Im2P_DFF(Folder, IsOverrideDFF);%Finds DF/F in each ROI


sOneSession = Im2P_AddTracking(Folder, IsOverride);%Add tracking from FicTrac

disp(['Finished running Im2P_OneSession_PreAnalysis with folder ',Folder])
disp(['Time: ',datestr(datetime('now'))])

%After this pipeline is done, can do:
%sOneSession = Im2P_VisualizeSession(Folder)%Visualize all the session, and trial by trial
%and update the column "use" in the excell table - remove if no response or too much motion in Z
%...and finaly - data analysis... - 

end