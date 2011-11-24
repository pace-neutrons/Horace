function axis = IX_axis(varargin)
% Create IX_axis object
%   >> w = IX_axis (caption)
%   >> w = IX_axis (caption, units)
%   >> w = IX_axis (caption, units, code)
%
%  Creates an IX_axis object with the following elements:
%
% 	caption		char        Caption for axis
%                          (Caption can be multiline input in the form of a
%                           cell array or a character array)
%   units       char        Units for axis
%   code        char        Code for units (see documentation for built-in units;
%                          can also be user-defined unit code)

% Default class
% (should make this call checkfields, but is so simple...)
if nargin==0
    axis.caption={};
    axis.units='';
    axis.code='';
    axis=class(axis,'IX_axis');
    return
end

% Various input options
if nargin==1 && isa(varargin{1},'IX_axis')  % if already IX_axis object, return
    axis=varargin{1};
    
elseif nargin==1 && isstruct(varargin{1})   % structure input
    [ok,mess,axis]=checkfields(varargin{1});   % Make checkfields the ultimate arbiter of the validity of a structure
    if ok, axis=class(axis,'IX_axis'); return, else error(mess); end

elseif nargin==1 && ~isempty(varargin{1}) && ischar(varargin{1}) && size(varargin{1},1)==1 && varargin{1}(1)=='$' % built-in unit code
    error('No built-in units implemented at present')

elseif nargin<=3
    if nargin>=1 && ~isempty(varargin{1})
        axis.caption=varargin{1};
    else
        axis.caption={};
    end

    if nargin>=2 && ~isempty(varargin{2})
        axis.units=varargin{2};
    else
        axis.units='';
    end

    if nargin>=3 && ~isempty(varargin{3})
        axis.code=varargin{3};
    else
        axis.code='';
    end
    [ok,mess,axis]=checkfields(axis);   % Make checkfields the ultimate arbiter of the validity of a structure
    if ok, axis=class(axis,'IX_axis'); return, else error(mess); end
else
    error('Check number of arguments')
end
