

vStim_Group = struct('Pulse_Num',[],'Sine150_Dur',[],'Sine100_2000_4000',[],'Sine250_2000_4000',[],'SineFreq',[],...
    'Pulse56',[],'Pulse56Sine100',[],'Pulse56Sine250',[],'Sine100',[],'Sine100Pulse56',[],'Sine250',[],'Sine250Pulse56',[]);

for ii = 1:sOneSession.LastStimToUse
    %Group 1 : Pulse_Num
    if ~isempty(strfind(sOneSession.LOGfile.stimFileName{ii},'pulseTrain_16PDUR_20PPAU_')) &&...
            isempty(strfind(sOneSession.LOGfile.stimFileName{ii},'sine')) &&...
            isempty(strfind(sOneSession.LOGfile.stimFileName{ii},'_56')) && isempty(strfind(sOneSession.LOGfile.stimFileName{ii},'_112'))
        vStim_Group.Pulse_Num = [vStim_Group.Pulse_Num ii];
    end
    
    %Group 2 : Sine150_Dur
    if ~isempty(strfind(sOneSession.LOGfile.stimFileName{ii},'SIN_150_'))
        vStim_Group.Sine150_Dur = [vStim_Group.Sine150_Dur ii];
    end
    
    %Group 3: Sine100_2000_4000
    if ~isempty(strfind(sOneSession.LOGfile.stimFileName{ii},'SIN_100_0_'))
        vStim_Group.Sine100_2000_4000 = [vStim_Group.Sine100_2000_4000 ii];
    end
    
    %Group 4: Sine250_2000_4000
    if ~isempty(strfind(sOneSession.LOGfile.stimFileName{ii},'SIN_250_0_'))
        vStim_Group.Sine250_2000_4000 = [vStim_Group.Sine250_2000_4000 ii];
    end
    
    %Group 5: SineFreq
    if ~isempty(strfind(sOneSession.LOGfile.stimFileName{ii},'_4000_100'))
        vStim_Group.SineFreq = [vStim_Group.SineFreq ii];
    end
    
    %Group 6: pulse-sine
    if ~isempty(strfind(sOneSession.LOGfile.stimFileName{ii},'pulseTrain_16PDUR_20PPAU_56PNUM_250PCAR'))
        vStim_Group.Pulse56 = [vStim_Group.Pulse56 ii];
    elseif ~isempty(strfind(sOneSession.LOGfile.stimFileName{ii},'pulseTrain_16PDUR_20PPAU_56PN_250CAR__sine_2000DUR_100CAR'))
        vStim_Group.Pulse56Sine100 = [vStim_Group.Pulse56Sine100 ii];
    elseif ~isempty(strfind(sOneSession.LOGfile.stimFileName{ii},'pulseTrain_16PDUR_20PPAU_56PN_250CAR__sine_2000DUR_250CAR'))
        vStim_Group.Pulse56Sine250 = [vStim_Group.Pulse56Sine250 ii];
    end
    
    %Group 7: sine-pulse
    if ~isempty(strfind(sOneSession.LOGfile.stimFileName{ii},'SIN_100_0_2000_100'))
        vStim_Group.Sine100 = [vStim_Group.Sine100 ii];
    elseif ~isempty(strfind(sOneSession.LOGfile.stimFileName{ii},'sine_2000DUR_100CAR__pulseTrain_16PDUR_20PPAU_56PN_250CAR'))
        vStim_Group.Sine100Pulse56 = [vStim_Group.Sine100Pulse56 ii];
    elseif ~isempty(strfind(sOneSession.LOGfile.stimFileName{ii},'SIN_250_0_2000_100'))
        vStim_Group.Sine250 = [vStim_Group.Sine250 ii];
    elseif ~isempty(strfind(sOneSession.LOGfile.stimFileName{ii},'sine_2000DUR_250CAR__pulseTrain_16PDUR_20PPAU_56PN_250CAR'))
        vStim_Group.Sine250Pulse56 = [vStim_Group.Sine250Pulse56 ii];
    end
      
end