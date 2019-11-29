function this = load(this,varargin)
% Load all data, defined by loader in memory
%
%presumes that data file name and par file name (if necessary)
%are already set up

% -reload  if option is present, reloads data into memory even
%          if they have already been loaded
%
if isempty(this.loader)
    error('RUNDATA:undefined','attempt to load data in memory when data file is not defined')
end
options = {'-reload'};
[ok,mess,reload]=parse_char_options(varargin,options);
if ~ok
    error('RUNDATA:invalid_argument',mess);
end

this = this.load_all_(reload);
end
