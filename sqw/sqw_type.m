function type = sqw_type(data)
% Determine sqw class type from the data component of an sqw data structure
%
%   >> type = sqw_type(data)
%
%   data        data componenet of sqw structure
%   type        ='b','b+' 'a' (valid sqw type) or 'a-' (sqw without pix)
%
%   Simple routine - the assumption is that the data corresponds to a valid type

% T.G.Perring   02/08/2007

if ~isfield(data,'npix');   type = 'b';  return; end
if ~isfield(data,'urange'); type = 'b+'; return; end
if ~isfield(data,'pix');    type = 'a-'; return; end
type = 'a';
