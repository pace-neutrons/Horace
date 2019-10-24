function    obj = put_sqw(obj,varargin)
% Save dnd data into new binary file or fully overwrite an existing file
%
% store header, which describes file as dnd file
%
%
% $Revision:: 1753 ($Date:: 2019-10-24 20:46:14 +0100 (Thu, 24 Oct 2019) $)
%
obj = obj.put_dnd(varargin{:});
