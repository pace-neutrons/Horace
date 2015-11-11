function varargout=disp2sqw_plot(varargin)
% Plot dispersion relation as colour map along a path in reciprocal space
%
%   >> disp2sqw_plot(rlp,dispreln,pars,ecent,fwhh)
%   >> disp2sqw_plot(lattice,rlp,dispreln,pars,ecent,fwhh)
%
%   >> disp2sqw_plot(...,'labels',{'G','X',...})  % customised labels
%   >> disp2sqw_plot(...,'ndiv',n)          % alter density of points
%
%   >> weight=disp2sqw_plot(...)            % output spectral weight and plot
%   >> weight=disp2sqw_plot(...,'noplot')   % output spectral weight, no plot
%
% Input:
% --------
%   lattice     [optional] Lattice parameters [a,b,c,alpha,beta,gamma] in
%              Angstrom and degrees
%               Default is [2*pi,2*pi,2*pi,90,90,90]
%
%   rlp         Array of r.l.p. e.g. [0,0,0; 0,0,1; 1,0,1; 1,0,0];
%
%   dispreln    Handle to function that calculates the dispersion relation
%              or set of dispersion relations w(Q) and corresponding spectral
%              weight, s(Q)
%               Must have the form:
%                   [w,s] = dispreln (qh,qk,ql,p)
%               where
%                 Input:
%                   qh,qk,ql    Arrays containing the coordinates of a set 
%                              of points in reciprocal lattice units
%                   p           Vector of parameters needed by the function 
%                              e.g. [A,js,gam] as intensity, exchange, lifetime
%                 Output:
%                   w           Array of corresponding energies, or, if more than
%                              one dispersion relation, a cell array of arrays.
%                   s           Array of spectral weights, or, if more than
%                              one dispersion relation, a cell array of arrays.
%
%              More general form is:
%                   [w,s] = dispreln (qh,qk,ql,p,c1,c2,..)
%                 where
%                   p           Typically a vector of parameters that we might 
%                              want to fit in a least-squares algorithm
%                   c1,c2,...   Other constant parameters e.g. file name of
%                              a look-up table.
%
%   pars        Arguments needed by the function.
%               - Most commonly, a vector of parameter values e.g. [A,js,gam]
%                 as intensity, exchange, lifetime.
%               - More generally, if addition constant arguments are needed
%                 by the dispersion function, then package these into a cell
%                 array and pass that as pars. In the example above then
%                 pars = {p, c1, c2, ...}
%
%   ecent       Defines energy bin centres: [ecent_lo, step, ecent_hi]
%
%   fwhh        Full-width half-height of Gaussian broadening to dispersion
%               relation(s)%
%
% Keyword options (can be abbreviated to single letter):
%
%   'labels'    Tick labels to place at the positions of the Q points in
%              argument rlp.
%                 e.g. {'G','X','M','R'}
%               By default the labels are character representations of rlp
%                 e.g. {0,0,0; 0.5,0,0; 0.5,0.5,0; 0.5,0.5,0.5}
%               becomes
%                     {'0,0,0', '0.5,0,0', '0.5,0.5,0', '0.5,0.5,0.5'}
%
%   'ndiv'   	Number of points into which to divide the interval between
%              two r.l.p. (default=100)
%
%   'noplot'    Do not plot, just return the output IX_dataset_2d (see below)
%
%
% Ouptut:
% --------
%   weight      [Optional] IX_dataset_2d with spectral weight
%
%
% See also: dispersion_plot


% Original author: T.G.Perring
%
% $Revision$ ($Date$)


% Set defaults:
arglist = struct('plot',1,'labels','','ndiv',100);
flags = {'plot'};

% Parse the arguments:
% --------------------
[args,opt,present] = parse_arguments(varargin,arglist,flags);

if numel(args)<5 || numel(args)>6
    error('Check number of arguments')
end

% Find out if first argument is lattice parameters
if numel(args)==6 && isnumeric(args{1}) && numel(args{1}==6)
    lattice=args{1};
    noff=1;
else
    lattice=[2*pi,2*pi,2*pi,90,90,90];
    noff=0;
end

if isnumeric(args{noff+1}) && size(args{noff+1},2)==3 && size(args{noff+1},1)>=2
    rlp=args{noff+1};
else
    error('Check argument giving list of reciprocal lattice points')
end

if isa(args{noff+2},'function_handle') && isscalar(args{noff+2})
    dispreln=args{noff+2};
else
    error('Check dispersion relation is a function handle')
end

pars=args{noff+3};

if isnumeric(args{noff+4}) && numel(args{noff+4})==3
    ecent=args{noff+4};
    if ecent(1)>=ecent(3)
        error('Must have ecent_lo < ecent_hi')
    elseif ecent(2)<=0
        error('Must have bin size>0')
    end
