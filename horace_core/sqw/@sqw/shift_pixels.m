function wout = shift_pixels (win, dispreln, pars, opt)
% Shift the energy of pixels in an sqw object according to a dispersion relation
%
%   >> wout = shift_pixels (win, dispreln, pars)
%
% Input:
% ------
%   win         Dataset (or array of datasets) that provides the axes and points
%              for the calculation
%
%   dispreln    Handle to function that calculates the dispersion relation w(Q)
%              Must have the form:
%                   w = dispreln (qh,qk,ql,p)
%               where
%                 Input:
%                   qh,qk,ql    Arrays containing the coordinates of a set
%                              of points in reciprocal lattice units
%                   p           Vector of parameters needed by the function
%                              e.g. [A,js,gam] as intensity, exchange, lifetime
%                 Output:
%                   w           Array of corresponding energies, or, if more than
%                              one dispersion relation, a cell array of arrays.
%
%              More general form is:
%                   w = dispreln (qh,qk,ql,p,c1,c2,..)
%                 where
%                   p           Typically a vector of parameters that we might
%                              want to fit in a least-squares algorithm
%                   c1,c2,...   Other constant parameters e.g. file name of
%                              a look-up table.
%
%   pars        Arguments needed by the function. Most commonly, a vector of parameter
%              values e.g. [A,js,gam] as intensity, exchange, lifetime. If a more general
%              set of parameters is required by the function, then
%              package these into a cell array and pass that as pars. In the example
%              above then pars = {p, c1, c2, ...}
%
%   '-ave'       [option] Requests that the calculated sqw be computed for the
%              average values of h,k,l of the pixels in a bin, not for each
%              pixel individually. Reduces cost of expensive calculations.
%               Applies only to the case of sqw object with pixel information - it is
%              ignored if dnd type object.
%
% Output:
% -------
%   wout        Output dataset or array of datasets


% Check optional argument
ave_pix=false;
if exist('opt','var')  % no option given
    if ischar(opt) && ~isempty(strncmpi(opt,'-ave',numel(opt)))    % option 'ave' given
        ave_pix=true;
    else
        error('Unrecognised option')
    end
end

wout = copy(win);
if ~iscell(pars), pars={pars}; end  % package parameters as a cell for convenience

for i=1:numel(win)
    if has_pixels(win(i))   % determine if sqw or dnd type
        if ~ave_pix
            qw = calculate_qw_pixels(win(i));
            wdisp=dispreln(qw{1:3},pars{:});
            if iscell(wdisp)
                wdisp=wdisp{1};     % pick out the first dispersion relation
            end
            wout(i).pix.dE=wout(i).pix.dE-wdisp(:)';
        else
            % Get average h,k,l,e for the bin, compute sqw for that average, and fill pixels with the average signal for the bin that contains them
            qw = calculate_qw_pixels(win(i));
            qw_ave=average_bin_data(win(i),qw);
            wdisp=dispreln(qw_ave{1:3},pars{:});
            if icell(wdisp)
                wdisp=wdisp{1};     % pick out the first dispersion relation
            end
            wdisp=replicate_array(wdisp,win(i).data.npix);
            wout(i).pix.dE=wout(i).pix.dE-wdisp(:)';
        end
        % Have shifted the energy, but need to recompute the bins.
        % - If energy is a plot axis, then extend the range of the
        %   axis to retain all pixels.
        % - If energy is an integration axis, then pixels fall out if
        %   shifted outside the integration range (i.e. we don't extend
        %   the integration range)

        [proj, pbin] = get_proj_and_pbin (win(i));

        % Convert wout(i) into a single bin object
        pix  = wout(i).pix;
        new_data = d0d();
        new_data.axes.img_range = wout(i).data.axes.img_range;
        new_data.proj = wout.data.proj;

        new_data.npix = pix.num_pixels;
        eps_lo = min(pix.dE);
        eps_hi = max(pix.dE);

        new_data.axes.img_range(:,4) = [eps_lo;eps_hi];
        wout(i).data = new_data;
        %wout(i) = recompute_bin_data(wout(i));
            

        pbin_i = pbin{i};
        % Redefine energy binning ranges with energy bin limits extended, if necessary
        if numel(pbin_i{4})==2
            pbin_i{4}(1) = floor(eps_lo);
            pbin_i{4}(2) = ceil(eps_hi);            
        else
            de = pbin_i{4}(2);            
            elo = floor(eps_lo)-0.5*de;
            ehi = ceil(eps_hi)+0.5*de;
            pbin_i{4} = [elo,de,ehi];
        end

        wout(i) = cut(wout(i),proj(i),pbin_i{:});

    else
        error('HORACE:sqw:not_implemented', ...
            'Not yet implemented for dnd objects')
        %         qw = calculate_qw_bins(win(i));
        %         wdisp=dispreln(qw{1:3},pars{:});
        %         if icell(wdisp)
        %             wdisp=wdisp{1};     % pick out the first dispersion relation
        %         end
    end
end
