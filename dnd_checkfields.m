function [ndim, mess] = dnd_checkfields (din)
% Check if the fields in a structure are correct for an nD datastructure (n=0,1,2,3,4)
% and check that the contents have the correct type and consistent sizes etc.
%
% Input:
% -------
%   din     Input structure.
%
% Output:
% -------
%   ndim    Number of dimensions (0,1,2,3,4). If an error, then returned as empty.
%   mess    Error message if isempty(ndim). If ~isempty(ndim), mess = ''
%
%
% The correct fields for a valid n-dimensional data structure are:
%
%   din.file  File from which (h,k,l,e) data was read [Character string]
%   din.grid  Type of grid ('orthogonal-grid') [Character string]
%   din.title Title contained in the file from which (h,k,l,e) data was read [Character string]
%   din.a     Lattice parameters (Angstroms)
%   din.b           "
%   din.c           "
%   din.alpha Lattice angles (degrees)
%   din.beta        "
%   din.gamma       "
%   din.u     Matrix (4x4) of projection axes in original 4D representation
%              u(:,1) first vector - u(1:3,1) r.l.u., u(4,1) energy etc.
%   din.ulen  Length of vectors in Ang^-1 or meV [row vector]
%   din.label Labels of the projection axes [1x4 cell array of charater strings]
%   din.p0    Offset of origin of projection [ph; pk; pl; pen] [column vector]
%   din.pax   Index of plot axes in the matrix din.u  [row vector]
%               e.g. if data is 3D, din.pax=[2,4,1] means u2, u4, u1 axes are x,y,z in any plotting
%                               2D, din.pax=[2,4]     "   u2, u4,    axes are x,y   in any plotting
%   din.iax   Index of integration axes in the matrix din.u
%               e.g. if data is 2D, din.iax=[3,1] means summation has been performed along u3 and u1 axes
%   din.uint  Integration range along each of the integration axes. Dimensions are uint(2,length(iax))
%               e.g. in 2D case above, is the matrix vector [u3_lo, u1_lo; u3_hi, u1_hi]
%   din.p1    Column vector of bin boundaries along first plot axis
%   din.p2    Column vector of bin boundaries along second plot axis
%     :       (for as many plot axes as given by length of din.pax)
%   din.s     Cumulative signal.  [size(din.s)=(length(din.p1)-1, length(din.p2)-1, ...)]
%   din.e     Cumulative variance [size(din.e)=(length(din.p1)-1, length(din.p2)-1, ...)]
%   din.n     Number of contributing pixels [size(din.n)=(length(din.p1)-1, length(din.p2)-1, ...)]
%             If 0D, 1D, 2D, 3D, din.n is a double; if 4D, din.n is int32


% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Horace v0.1   J.Van Duijn, T.G.Perring

first_names = {'file';'grid';'title';'a';'b';'c';'alpha';'beta';'gamma';'u';'ulen';'label';'p0';'pax';'iax';'uint'};
last_names  = {'s';'e';'n'};
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

