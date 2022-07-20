function obj = load(obj,varargin)
% Load all data, defined by loader in memory
%
%presumes that data file name and par file name (if necessary)
%are already set up

% -reload  if option is present, reloads data into memory even
%          if they have already been loaded
%
if isempty(obj.loader)
    error('HERBERT:rundata:runtime_error',....
         'attempt to load data in memory when data file is not defined')
end
options = {'-reload'};
[ok,mess,reload]=parse_char_options(varargin,options);
if ~ok
    error('HERBERT:rundata:invalid_argument',....
        mess);
end
obj.do_check_combo_arg = false;
obj = obj.load_all_(reload);
obj.do_check_combo_arg = true;
obj = obj.check_combo_arg();
end
