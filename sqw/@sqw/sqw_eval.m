function wout=sqw_eval(win,sqwfunc,pars,opt)
% Calculate sqw for a model scattering function
%
%   >> wout=sqw_eval(win,sqwfunc,p)
%
% Input:
% ------
%   win         Dataset (or array of datasets) that provides the axes and points
%              for the calculation
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
%   'all'       [option] Requests that the calculated sqw be returned over
%              the whole of the domain of the input dataset. If not given, then
%              the function will be returned only at those points of the dataset
%              that contain data.
%               Applies only to input with no pixel information - it is ignored if
%              full sqw object.
%
%   'ave'       [option] Requests that the calculated sqw be computed for the
%              average values of h,k,l of the pixels in a bin, not for each
%              pixel individually. Reduces cost of expensive calculations.
%               Applies only to the case of sqw object with pixel information - it is
%              ignored if dnd type object.
%
% Output:
% -------
%   wout        Output dataset or array of datasets 


% Check optional argument
all_bins=false;
ave_pix=false;
if exist('opt','var')  % no option given
    if ischar(opt) && ~isempty(strmatch(lower(opt),'all'))    % option 'all' given
        all_bins=true;
    elseif ischar(opt) && ~isempty(strmatch(lower(opt),'ave'))    % option 'ave' given
        ave_pix=true;
    else
        error('Unrecognised option')
    end
end
    
wout = win;
if ~iscell(pars), pars={pars}; end  % package parameters as a cell for convenience

for i=1:numel(win)
    if is_sqw_type(win(i))   % determine if sqw or dnd type
        if ~ave_pix
            qw = calculate_qw_pixels(win(i));
            stmp=sqwfunc(qw{:},pars{:});
            wout(i).data.pix(8:9,:)=[stmp(:)';zeros(1,numel(stmp))];
            wout(i)=recompute_bin_data(wout(i));
        else
            % Get average h,k,l,e for the bin, compute sqw for that average, and fill pixels with the average signal for the bin that contains them
            qw = calculate_qw_pixels(win(i));
            qw_ave=average_bin_data(win(i),qw);
            stmp=sqwfunc(qw_ave{:},pars{:});
            stmp=replicate_array(stmp,win(i).data.npix);
            wout(i).data.pix(8:9,:)=[stmp(:)';zeros(1,numel(stmp))];
            wout(i)=recompute_bin_data(wout(i));
        end
    else
        qw = calculate_qw_bins(win(i));
        if ~all_bins                    % only evaluate at the bins actually containing data
            ok=(win(i).data.npix~=0);   % should be faster than isfinite(1./win.data.npix), as we know that npix is zero or finite
            for idim=1:4
                qw{idim}=qw{idim}(ok);  % pick out only the points where there is data
            end
            wout(i).data.s(ok)=sqwfunc(qw{:},pars{:});
        else
            wout(i).data.s=reshape(sqwfunc(qw{:},pars{:}), size(win(i).data.s));
        end
        wout(i).data.e = zeros(size(win(i).data.e));
    end
end
