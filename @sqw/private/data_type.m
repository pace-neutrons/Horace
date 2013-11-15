function type = data_type(data)
% Determine sqw type from the data component of an sqw data structure
%
%   >> type = data_type(data)
%
% Input:
% ------
%   data        data componenet of sqw structure
%
% Output:
% -------
%   type        ='b','b+' 'a' (valid sqw type) or 'a-' (sqw without pix)
%               ='h' if header part of data structure only
%
% Simple routine - the assumption is that the data corresponds to a valid type
% Needs full data structure, not just the header fields

% T.G.Perring   02/08/2007

if ~isfield(data,'s');      type = 'h';  return; end
if ~isfield(data,'npix');   type = 'b';  return; end
if ~isfield(data,'urange'); type = 'b+'; return; end
if ~isfield(data,'pix');    type = 'a-'; return; end
type = 'a';
