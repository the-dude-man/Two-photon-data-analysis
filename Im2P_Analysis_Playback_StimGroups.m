

vStim_Group = struct('PauseDur',[],'Sine',[],'Intensity',[],'Carrier',[],'SinePulse',[],'PulseSine',[],'IPI',[]);

for ii = 1:sOneSession.LastStimToUse
    %Group 1 : pause-dur
    if ~isempty(sOneSession.StimParams{ii}.pdur) && ~isempty(sOneSession.StimParams{ii}.ppau) &&...
            ~isempty(sOneSession.StimParams{ii}.Intensity) && sOneSession.StimParams{ii}.Intensity == 4 &&...
            ((isempty(sOneSession.StimParams{ii}.pcar)) || (~isempty(sOneSession.StimParams{ii}.pcar) &&...
            sOneSession.StimParams{ii}.pcar == 250)) &&...
            isempty(strfind(sOneSession.LOGfile{ii,1}{1},'sine'))
        vStim_Group.PauseDur = [vStim_Group.PauseDur ii];
    end
    
    %Group 2 : sine
    if (~isempty(sOneSession.StimParams{ii}.car))
        vStim_Group.Sine = [vStim_Group.Sine ii];
    end
    
    %Group 3: Intensity
    if ~isempty(sOneSession.StimParams{ii}.pcar) && sOneSession.StimParams{ii}.pcar == 250 &&...
            ~isempty(sOneSession.StimParams{ii}.ipi) && sOneSession.StimParams{ii}.ipi == 36 &&...
            ~isempty(sOneSession.StimParams{ii}.pdur) && sOneSession.StimParams{ii}.pdur == 16
        vStim_Group.Intensity = [vStim_Group.Intensity ii];
    end
    
    %Group 4: Carrier
    if ~isempty(sOneSession.StimParams{ii}.ipi) && sOneSession.StimParams{ii}.ipi == 36 &&...
            ~isempty(sOneSession.StimParams{ii}.pdur) && sOneSession.StimParams{ii}.pdur == 16 &&...
            ~isempty(sOneSession.StimParams{ii}.Intensity) && sOneSession.StimParams{ii}.Intensity == 4 &&...
            isempty(strfind(sOneSession.LOGfile{ii,1}{1},'sine'))
        vStim_Group.Carrier = [vStim_Group.Carrier ii];
    end
    
    %Group 5: SinePulse
    if isempty(sOneSession.StimParams{ii}.car) && isempty(sOneSession.StimParams{ii}.ipi)
        vStim_Group.SinePulse = [vStim_Group.SinePulse ii];
    end
    
    %Group 6: PulseSine
    if ~isempty(sOneSession.StimParams{ii}.pdur) && ~isempty(sOneSession.StimParams{ii}.ppau) &&...
            ~isempty(sOneSession.StimParams{ii}.Intensity) && sOneSession.StimParams{ii}.Intensity == 4 &&...
            ((isempty(sOneSession.StimParams{ii}.pcar)) || (~isempty(sOneSession.StimParams{ii}.pcar) &&...
            sOneSession.StimParams{ii}.pcar == 250)) &&...
            ~isempty(strfind(sOneSession.LOGfile{ii,1}{1},'sine'))
        vStim_Group.PulseSine = [vStim_Group.PulseSine ii];
    end
    
    %Group 7: IPI
    if ~isempty(strfind(sOneSession.LOGfile{ii,1}{1},'pulseTrain_16PDUR')) && ~isempty(strfind(sOneSession.LOGfile{ii,1}{1},'112PNUM'))
        vStim_Group.IPI = [vStim_Group.IPI ii];
    end
    
    
    
end