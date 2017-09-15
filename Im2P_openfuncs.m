%opening the scripts/functions needed for the part of the Im2P pipeline
%that is done localy

edit Im2P_CreateFolders_OnePerSession.m %make one session per folder

edit Im2P_BatchfindROIs.m %mark ROI in each folder

edit Im2P_FindFoldersToTrack.m %create a list of folders to track that will be used by Spock cluster

edit Im2P_VisualizeSession.m %visualize each session

edit Im2P_CollectData.m %collect all data to a single table