function [ndim, mess] = dnd_checkfields (din)
% Check if the fields in a structure are correct for an nD datastructure
% and check that the contents have the correct type and consistent sizes etc.
%
% Input:
% -------
%   din     Input structure
%
% Output:
% -------
%   ndim    Number of dimensions (0,1,2,3,4). If an error, then returned as empty.
%   mess    Error message if isempty(ndim). If ~isempty(ndim), mess = ''

% Author:
%   T.G.Perring     10/06/2005
%
% $Revision$ ($Date$)
%
% Horace v0.1   J.Van Duijn, T.G.Perring

first_names = {'file';'title';'grid';'a';'b';'c';'alpha';'beta';'gamma';'u';'ulen';'label';'p0';'pax'};
last_names  = {'iax';'uint';'s';'e';'n'};
d0d_names = [first_names;last_names];
d1d_names = [first_names;{'p1'};last_names];
d2d_names = [first_names;{'p1';'p2';};last_names];
d3d_names = [first_names;{'p1';'p2';'p3'};last_names];
d4d_names = [first_names;{'p1';'p2';'p3';'p4'};last_names];

ndim=[];
mess='';
if isstruct(din)
    names = fieldnames(din);
    if length(names)==length(d0d_names) && min(strcmp(d0d_names,names))
        ndim=0;
    elseif length(names)==length(d1d_names) && min(strcmp(d1d_names,names))
        ndim=1;
    elseif length(names)==length(d2d_names) && min(strcmp(d2d_names,names))
        ndim=2;
    elseif length(names)==length(d3d_names) && min(strcmp(d3d_names,names))
        ndim=3;
    elseif length(names)==length(d4d_names) && min(strcmp(d4d_names,names))
        ndim=4;
    else
        mess = 'ERROR: Input structure does not have correct fields for an nD dataset';
        return
    end
    % check the contents of each of the fields is valid:
else
    mess = 'ERROR: Input is not a structure';
    return
end

