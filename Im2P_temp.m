%manual fix of Laser-On from the avi movies

CurrDir = cd();
if strcmp(Folder,'Z:\Dudi\Imaging\2Photon\Dudi_setup\DSX_VR2P_Auditory\20170425\20170425_210')
    cd(Folder)
    filename = dir('OneSession*');  filename  = filename(1).name;
    load(filename)
    datfile = dir('*.dat'); datfile = datfile(1).name;
    DAT = importdata(datfile);
    sOneSession.LaserOffFrame = size(DAT,1);
    sOneSession.LaserOnFrame = 366;
    save(filename,'sOneSession')
elseif strcmp(Folder,'Z:\Dudi\Imaging\2Photon\Dudi_setup\DSX_VR2P_Auditory\20170426\20170426_102')
    cd(Folder)
    filename = dir('OneSession*');  filename  = filename(1).name;
    load(filename)
    datfile = dir('*.dat'); datfile = datfile(1).name;
    DAT = importdata(datfile);
    sOneSession.LaserOffFrame = size(DAT,1);
    sOneSession.LaserOnFrame = 381;
    save(filename,'sOneSession')
elseif  strcmp(Folder,'Z:\Dudi\Imaging\2Photon\Dudi_setup\DSX_VR2P_Auditory\20170426\20170426_103')
    cd(Folder)
    filename = dir('OneSession*');  filename  = filename(1).name;
    load(filename)
    datfile = dir('*.dat'); datfile = datfile(1).name;
    DAT = importdata(datfile);
    sOneSession.LaserOffFrame = size(DAT,1);
    sOneSession.LaserOnFrame = 293;
    save(filename,'sOneSession')
elseif  strcmp(Folder,'Z:\Dudi\Imaging\2Photon\Dudi_setup\DSX_VR2P_Auditory\20170511\20170511_102')
    cd(Folder)
    filename = dir('OneSession*');  filename  = filename(1).name;
    load(filename)
    datfile = dir('*.dat'); datfile = datfile(1).name;
    DAT = importdata(datfile);
    sOneSession.LaserOffFrame = size(DAT,1);
    sOneSession.LaserOnFrame = 219;
    save(filename,'sOneSession')
elseif  strcmp(Folder,'Z:\Dudi\Imaging\2Photon\Dudi_setup\DSX_VR2P_Auditory\20170511\20170511_203')
    cd(Folder)
    filename = dir('OneSession*');  filename  = filename(1).name;
    load(filename)
    datfile = dir('*.dat'); datfile = datfile(1).name;
    DAT = importdata(datfile);
    sOneSession.LaserOffFrame = size(DAT,1);
    sOneSession.LaserOnFrame = 381;
    save(filename,'sOneSession')
elseif  strcmp(Folder,'Z:\Dudi\Imaging\2Photon\Dudi_setup\DSX_VR2P_Auditory\20170518\20170518_202')
    cd(Folder)
    filename = dir('OneSession*');  filename  = filename(1).name;
    load(filename)
    datfile = dir('*.dat'); datfile = datfile(1).name;
    DAT = importdata(datfile);
    sOneSession.LaserOffFrame = size(DAT,1);
    sOneSession.LaserOnFrame = 381;
    save(filename,'sOneSession')
elseif  strcmp(Folder,'Z:\Dudi\Imaging\2Photon\Dudi_setup\DSX_VR2P_Auditory\20170518\20170518_302')
    cd(Folder)
    filename = dir('OneSession*');  filename  = filename(1).name;
    load(filename)
    datfile = dir('*.dat'); datfile = datfile(1).name;
    DAT = importdata(datfile);
    sOneSession.LaserOffFrame = size(DAT,1);
    sOneSession.LaserOnFrame = 385;
    save(filename,'sOneSession')
elseif  strcmp(Folder,'Z:\Dudi\Imaging\2Photon\Dudi_setup\DSX_VR2P_Auditory\20170518\20170518_403')
    cd(Folder)
    filename = dir('OneSession*');  filename  = filename(1).name;
    load(filename)
    datfile = dir('*.dat'); datfile = datfile(1).name;
    DAT = importdata(datfile);
    sOneSession.LaserOffFrame = size(DAT,1);
    sOneSession.LaserOnFrame = 385;
    save(filename,'sOneSession')
elseif  strcmp(Folder,'Z:\Dudi\Imaging\2Photon\Dudi_setup\DSX_VR2P_Auditory\20170523\20170523_102')
    cd(Folder)
    filename = dir('OneSession*');  filename  = filename(1).name;
    load(filename)
    datfile = dir('*.dat'); datfile = datfile(1).name;
    DAT = importdata(datfile);
    sOneSession.LaserOffFrame = size(DAT,1);
    sOneSession.LaserOnFrame = 393;
    save(filename,'sOneSession')
elseif  strcmp(Folder,'Z:\Dudi\Imaging\2Photon\Dudi_setup\DSX_VR2P_Auditory\20170523\20170523_104')
    cd(Folder)
    filename = dir('OneSession*');  filename  = filename(1).name;
    load(filename)
    datfile = dir('*.dat'); datfile = datfile(1).name;
    DAT = importdata(datfile);
    sOneSession.LaserOffFrame = size(DAT,1);
    sOneSession.LaserOnFrame = 394;
    save(filename,'sOneSession')
elseif  strcmp(Folder,'Z:\Dudi\Imaging\2Photon\Dudi_setup\DSX_VR2P_Auditory\20170523\20170523_203')
    cd(Folder)
    filename = dir('OneSession*');  filename  = filename(1).name;
    load(filename)
    datfile = dir('*.dat'); datfile = datfile(1).name;
    DAT = importdata(datfile);
    sOneSession.LaserOffFrame = size(DAT,1);
    sOneSession.LaserOnFrame = 389;
    save(filename,'sOneSession')
elseif  strcmp(Folder,'Z:\Dudi\Imaging\2Photon\Dudi_setup\DSX_VR2P_Auditory\20170523\20170523_206')
    cd(Folder)
    filename = dir('OneSession*');  filename  = filename(1).name;
    load(filename)
    datfile = dir('*.dat'); datfile = datfile(1).name;
    DAT = importdata(datfile);
    sOneSession.LaserOffFrame = size(DAT,1);
    sOneSession.LaserOnFrame = 389;
    save(filename,'sOneSession')
elseif  strcmp(Folder,'Z:\Dudi\Imaging\2Photon\Dudi_setup\DSX_VR2P_Auditory\20170525\20170525_205')
    cd(Folder)
    filename = dir('OneSession*');  filename  = filename(1).name;
    load(filename)
    datfile = dir('*.dat'); datfile = datfile(1).name;
    DAT = importdata(datfile);
    sOneSession.LaserOffFrame = size(DAT,1);
    sOneSession.LaserOnFrame = 385;
    save(filename,'sOneSession')
elseif  strcmp(Folder,'Z:\Dudi\Imaging\2Photon\Dudi_setup\DSX_VR2P_Auditory\20170525\20170525_206')
    cd(Folder)
    filename = dir('OneSession*');  filename  = filename(1).name;
    load(filename)
    datfile = dir('*.dat'); datfile = datfile(1).name;
    DAT = importdata(datfile);
    sOneSession.LaserOffFrame = size(DAT,1);
    sOneSession.LaserOnFrame = 385;
    save(filename,'sOneSession')
end


cd(CurrDir)