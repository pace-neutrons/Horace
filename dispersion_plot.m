function varargout=dispersion_plot(varargin)
% Plot dispersion relation or array of dispersion relations
%
%   >> dispersion_plot(rlp,dispreln,pars)
%   >> dispersion_plot(lattice,rlp,dispreln,pars)
%
%   >> dispersion_plot(...,'dispersion')            % plot dispersion only
%   >> dispersion_plot(...,'weight')                % plot spectral weight only
%   >> dispersion_plot(...,'labels',{'G','X',...})  % Customised labels at the positions of the rlp
%   >> dispersion_plot(...,'ndiv',n)        % plot with number of points per interval other than the default
%
%   >> [wdisp,weight]=dispersion_plot(...)  % output arrays of IXTdataset_1d with dispersion and spectral weight
%   >> [wdisp,weight]=dispersion_plot(...,'noplot')     % output arrays without plotting
%
% Input:
% --------
%   lattice     [optional] Lattice parameters [a,b,c,alpha,beta,gamma]  (Angstrom, degrees)
%               Default is [2*pi,2*pi,2*pi,90,90,90]
%
%   rlp         Array of r.l.p. e.g. [0,0,0; 0,0,1; 0,-1,1; 1,-1,1; 1,0,1; 1,0,0];
%
%   dispreln    Handle to function that calculates the dispersion relation w(Q) and spectrl weight, s(Q)
%              Must have form:
%                   [w,s] = dispreln (qh,qk,ql,p)
%               where
%                   qh,qk,ql    Arrays containing the coordinates of a set of points
%                              in reciprocal lattice units
%                   p           Vector of parameters needed by dispersion function 
%                              e.g. [A,js,gam] as intensity, exchange, lifetime
%                   w           Array of corresponding energies, or, if more than
%                              one dispersion relation, a cell array of arrays.
%
%              More general form is:
%                   [w,s] = dispreln (qh,qk,ql,p,c1,c2,..)
%                 where
%                   p           Typically a vector of parameters that we might want 
%                              to fit in a least-squares algorithm
%                   c1,c2,...   Other constant parameters e.g. file name for look-up
%                              table.
%   
%   pars        Arguments needed by the function. Most commonly, a vector of parameter
%              values e.g. [A,js,gam] as intensity, exchange, lifetime. If a more general
%              set of parameters is required by the function, then
%              package these into a cell array and pass that as pars. In the example
%              above then pars = {p, c1, c2, ...}
%
% Keyword options (can be abbreviated to single letter):
%
%   'dispersion'Only plot the dispersion relation(s)
%               The default is to plot and/or return dispersion, and weight if available
%
%   'weight'    Only plot the spectral weight(s)
%               The default is to plot and/or return dispersion, and weight if available
%
%   'noplot'    Do not plot, just return the output IXTdataset_1d (see below)
%
%   'ndiv'   	Number of points into which to divide the interval between two r.l.p. (default=100)
%
%
% Ouptut:
% --------
%   wdisp       Array of IXTdataset_1d containing dispersion, one per dispersion relation.
%               The x-aaxis is the distance in Ang^-1 along the path described 
%
%   weight      Array of IXTdataset_1d with corresponding spectral weight, one per dispersion relation

% T.G.Perring, 1 October 2009

% Set defaults:
arglist = struct('dispersion',1,'weight',1,'labels','','plot',1,'ndiv',100);
flags = {'dispersion','weight','plot'};

% Parse the arguments:
% --------------------
[args,opt,present] = parse_arguments(varargin,arglist,flags);

if numel(args)<3 || numel(args)>4
    error('Check number of arguments')
end

% Find out if first argument is lattice parameters
if numel(args)==4 && isnumeric(args{1}) && numel(args{1}==6)
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

% Determine if need to calculate dispersion, weight, or both, and consistency with dispreln
% ------------------------------------------------------------------------------------------
return_dispersion = nargout>=1;
return_weight = nargout>=2;
if opt.plot
    plot_dispersion = opt.dispersion & (present.dispersion | (~present.dispersion & ~present.weight));
    plot_weight = opt.weight & (present.weight | (~present.dispersion & ~present.weight & nargout(dispreln)>=2));
else
    plot_dispersion = false;
    plot_weight = false;
end
calc_dispersion = return_dispersion | plot_dispersion;
calc_weight = return_weight | plot_weight;
if ~calc_dispersion && ~calc_weight
    error('Neither requested to return calculation nor to plot calculation')
end
if nargout(dispreln)<2 && calc_weight
    error('Requested spectral weight to be calculated, but the provided dispersion function does not return it')
end

% Evaluate the dispersion relation
% --------------------------------
[qh,qk,ql,xrlp,x]=make_qarray(lattice,rlp,opt.ndiv);

if iscell(pars)
    if calc_weight
        [e,sf]=dispreln(qh,qk,ql,pars{:});
    else
        e=dispreln(qh,qk,ql,pars{:});
    end
else
    if calc_weight
        [e,sf]=dispreln(qh,qk,ql,pars);
    else
        e=dispreln(qh,qk,ql,pars);
    end
end

if iscell(e)
    wdisp=IXTdataset_1d('Dispersion relation',e{1},zeros(size(e{1})),IXTaxis('Energy'),x,IXTaxis('momentum'),false);
    if numel(e)>1, wdisp(1,numel(e))=wdisp; end
    for i=2:numel(e)
        wdisp(i)=IXTdataset_1d('Dispersion relation',e{i},zeros(size(e{i})),IXTaxis('Energy'),x,IXTaxis('momentum'),false);
    end
    if calc_weight
        weight=IXTdataset_1d('Spectral weight',sf{1},zeros(size(sf{1})),IXTaxis('Intensity'),x,IXTaxis('momentum'),false);
        if numel(e)>1, weight(1,numel(e))=weight; end
        for i=2:numel(e)
            weight(i)=IXTdataset_1d('Spectral weight',sf{i},zeros(size(sf{i})),IXTaxis('Intensity'),x,IXTaxis('momentum'),false);
        end
    end
else
    wdisp=IXTdataset_1d('Dispersion relation',e,zeros(size(e)),IXTaxis('Energy'),x,IXTaxis('momentum'),false);
    if calc_weight
        weight=IXTdataset_1d('Spectral weight',sf,zeros(size(sf)),IXTaxis('Intensity'),x,IXTaxis('momentum'),false);
    end
end

if plot_dispersion || plot_weight
    if ~present.labels
        labels=make_labels(rlp);
    else
        if ~isempty(opt.labels) && iscellstr(opt.labels) && numel(opt.labels)==size(rlp,1)
            labels=opt.labels;
        else
            error('Check number of user-supplied labels and that they form a cell array of strings')
        end
    end
end

if plot_dispersion
    dl(wdisp)
    lx(0,x(end));     % have to enforce the maximum limit, otherwise autoscales for some reason
    plot_labels(labels,xrlp);
end

if plot_weight
    if plot_dispersion, keep_figure; end     % plotted dispersion, so keep that plot
    dl(weight)
    lx(0,x(end));     % have to enforce the maximum limit, otherwise autoscales for some reason
    plot_labels(labels,xrlp);
end

if return_dispersion
    varargout{1}=wdisp;
end

if return_weight
    varargout{2}=weight;
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
