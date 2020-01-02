function    obj = put_sqw(obj,varargin)
% Save dnd data into new binary file or fully overwrite an existing file
%
% store header, which describes file as dnd file
%
%
% $Revision:: 1758 ($Date:: 2019-12-16 18:18:50 +0000 (Mon, 16 Dec 2019) $)
%
obj = obj.put_dnd(varargin{:});

