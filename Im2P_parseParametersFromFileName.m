function param = Im2P_parseParametersFromFileName(string)
% param = parseParametersFromFileName(string)
% specialNames:
% "pulseTrain_XXIPI', pulseTrain_PDURXX_..."
% "SIN_FREQ_PHASE_DURATION"
% "PUL_DUR_PAU_NUM_DEL"

token = strsplit(string, '_');

% init
param = struct('stimType',[],'pcar',[],'ipi',[],'pdur',[],'ppau',[],'tdur',[], 'pnum',[],'delay',[],'car',[],'phase',[]','dur',[]);
param.stimType = lower(token{1});

para2num = @(str) str2double(regexp(str,'-?\d+\.?\d*|-?\d*\.?\d+','match'));
if strncmp(string, 'SIN_',4)
   parameterStrings = {'CAR', 'PHASE', 'DUR'};
   for para = 1:length(parameterStrings)
      param.(lower(parameterStrings{para})) = para2num(token{para+1});
   end
end

if strncmp(string, 'PUL_',4)
   parameterStrings = {'PDUR', 'PPAU', 'PNUM', 'DELAY'};
   for para = 1:length(parameterStrings)
      param.(lower(parameterStrings{para})) = para2num(token{para+1});
   end
end

if strncmp(string, 'pulseTrain_',11)
   parameterStrings = {'PDUR', 'PPAU', 'PCAR', 'TDUR', 'PNUM', 'Hz', 'IPI'};
   for para = 1:length(parameterStrings)
      tokenHits = find(~cellfun(@isempty, strfind(token, parameterStrings{para})));
      if ~isempty(tokenHits)
         thisToken = token{tokenHits};
         if para==length(parameterStrings) % IPI - so we fill in all the rest
            param.(lower(parameterStrings{para})) = para2num(thisToken(1:end-3));
            param.pdur = 16;
            param.ppau = param.ipi-param.pdur;
            if isempty(param.pcar)% do not overwrite 'Hz'
               param.pcar = 250;
            end
            param.tdur = 4;
         elseif para==length(parameterStrings)-1 %Hz
            param.pcar = para2num(thisToken);
         else % infer param names from stimName
            param.(lower(parameterStrings{para})) = para2num(thisToken);
         end
      end
   end
   param.ipi = param.pdur+param.ppau;
end
