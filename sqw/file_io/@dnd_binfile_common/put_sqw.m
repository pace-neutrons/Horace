function    obj = put_sqw(obj,varargin)
% Save dnd data into new binary file or fully overwrite an existing file
%
% store header, which describes file as dnd file
%
%
% $Revision$ ($Date$)
%
obj = obj.put_dnd(varargin{:});
