function dout = cut_data (din, varargin)
% Take a cut from a multi-dimensional dataset and return the reduced dimensional
% dataset.
%
% Syntax:
%   >> dout = cut_data (din, iax_1, iax1_range, iax_2, iax2_range, ...)
%
% Input:
% ------
%   din             Data from which a reduced dimensional manifold is to be taken.
%                  Type >> help dnd_checkfields for a full description of the fields
%
%   iax_1           Index of further axis to integrate along. The labels of the axis
%                  is the plot axis index i.e. 1=plot x-axis, 2=plot y-axis etc.
%
%   iax_1_range     Integration range [iax_lo, iax_hi] for this integration axis
%
%   iax_2       -|  The same for second additional integration axis
%   iax_2_range -| 
%
%       :
%
% Output:
% -------
%   dout            Output dataset. Its elements are the same as those of din,
%                  appropriately updated.
%
%
% Examples: if input dataset is 3D or 4D:
%   >> dout = cut_data (din, 2, [1.9,2.1], 3 [-0.55,-0.45]) % sum along y and z axes
%                                                           

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
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
niax = floor((nargin-1)/2); % niax = 1,2,3, or 4
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
dout.grid = din.grid;
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
dout.pax = pax; 
dout.iax = [din.iax, iax];
dout.uint = [din.uint, uint];
for i=1:length(pax_ind)
    pvals_name_in = ['p', num2str(pax_ind(i))];
    pvals_name_out= ['p', num2str(i)];
    dout.(pvals_name_out) = din.(pvals_name_in);
end
dout.s = signal;
dout.e = errors;
dout.n = nbins;

% temporary: should change all dnd structures to classes
if length(dout.pax)==1
    dout = d1d(dout);
end
toc
