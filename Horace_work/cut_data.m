function dout = cut_data (din, varargin)

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
%   din.label Labels of theprojection axes [1x4 cell array of charater strings]
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
% iax_1       Further axes to integrate along. The labels of these axes is not those that appear in
%             the matrix din.u, but are indexes into din.pax. 
%               e.g. in the 2D case above if iax=2 then this refers to u4, as din.pax(2)=4
%             This is so that the user can refer to the axes of his/her plot when determining the
%             next integration axis.
%
% iax_1_range Integration range [iax_lo,iax_hi] for first additional integration axis
%
% iax_2       -| The same for second additional
% iax_2_range -| integration axis
%
%   :
%
% Output:
% -------
% dout        Output data structure. Its elements are the same as those of din, appropriately updated.
%
%
% Examples:
%   >> dout = cut_data (din, 2, [1.9,2.1], 3 [-0.55,-0.45]) % sum along y and z axes
%                                                           %(din must be a 3D or 4D data structure)

% Author:
%   T.G.Perring     20/06/2005
% Modified:
%
% Horace v0.1   J.Van Duijn, T.G.Perring

tic
if nargin==1    % trivial case - no integration, so return
    dout = din;
    return
elseif ~(nargin==3|nargin==5|nargin==7|nargin==9)
    error ('ERROR - Check number of arguments')
end

% Get integration parameters:
niax = floor((nargin-1)/2);
pax_ind = linspace(1,length(din.pax),length(din.pax));
for i=1:niax
    iax_ind(i) = varargin{2*i-1};
    if iax_ind(i) < 1 | iax_ind(i) > length(din.pax)
        error(['ERROR: Integration axis index/indices must lie in range 1 to ',num2str(length(din.pax))])
    end
    pax_ind = pax_ind(find(pax_ind~=iax_ind(i)));
    uint(1:2,i) = varargin{2*i}';
end
iax = din.pax(iax_ind);
pax = din.pax(pax_ind);

% Check integration parameters:
if min(diff(sort(iax)))==0
    error('ERROR: Integration axes must be distinct')
end
for i=1:niax
    if uint(1,i)>=uint(2,i)
        error ('ERROR: Integration ranges must have all have lower_value < upper_value')
    end
end


% Perform summation along the additional integration axes. Perform the summantion along the
% highest axis index - this allows succesive calls of routines that reduce dimension by one
% without the need for sophisticated book-keeping.
% [There may be cleverer ways to do this for the general n to m (n>=m>=0) reduction, but in 
% the present case of 4 or fewer dimensions this is good enough]

signal = din.s;
errors = din.e;
nbins = din.n;

[idim,ind] = sort(iax_ind);     % get plot axes over which to integrate in increasing order
ilims = uint(:,ind);            % corresponding integration limits
idim = fliplr(idim);            % now get plot axes over which to integrate in decreasing order
ilims = fliplr(ilims);          % corresponding integration limits
for i=1:niax
    pvals_name = ['p', num2str(idim(i))];   % name of field containing bin boundaries for the plot axis to be integrated over
    pvals = din.(pvals_name);               % values of bin boundaries (use dynamic field names facility of Matlab)
    pcent = 0.5*(pvals(2:end)+pvals(1:end-1));          % values of bin centres
    lis=find(pcent>=ilims(1,i) & pcent<=ilims(2,i));    % indices of bins whose centres lie within or at boundaries of integration range
    if ~isempty(lis)
        ilo = lis(1);
        ihi = lis(end);
    else
        error ('ERROR: No data in the requested cut')
    end
    [signal,errors,nbins] = cut_data_arrays (idim(i), ilo, ihi, signal, errors, nbins);
end


% Fill up the output data structure
% Unchanged items:
dout.file = din.file;
dout.title = din.title;
dout.a = din.a;
dout.b = din.b;
dout.c = din.c;
dout.alpha = din.alpha;
dout.beta = din.beta;
dout.gamma = din.gamma;
dout.u = din.u;
dout.ulen = din.ulen;
dout.label = din.label;
dout.p0 = din.p0;

% Changed items:
dout.pax = pax; 
for i=1:length(pax_ind)
    pvals_name_in = ['p', num2str(pax_ind(i))];
    pvals_name_out= ['p', num2str(i)];
    dout.(pvals_name_out) = din.(pvals_name_in);
end
dout.iax = [din.iax, iax];
dout.uint = [din.uint, uint];
dout.s = signal;
dout.e = errors;
dout.n = nbins;
toc
