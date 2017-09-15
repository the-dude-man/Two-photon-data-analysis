function [CTRL_table,VisualStimOut] = Im2P_readVisStim(Folder)
%Folder = 'Z:\Dudi\Imaging\2Photon\Dudi_setup\DSX_VR2P_Visual\20170814\20170814_test';


%Read the the CTRL (control) file and save as a table
CTRLfile = dir([Folder,filesep(),'CTRL*.txt']);
CTRL_table = readtable(fullfile(Folder,CTRLfile.name));

%add var names (there must be a better way, but anyhow..)
fileID = fopen(fullfile(Folder,CTRLfile.name));
Firstline = fgetl(fileID);
VariableNames = textscan(Firstline,'%s %s %s %s %s %s %s %s %s','Delimiter',',');
fclose(fileID);
for nVar = 1:size(CTRL_table,2)
CTRL_table.Properties.VariableNames(nVar) = VariableNames{nVar};
end


%Read the out file and save as a structure
OUTfile = dir([Folder,filesep(),'*.out']);
fid = fopen(fullfile(Folder,OUTfile.name));
Date = OUTfile.date(1:11);

clear VisualStimOut
VisualStimOut = struct();

nStimNumber = 0;
tline = fgetl(fid);
while ischar(tline)
    Comma = strfind(tline,',');
    if isempty(Comma)
        stimulus = tline;
        tline = fgetl(fid);
        StartTime = tline;
        tline = fgetl(fid);
        Comma = strfind(tline,',');
        nStimNumber = nStimNumber + 1;
        
        VisualStimOut(nStimNumber).Date = Date;
        VisualStimOut(nStimNumber).StartTime =  StartTime;
        VisualStimOut(nStimNumber).Stimulus = stimulus;
        
        nLine = 1;
    end
    VisualStimOut(nStimNumber).Stim_Timestamp(nLine,1) = str2double(tline(1:Comma(1)-1));
    VisualStimOut(nStimNumber).Stim_Coordinates(nLine,1:2) = [str2double(tline(Comma(1)+1:Comma(2)-1)),str2double(tline(Comma(2)+1:end))];
    nLine = nLine + 1;
    
    tline = fgetl(fid);
end
fclose(fid);


if size(CTRL_table,1)~=size(VisualStimOut,2)
disp('Number of lines in the CTRL file do not match the number of trials in the output file. Returning.')
return
end

end



