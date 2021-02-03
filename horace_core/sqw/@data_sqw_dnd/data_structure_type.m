function data_type = data_structure_type(data)
% Determine data type of the data field of an sqw data structure
%
%   >> type = data_structure_type(data)
%
% Input:
% ------
%   data        Data field of sqw structure
%
% Output:
% -------
%   data_type   ='b'  (prototype),
%               ='b+' (dnd type)
%               ='a'  (valid sqw type)
%               ='a-' (sqw without pix)
%               ='h'  (header part of data structure only)
%
% Simple routine - it assumes that the data structure actually has
% one of the above formats.

% T.G.Perring   02/08/2007

if ~isfield(data,'s');      data_type = 'h';  return; end
if ~isfield(data,'npix');   data_type = 'b+';  return; end
% should not exist such type in new classes
%if ~isfield(data,'u range'); data_type = 'b+'; return; end
if ~isfield(data,'pix');    data_type = 'a-'; return; end
data_type = 'a';
