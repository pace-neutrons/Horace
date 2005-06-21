din.file = 'c:\blobby.dat';
din.title = 'This is a silly test';
din.u = [1,1,0,0; 0,0,1,0; 1,-1,0,0; 0,0,0,1];
din.ulen = [2.828427125, 2, 2.828427125, 1];
din.p0 = [3,1,4,10];
din.pax = [2,4];
din.iax = [3,1];
din.uint = [0.45,0.9;0.55,1.1];

din.s = 

% din         Data from which a reduced dimensional manifold is to be taken. Its fields are:
%   din.file  File from which (h,k,l,e) data was read
%   din.title Title contained in the file from which (h,k,l,e) data was read
%   din.u     Matrix (4x4) of projection axes in original 4D representation
%              u(:,1) first vector - u(1:3,1) r.l.u., u(4,1) energy etc.
%   din.ulen  Length of vectors in Ang^-1, energy
%   din.p0    Offset of origin of projection [ph; pk; pl; pen]
%   din.pax   Index of plot axes in the matrix din.u
%               e.g. if data is 3D, din.pax=[2,4,1] means u2, u4, u1 axes are x,y,z in any plotting
%                               2D, din.pax=[2,4]     "   u2, u4,    axes are x,y   in any plotting
%   din.p1    (Row) vector of bin boundaries along first plot axis
%   din.p2    (Row) vector of bin boundaries along second plot axis
%     :       (for as many plot axes as given by length of din.pax)
%   din.iax   Index of integration axes in the matrix din.u
%               e.g. if data is 2D, din.iax=[3,1] means summation has been performed along u3 and u1 axes
%   din.uint  Integration range along each of the integration axes
%               e.g. in 2D case above, is the matrix vector [u3_lo, u1_lo; u3_hi, u1_hi]
%   din.s     Cumulative signal.  [size(din.s)=(length(din.p1)-1, length(din.p2)-1, ...)]
%   din.e     Cumulative variance [size(din.e)=(length(din.p1)-1, length(din.p2)-1, ...)]
%   din.n     Number of contributing pixels [size(din.n)=(length(din.p1)-1, length(din.p2)-1, ...)]
