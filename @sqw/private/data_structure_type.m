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
%               ='sp' (sparse data section format)
%
% Simple routine - it assumes that the data structure actually has
% one of the above formats.

% T.G.Perring   02/08/2007

if issparse(data.s)
    if isfield(data,'npix_nz');
        data_type = 'sp'; return
    else
        data_type = 'sp-'; return
    end
end

if ~isfield(data,'s');      data_type = 'h';  return; end
if ~isfield(data,'npix');   data_type = 'b';  return; end
if ~isfield(data,'urange'); data_type = 'b+'; return; end
if ~isfield(data,'pix');    data_type = 'a-'; return; end
data_type = 'a';
