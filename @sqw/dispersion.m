function wout=dispersion(win,dispreln,pars)
% Calculate dispersion relation for dataset or array of datasets. 
%
% The output dataset (or array of data sets) will retain only the Q axes, and
% the signal array(s) will contain the values of energy along the Q axes.
%
% The dispersion relation is calculated at the bin centres. 
%
% If the function that calculates dispersion relations produces for than one
% branch, then in the case of a single input dataset the output will be an array
% of datasets, one for each branch. If the input is an array of datasets, then only
% the first dispersion branch will be used, so there is one output dataset per
% input dataset.
%
%   >> wout=dispersion(win,dispreln,p)
%
%   win          Dataset that provides the axes and points for the calculation
%                If one of the plot axes is energy transfer, then the output dataset
%               will have dimensionality oe less than the input dataset
%
%   dispreln     Handle to function that calculates the dispersion relation w(Q)
%               Must have form:
%                   w = dispreln (qh,qk,ql,p)
%                where
%                   qh,qk,ql    Arrays containing the coordinates of a set of points
%                              in reciprocal lattice units
%                   p           Vector of parameters needed by dispersion function 
%                              e.g. [A,js,gam] as intensity, exchange, lifetime
%                   w           Array of corresponding energies, or, if more than
%                              one dispersion relation, a cell array of arrays.
%
%               More general form is:
%                   w = dispreln (qh,qk,ql,p,c1,c2,..)
%                 where
%                   p           Typically a vector of parameters that we might want 
%                              to fit in a least-squares algorithm
%                   c1,c2,...   Other constant parameters e.g. file name for look-up
%                              table
%
%   p           Arguments needed by the function. Most commonly, a vector of parameter
%              values e.g. [A,js,gam] as intensity, exchange, lifetime. If a more general
%              set of parameters is required by the function, then
%              package these into a cell array and pass that as pars. In the example
%              above then pars = {p, c1, c2, ...}
%
%
% Output:
% =======
%   wout        Output dataset or array of datasets. Output is always dnd-type.
%               The output dataset (or array of data sets) will retain only the Q axes, and
%              the signal array(s) will contain the values of energy along the Q axes.
%
%   e.g.        If win is a 2D dataset with Q and E axes, then wout is a 1D dataset
%              with just the Q axis


% Original author: T.G.Perring
%
% $Revision: 101 $ ($Date: 2007-01-25 09:10:34 +0000 (Thu, 25 Jan 2007) $)

wout = win;
if ~iscell(pars), pars={pars}; end      % package parameters as a cell for convenience

for i=1:numel(win)
    nd=dimensions(win(i));
    % Extract structure; use class constructor only at the end to save making checks at intermediate points
    data=win(i).data;   
    % Remove energy axis, if present
    npax=numel(data.pax);
    if npax>0 && data.pax(end)==4
        data.uoffset(4)=0;              % remove energy axis offset, so always treated as zero
        data.iax=[data.iax,4];          % add energy axis to integration axes
        data.iint=[data.iint,[0;0]];
        data.pax=data.pax(1:end-1);     % this works even if npax=1; correctly [1x0] empty array
        data.p=data.p(1:end-1);
        dax=data.dax;
        [dummy,ien]=max(dax);  % index of energy axis in dax (energy will always be the largest, as pax(end) is energy if present
        data.dax=dax(dax~=dax(ien));
        if nd>=2
            sz=size(win(i).data.s);
            if nd>2
                sz=sz(1:nd-1);          % 2D dataset or greater, so outer dimension is energy
            else
                sz=[sz(1:nd-1),1];      % 2D dataset or greater, so outer dimension is energy, but must make size array length 2
            end
        else
            sz=[1,1];           % 1D dataset, with energy as the axis, so output is scalar
        end
        nd_out=nd-1;
    else
        sz=size(win(i).data.s);
        nd_out=nd;
    end
    data.s = zeros(sz);
    data.e = zeros(sz);
    data.npix = ones(sz);

    % Package up as a dnd-type sqw object in the output array
    if nd_out==0
        wout(i)=sqw(d0d(data));
    elseif nd_out==1
        wout(i)=sqw(d1d(data));
    elseif nd_out==2
        wout(i)=sqw(d2d(data));
    elseif nd_out==3
        wout(i)=sqw(d3d(data));
    elseif nd_out==4
        wout(i)=sqw(d4d(data));
    end
    
    % Compute dispersion relation at bin centres
    qw = calculate_qw_bins(wout(i));
    wdisp = dispreln(qw{1:3},pars{:});
    if iscell(wdisp)
        if numel(win)==1    % single input sqw object
            wout=repmat(wout,size(wdisp));  % make one output array per dispersion relation
            for j=1:numel(wdisp)
                wout(j).data.s=reshape(wdisp{j},sz);
            end
        else
            wout(i).data.s=reshape(wdisp{1},sz);
        end
    else
        wout(i).data.s=reshape(wdisp,sz);
    end

end
