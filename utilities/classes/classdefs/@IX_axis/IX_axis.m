function axis = IX_axis(varargin)
% Create IX_axis object
%   >> w = IX_axis (caption)
%   >> w = IX_axis (caption, units)
%   >> w = IX_axis (code)           % set cption and units via a standard units code
%   >> w = IX_axis (...,code)       % override caption and/or units from the defined code
%
% Setting custom tick positions and labels
%   >> w = IX_axis (...,vals)           % positions
%   >> w = IX_axis (...,vals,labels)    % positions and labels
%   >> w = IX_axis (...,ticks)          % strucutre with position and tick labels
%
%  Creates an IX_axis object with the following elements:
%
% 	caption		char        Caption for axis
%            or cellstr    (Caption can be multiline input in the form of a
%                           cell array or a character array)
%   units       char        Units for axis e.g. 'meV'
%   code        char        Code for units (see documentation for built-in units;
%                          can also be user-defined unit code)
%
%   vals        numeric     Array of tick positions
%   labels      char        Character array or cellstr of tick labels
%            or cellstr     
%   ticks       structure   Tick information with two fields
%                               positions    tick positions (numeric array)
%                               labels       cell array of tick labels

narg=nargin;

% Default class
% (should make this call checkfields, but is so simple...)
if narg==0
    axis.caption={};
    axis.units='';
    axis.code='';
    axis.ticks=struct('positions',[],'labels',{{}});
    axis=class(axis,'IX_axis');
    return
end

% Various input options
if narg==1 && isa(varargin{1},'IX_axis')  % if already IX_axis object, return
    axis=varargin{1};
    return
    
elseif narg==1 && isstruct(varargin{1})   % structure input
    [ok,mess,axis]=checkfields(varargin{1});   % Make checkfields the ultimate arbiter of the validity of a structure
    if ok, axis=class(axis,'IX_axis'); return, else error(mess); end

elseif narg<=4 && isstruct(varargin{end})    % final argument is structure
    nch=narg-1;
    if nch>=1, axis.caption=varargin{1}; else axis.caption={}; end
    if nch>=2, axis.units=varargin{2};   else axis.units=''; end
    if nch>=3, axis.code=varargin{3};    else axis.code=''; end
    axis.ticks=varargin{end};

elseif narg<=4 && isnumeric(varargin{end})   % final argument is numeric array
    nch=narg-1;
    if nch>=1, axis.caption=varargin{1}; else axis.caption={}; end
    if nch>=2, axis.units=varargin{2};   else axis.units=''; end
    if nch>=3, axis.code=varargin{3};    else axis.code=''; end
    if isempty(varargin{end})
        axis.ticks=struct('positions',[],'labels',{{}});
    else
        axis.ticks=struct('positions',varargin{end}(:)','labels',{{}});
    end

elseif narg>1 && narg<=5 && isnumeric(varargin{end-1}) % penultimate argument is numeric array
    nch=narg-2;
    if nch>=1, axis.caption=varargin{1}; else axis.caption={}; end
    if nch>=2, axis.units=varargin{2};   else axis.units=''; end
    if nch>=3, axis.code=varargin{3};    else axis.code=''; end
    if isempty(varargin{end-1}), ticks.positions=[]; else ticks.positions=varargin{end-1}; end
    if isempty(varargin{end-1}), ticks.labels={}; else ticks.labels=varargin{end}; end
    axis.ticks=ticks;

elseif narg<=3
    nch=narg;
    if nch>=1, axis.caption=varargin{1}; else axis.caption={}; end
    if nch>=2, axis.units=varargin{2};   else axis.units=''; end
    if nch>=3, axis.code=varargin{3};    else axis.code=''; end
    axis.ticks=struct('positions',[],'labels',{{}});

else
    error('Check number and type of arguments')
end

[ok,mess,axis]=checkfields(axis);   % Make checkfields the ultimate arbiter of the validity of a structure
if ok, axis=class(axis,'IX_axis'); return, else error(mess); end
