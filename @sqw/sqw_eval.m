function wout=sqw_eval(win,sqwfunc,pars,opt)
% Calculate sqw for a model scattering function
%
%   >> wout=sqw(win,sqwfunc,p)
%
%   win         Dataset that provides the axes and points for the calculation
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
% Output:
% =======
%   wout        Output dataset or array of datasets 

% Check optional argument
if ~exist('opt','var')  % no option given
    all_bins=false;
elseif ischar(opt) && ~isempty(strmatch(lower(opt),'all'))    % option 'all' given
    all_bins=true;
else
    error('Unrecognised option')
end
    
wout = win;
if ~iscell(pars), pars={pars}; end  % package parameters as a cell for convenience

for i=1:numel(win)
    if is_sqw_type(win(i));   % determine if sqw or dnd type
        qw = calculate_qw_pixels(win(i));
        stmp=sqwfunc(qw{:},pars{:});
        wout(i).data.pix(8:9,:)=[stmp(:)';zeros(1,numel(stmp))];
        wout(i)=recompute_bin_data(wout(i));
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
