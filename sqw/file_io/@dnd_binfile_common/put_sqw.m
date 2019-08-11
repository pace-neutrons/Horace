function    obj = put_sqw(obj,varargin)
% Save dnd data into new binary file or fully overwrite an existing file
%
% store header, which describes file as dnd file
%
%
% $Revision:: 1752 ($Date:: 2019-08-11 23:26:06 +0100 (Sun, 11 Aug 2019) $)
%
obj = obj.put_dnd(varargin{:});