else
    error('Check energy bin centres')
end

fwhh=args{noff+5};


% Determine if need to calculate dispersion, weight, or both, and consistency with dispreln
% ------------------------------------------------------------------------------------------
nout = nargout(dispreln);
errstr = 'The provided dispersion function does not appear to return spectral weight';
if nout<0
    try
        [e,sf]=dispreln(0,0,0,pars{:});
    catch
        error(errstr);
    end
elseif nout<2
    error(errstr);
end

% Make labels
% ------------
if ~present.labels
    labels=make_labels(rlp);
else
    if ~isempty(opt.labels) && iscellstr(opt.labels) && numel(opt.labels)==size(rlp,1)
        labels=opt.labels;
    else
        error('Check number of user-supplied labels and that they form a cell array of strings')
    end
end


% Evaluate the dispersion relation
% --------------------------------
[qh,qk,ql,xrlp,x]=make_qarray(lattice,rlp,opt.ndiv);
en=ecent(1):abs(ecent(2)):ecent(3);
weight = disp2sqw({qh,qk,ql},en,dispreln,pars,fwhh);


% Create output objects
% ----------------------
x_axis=IX_axis('Momentum');
try % try to put ticks in the IX_axis object
    ticks.positions=xrlp;
    ticks.labels=labels;
    x_axis.ticks=ticks;
catch
end
tmp=IX_dataset_2d ('Spectral weight', weight, zeros(size(weight)),...
    IX_axis('Spectral weight'), x', x_axis, false, en, IX_axis('Energy'), false);

if opt.plot
    da(tmp)
    plot_labels(labels,xrlp);   % do this in case of older Herbert or Libisis
end

if nargout>=1
    varargout{1}=tmp;
end


%========================================================================================================
function [qh,qk,ql,xrlp,x,ind]=make_qarray(lattice,rlp,ndiv)
% Create arrays of qh,qk,ql
%   >> [qh,qk,ql,ind]=make_qarray(rlp,ndiv)
%
%   rlp         Array of r.l.p e.g. [0,0,0; 0,0,1; 0,-1,1; 1,-1,1; 1,0,1; 1,0,0];
%   ndiv        Number of intervals into which to divide each interval e.g. 100
%
%   qh          Array of qh values (column vector)
%   qk          Array of qk values (column vector)
%   ql          Array of ql values (column vector)
%   xrlp        Array of distances corresponding to the rlp (column vector)
%   x           Array of distances along the line connecting the rlp (which are at 0,1,2,..(n-1)
%              where n is the number of rlp. (column vector)
%   ind         Index of points, 1,2,3,... (column vector)


% Get distances along the segments
b=bmatrix(lattice(1:3),lattice(4:6));
cryst=(b*diff(rlp)')';      % difference in rlp in crystal Cartesian coords
lenseg=sqrt(sum(cryst.^2,2));
xrlp=[0;cumsum(lenseg)];

% Fill output arrays
nseg=size(rlp,1)-1;
npnt=nseg*ndiv+1;
qh=zeros(npnt,1); qk=zeros(npnt,1); ql=zeros(npnt,1); x=zeros(npnt,1);
for i=1:nseg
    qqh=linspace(rlp(i,1),rlp(i+1,1),ndiv+1)';
    qqk=linspace(rlp(i,2),rlp(i+1,2),ndiv+1)';
    qql=linspace(rlp(i,3),rlp(i+1,3),ndiv+1)';
    xx=linspace(xrlp(i),xrlp(i+1),ndiv+1)';
    jlo=1+(i-1)*ndiv; jhi=i*ndiv;
    if i~=nseg
        qh(jlo:jhi)=qqh(1:end-1); qk(jlo:jhi)=qqk(1:end-1); ql(jlo:jhi)=qql(1:end-1); x(jlo:jhi)=xx(1:end-1);
    else
        qh(jlo:jhi+1)=qqh; qk(jlo:jhi+1)=qqk; ql(jlo:jhi+1)=qql; x(jlo:jhi+1)=xx;
    end
end
ind=(1:npnt)';

%========================================================================================================
function labels=make_labels(rlp)
% Make labels for graphs from list of r.l.p
nrlp=size(rlp,1);
labels=cell(1,nrlp);
for i=1:nrlp
    labels{i}=['[',str_compress(num2str(rlp(i,:)),','),']'];
end

%========================================================================================================
function plot_labels(labels,xvals)
% Labels for plots.
%
%   >> plot_labels(labels,ndiv)
%
%   labels      cell array of labels
%   xvals       positions for the labels

set(gca,'XTick',xvals);
set(gca,'XTickLabel',labels);
