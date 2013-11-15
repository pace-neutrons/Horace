function type = data_type_file(position)
% Determine sqw type from the position block oread from an sqw file
%
%   >> type = data_type_file(position)
%
% Input:
% ------
%   data        Positional information block read from sqw file
%
% Output:
% -------
%   type        ='b','b+' 'a' (valid sqw type) or 'a-' (sqw without pix)
%               ='h' if header part of data structure only
%
% Simple routine - the assumption is that the data file corresponds to a valid type

% T.G.Perring   24/02/2013


if isempty(position.s);     type = 'h';  return; end
if isempty(position.npix);  type = 'b';  return; end
if isempty(position.urange);type = 'b+'; return; end
if isempty(position.pix);   type = 'a-'; return; end
type = 'a';
