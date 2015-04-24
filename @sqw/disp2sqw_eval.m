function wout=disp2sqw_eval(win,dispreln,pars,fwhh,opt)
% Calculate sqw for a model scattering function
%
%   >> wout = disp2sqw_eval(win,dispreln,pars,fwhh,opt)
%
% Input:
% ------
%   win         Dataset, or array of datasets, that provides the axes and points
%              for the calculation
%
%   dispreln    Handle to function that calculates the dispersion relation w(Q) and
%              spectral weight, s(Q)
%              Must have form:
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
%   fwhh       Parametrizes the resolution function. There are three
%              possible input values of fwhh:
%
%       double              A single FWHM value determines the FWHM of the 
%                           Gaussian resolution function
%       function_handle     A function that produces the FWHM value as a
%                           function of energy transfer, it has to have the
%                           following simple header (where omega can be a row
%                           vector of energies:
%                               dE = resfun(omega)
%       function_handle     A function handle of a function with two input
%                           parameters with the following header:
%                               I = shapefun(Emat,omega)
%                           where Emat is a matrix with dimensions of [nQ nE]
%                           and omega is a column vector with nQ elements. The
%                           shapefun produces a peakshape for every Q point
%                           centered at the given omega and normalized to one.
%                           The output I has the same dimensions as the
%                           input Emat.
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
    if is_sqw_type(win(i));   % determine if sqw or dnd type
        % If sqw type, then must evaluate at every pixel, as qh,qk,ql in general will be different for every pixel
        if ~ave_pix
            wout(i)=sqw_eval(win(i),@disp2sqw,{dispreln,pars,fwhh});
        else
            wout(i)=sqw_eval(win(i),@disp2sqw,{dispreln,pars,fwhh},'ave');
        end
    else
        % If dnd type, then can take advantage of Cartesian grid to calculate dispersion for the Q grid only
        [q,en]=calculate_q_bins(win(i));
        weight=reshape(disp2sqw(q,en,dispreln,pars,fwhh),size(win(i).data.s));
        if ~all_bins
            omit=(win(i).data.npix==0);
            if any(omit), weight(omit)=0; end
        end
        wout(i).data.s=weight;
        wout(i).data.e=zeros(size(win(i).data.e));
    end
end
