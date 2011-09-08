function varargout=sqw_plot(varargin)
% Plot dispersion relation as colour map
%
%   >> sqw_plot(rlp,sqwfunc,pars,ecent)
%   >> sqw_plot(lattice,rlp,sqwfunc,pars,ecent)
%
%   >> sqw_plot(...,'ndiv',n)          % plot with number of points per interval other than the default
%
%   >> weight=sqw_plot(...)            % output IXTdataset_2d with spectral weight
%   >> weight=sqw_plot(...,'noplot')   % output IXTdataset_2d with spectral weight, no plot
%
% Input:
% --------
%   lattice     [optional] Lattice parameters [a,b,c,alpha,beta,gamma]  (Angstrom, degrees)
%               Default is [2*pi,2*pi,2*pi,90,90,90]
%
%   rlp         Array of r.l.p. e.g. [0,0,0; 0,0,1; 0,-1,1; 1,-1,1; 1,0,1; 1,0,0];
%
%   sqwfunc     Handle to function that calculates S(Q,w)
%               Most commonly used form is:
%                   weight = sqwfunc (qh,qk,ql,en,p)
%                where
%                   qh,qk,ql,en Arrays containing the coordinates of a set of points
%                   p           Vector of parameters needed by dispersion function 
%                              e.g. [A,js,gam] as intensity, exchange, lifetime
%                   weight      Array containing calculated energies; if more than
%                              one dispersion relation, then a cell array of arrays
%
%               More general form is:
%                   weight = sqwfunc (qh,qk,ql,en,p,c1,c2,..)
%                 where
%                   p           Typically a vector of parameters that we might want 
%                              to fit in a least-squares algorithm
%                   c1,c2,...   Other constant parameters e.g. file name for look-up
%                              table
%   
%   pars        Arguments needed by the function. Most commonly, a vector of parameter
%              values e.g. [A,js,gam] as intensity, exchange, lifetime. If a more general
%              set of parameters is required by the function, then
%              package these into a cell array and pass that as pars. In the example
%              above then pars = {p, c1, c2, ...}
%
%   ecent       Energy bin centres: [ecent_lo, step, ecent_hi]
%
% Keyword options (can be abbreviated to single letter):
%
%   'noplot'    Do not plot, just return the output IXTdataset_2d (see below)
%
%   'ndiv'   	Number of points into which to divide the interval between two r.l.p. (default=100)
%
%   'labels'    Tick labels to place at the positions of the Q points in argument rlp.
%                 e.g. {'G','X','M','R'}
%               By default the labels are character representations of rlp
%                 e.g. {0,0,0; 0.5,0,0; 0.5,0.5,0; 0.5,0.5,0.5}
%               becomes
%                     {'0,0,0', '0.5,0,0', '0.5,0.5,0', '0.5,0.5,0.5'}
%
%
% Ouptut:
% --------
%   weight      IXTdataset_2d with spectral weight

% T.G.Perring, 1 October 2009

% Set defaults:
arglist = struct('plot',1,'labels','','ndiv',100);
flags = {'plot'};

% Parse the arguments:
% --------------------
[args,opt,present] = parse_arguments(varargin,arglist,flags);

if numel(args)<4 || numel(args)>5
    error('Check number of arguments')
end

% Find out if first argument is lattice parameters
if numel(args)==5 && isnumeric(args{1}) && numel(args{1}==6)
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
    sqwfunc=args{noff+2};
else
    error('Check that a function handle to evaluate S(Q,w) has been given')
end

pars=args{noff+3};

if isnumeric(args{noff+4}) && isnumeric(args{noff+4}) && numel(args{noff+4})==3
    ecent=args{noff+4};
    if ecent(1)>=ecent(3)
        error('Must have ecent_lo < ecent_hi')
    elseif ecent(2)<=0
        error('Must have bin size>0')
    end
else
    error('Check energy bin centres')
end


% Evaluate S(Q,w)
% ---------------
[qh,qk,ql,xrlp,x]=make_qarray(lattice,rlp,opt.ndiv);
en=ecent(1):abs(ecent(2)):ecent(3);
qqh=repmat(qh,[1,numel(en)]);
qqk=repmat(qk,[1,numel(en)]);
qql=repmat(ql,[1,numel(en)]);
een=repmat(en,[numel(x),1]);
if iscell(pars)
    weight=sqwfunc(qqh,qqk,qql,een,pars{:});
else
    weight=sqwfunc(qqh,qqk,qql,een,pars);
end

tmp=IXTdataset_2d ('Spectral weight', weight, zeros(size(weight)),...
            IXTaxis('Spectral weight'), x', IXTaxis('momentum'), false, en, IXTaxis('Energy'), false);

if opt.plot
    da(tmp)
    if ~present.labels
        labels=make_labels(rlp);
    else
        if ~isempty(opt.labels) && iscellstr(opt.labels) && numel(opt.labels)==size(rlp,1)
            labels=opt.labels;
        else
            error('Check number of user-supplied labels and that they form a cell array of strings')
        end
    end
    plot_labels(labels,xrlp);
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
