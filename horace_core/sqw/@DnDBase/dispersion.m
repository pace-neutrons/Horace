function [wout_disp, wout_weight] = dispersion(win, dispreln, pars)
% Calculate dispersion relation for dataset or array of datasets.
%
% New behaviour: Always returns appropriate dnd object. May be modified in
% a future.
%
%
%   >> wdisp = dispersion (win, dispreln, p)            % dispersion only
%   >> [wdisp,weight] = dispersion (win, dispreln, p)   % dispersion and spectral weight
%
% The output dataset (or array of data sets), wdisp, will retain only the Q axes, and
% the signal array(s) will contain the values of energy along the Q axes. If the
% dispersion relation returns the spectral weight, this will be placed in the error
% array (actually the square of the spectral weight is put in the error array). In the
% case when the dispersion has been calculated on a plane in momentum (i.e. wdisp
% is IX_datset_2d) then the plot function ps2 (for plot_surface2)
%   >> ps2(wdisp)
% will plot a surface with the z axis as energy and coloured according to the spectral
% weight.
%
% The dispersion relation is calculated at the bin centres (that is, the individual pixel
% information in a sqw input object is not used).
%
% If the function that calculates dispersion relations produces more than one
% branch, then in the case of a single input dataset the output will be an array
% of datasets, one for each branch. If the input is an array of datasets, then only
% the first dispersion branch will be returned, so there is one output dataset per
% input dataset.
%
% Input:
% ======
%   win         Dataset that provides the axes and points for the calculation
%               If one of the plot axes is energy transfer, then the output dataset
%               will have dimensionality one less than the input dataset
%
%   dispreln    Handle to function that calculates the dispersion relation w(Q)
%               Must have form:
%                   [w,s] = dispreln (qh,qk,ql,p)
%               where
%                   qh,qk,ql    Arrays containing the coordinates of a set of points
%                              in reciprocal lattice units
%                   p           Vector of parameters needed by dispersion function
%                              e.g. [A,js,gam] as intensity, exchange, lifetime
%                   w           Array of corresponding energies, or, if more than
%                              one dispersion relation, a cell array of arrays.
%                   s           Array of spectral weights, or, if more than
%                              one dispersion relation, a cell array of arrays.
%
%              More general form is:
%                   [w,s] = dispreln (qh,qk,ql,{p,c1,c2,..})
%                 where
%                   p           Typically a vector of parameters that we might want
%                              to fit in a least-squares algorithm
%                   c1,c2,...   Other constant parameters e.g. file name for look-up
%                              table.
%
%   pars       Arguments needed by the function. Most commonly, a vector of parameter
%              values e.g. [A,js,gam] as intensity, exchange, lifetime. If a more general
%              set of parameters is required by the function, then
%              package these into a cell array and pass that as pars. In the example
%              above then pars = {p, c1, c2, ...}
%
%
% Output:
% =======
%   wdisp       Output dataset or array of datasets of the same type as the input argument.
%               The output dataset (or array of data sets) will retain only the Q axes, the
%              the signal array(s) will contain the values of energy along the Q axes, and
%              the error array will contain the square of the spectral weight.
%               If the function that calculates dispersion relations produces more than one
%              branch, then in the case of a single input dataset the output will be an array
%              of datasets, one for each branch. If the input is an array of datasets, then only
%              the first dispersion branch will be returned, so there is one output dataset per
%              input dataset.
%
%   weight      Mirror output: the signal is the spectral weight, and the error array
%               contains the square of the frequency.
%
%   e.g.        If win is a 2D dataset with Q and E axes, then wdisp is a 1D dataset
%              with just the Q axis

if ~iscell(pars)   % package parameters as a cell for convenience
    pars={pars};
end


wout_disp      = copy(win);
wout_disp.s    = zeros(size(wout_disp.s));
wout_disp.e    = zeros(size(wout_disp.s));
wout_disp.npix = ones(size(wout_disp.s));
if nargout==2
    wout_weight=wout_disp;
end

for i=1:numel(win)
    % Extract structure; use class constructor only at the end to save making checks at intermediate points
    data = wout_disp(i);
    % Remove energy axis, if present
    npax=numel(data.pax);
    if npax>0 && data.pax(end)==4
        data.offset(4)=0;              % remove energy axis offset, so always treated as zero
        ax = data.axes;
        proj = data.proj;
        bins = ax.get_cut_range('-full');
        bins{4} = [0,0];
        ax = ortho_axes(bins{:});
        dax=data.dax;
        [~, ien]=max(dax);  % index of energy axis in dax (energy will always be the largest, as pax(end) is energy if present
        data = DnDBase.dnd(ax,proj);
        data.dax=dax(dax~=dax(ien));
    else
        sz=size(win(i).s);
        data.s    = zeros(sz);
        data.e    = zeros(sz);
        data.npix = ones(sz);
    end
    wout_disp(i) = data;


    % Compute dispersion relation at bin centres
    qw = calculate_qw_bins(data);
    if nargout(dispreln) < 2
        wdisp = dispreln(qw{1:3}, pars{:});  % only dispersion seems to be provided
    else
        [wdisp,sfact] = dispreln(qw{1:3}, pars{:});
    end
    if iscell(wdisp)
        if numel(win)==1    % single input sqw
            % object
            wout_disp=repmat(wout_disp,size(wdisp));  % make one output array per dispersion relation
            if nargout==2, wout_weight=repmat(wout_weight,size(wdisp)); end  % make one output array per dispersion relation
            for j=1:numel(wdisp)
                wout_disp(j).s=reshape(wdisp{j},sz);
                if exist('sfact','var'), wout_disp(j).e=reshape(sfact{j},sz).^2; end
                if nargout==2
                    if exist('sfact','var'), wout_weight(j).s=reshape(sfact{j},sz); end
                    wout_weight(j).e=reshape(wdisp{j},sz).^2;
                end
            end
        else
            wout_disp(i).s=reshape(wdisp{1},sz);
            if exist('sfact','var'), wout_disp(i).e=reshape(sfact{1},sz).^2; end
            if nargout==2
                if exist('sfact','var'), wout_weight(i).s=reshape(sfact{1},sz); end
                wout_weight(i).e=reshape(wdisp{1},sz).^2;
            end
        end
    else
        wout_disp(i).s=reshape(wdisp,sz);
        if exist('sfact','var'), wout_disp(i).e=reshape(sfact,sz).^2; end
        if nargout==2
            if exist('sfact','var'), wout_weight(i).s=reshape(sfact,sz); end
            wout_weight(i).e=reshape(wdisp,sz).^2;
        end
    end
end
