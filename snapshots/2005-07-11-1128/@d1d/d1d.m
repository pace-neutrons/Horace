function w = d1d (din)
% D1D   Create a class object from the structure of a 1D dataset.
%
% Syntax:
%   >> w = d1d (din)    % din is the structure; w the corresponding output class
%                       % If din is already a 1D dataset, then w = din
%
% Input:
% ------
% din         Data from which a reduced dimensional manifold is to be taken. Its fields are:
%   din.file  File from which (h,k,l,e) data was read
%   din.grid  Type of grid ('orthogonal-grid')
%   din.title Title contained in the file from which (h,k,l,e) data was read
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
%   din.p0    Offset of origin of projection [ph; pk; pl; pen]
%   din.pax   Index of plot axes in the matrix din.u  [row vector]
%               e.g. if data is 3D, din.pax=[2,4,1] means u2, u4, u1 axes are x,y,z in any plotting
%                               2D, din.pax=[2,4]     "   u2, u4,    axes are x,y   in any plotting
%   din.p1    Column vector of bin boundaries along first plot axis
%   din.p2    Column vector of bin boundaries along second plot axis
%     :       (for as many plot axes as given by length of din.pax)
%   din.iax   Index of integration axes in the matrix din.u
%               e.g. if data is 2D, din.iax=[3,1] means summation has been performed along u3 and u1 axes
%   din.uint  Integration range along each of the integration axes. Dimensions are uint(2,length(iax))
%               e.g. in 2D case above, is the matrix vector [u3_lo, u1_lo; u3_hi, u1_hi]
%   din.s     Cumulative signal.  [size(din.s)=(length(din.p1)-1, length(din.p2)-1, ...)]
%   din.e     Cumulative variance [size(din.e)=(length(din.p1)-1, length(din.p2)-1, ...)]
%   din.n     Number of contributing pixels [size(din.n)=(length(din.p1)-1, length(din.p2)-1, ...)]
%
% Output:
% -------
% w is a class with precisely the same fields

superiorto('spectrum');

if strcmp(class(din),'d1d')
    w = din;
else
    [ndim, mess] = dnd_checkfields(din);
    if ~isempty(ndim)
        w = class (din, 'd1d');
    else
        error (mess)
    end
end
