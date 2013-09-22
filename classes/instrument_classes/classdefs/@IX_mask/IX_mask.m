function wout=IX_mask(varargin)
% Constructor for IX_map object. There are numerous ways to specify the map
%
%   >> w = IX_mask(filename)        % Read from ascii file
%   >> w = IX_mask(iarray)          % Array of spectra to be masked
%
% A mask object contains a list of spectra to be masked, where all spectrum
% numbers are greater than or equal to one. The array is sorted into
% numerically increasing order, with duplicates removed.

% Original author: T.G.Perring

classname='IX_mask';

% Catch default constructor or existing IX_map
% --------------------------------------------
if nargin==0
    % Default constructor: empty array
    wout.msk=zeros(1,0);
    [ok,mess,wout]=checkfields(wout);   % Make checkfields the ultimate arbiter of the validity of a structure
    if ok, wout = class(wout,classname); return, else error(mess); end
    
elseif nargin==1 && isa(varargin{1},classname)
    % Is a mask object already
    wout = varargin{1};
    return
end


% Handle other cases
% ------------------
if nargin==1
    if isstruct(varargin{1})
        % Structure with the fields of a mask object is permitted
        wout = varargin{1};
        
    elseif isstring(varargin{1})
        % File name input
        if ~isempty(varargin{1})
            [wout,ok,mess]=get_mask(varargin{1});
        else
            error('File name cannot be an empty string')
        end
        
    elseif isnumeric(varargin{1}) && all(rem(varargin{1}(:),1)==0) && all(varargin{1})>0
        wout.msk=varargin{1};
        
    else
        error('Input argument must be an array of positive integers or a file name')
    end
    
else
    error('Check number and/or type of arguments')
    
end

[ok,mess,wout]=checkfields(wout);   % Make checkfields the ultimate arbiter of the validity of a structure
if ok, wout = class(wout,classname); return, else error(mess); end
