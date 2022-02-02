function [y,t] = pulse_shape (obj, varargin)
% Chopper pulse as a function of time
%
%   >> [y,t] = pulse_shape (obj)
%   >> [y,t] = pulse_shape (obj, phase)    % for specified phase
%   >> [y,t] = pulse_shape (obj, t)        % for an array of times
%   >> [y,t] = pulse_shape (obj, t, phase) % for specified time(s) and phase
%
%
% Input:
% -------
%   obj     IX_fermi_chopper object (scalar)
%
%   t       time (microseconds) (array or scalar)
%           If omitted, a default suitable set of points for a plot is used
%
%   phase   if true, optimally phased; if false, 180 degrees out of phase
%           If omitted, uses phase in the IX_fermi_chopper object
%
% Output:
% -------
%   y       Array of values of pulse shape as a function of time for the
%           incident energy contained in the chopper object.
%
%           The area integrated with respect to time matches the total
%           transmission as returned by the method named transmission for
%           the energy of the chopper at the provided phase.
%           That method returns the integrated transmission normalised so
%           that at the energy of peak transmission for optimum phase
%           (i.e phase==1) is unity.


% Check inputs
if ~isscalar(obj)
    error('IX_fermi_chopper:pulse_shape:invalid_argument',...
        'Method only takes a scalar object')
end

[ok, mess, t, phase, t_given] = parse_t_and_phase_ (obj, varargin{:});
if ~ok, error(mess), end

% Calculate pulse shape
[pk_fwhh, gam] = get_pulse_props_ (obj, obj.energy_, phase);

if pk_fwhh > 0
    % Get suitable range of times for plotting
    if ~t_given
        npnt = 500;
        [tlo, thi] = pulse_range (obj);
        t = linspace (tlo,thi,npnt);
    end
    
    y = zeros(size(t));
    tau = abs(t) / (10^6 * pk_fwhh);
    if gam < 1
        ilo = (tau<gam);
        y(ilo) = 1 - ((gam+tau(ilo)).^2) / (4 * gam);
        ihi = (tau >= gam & tau < 1);
        y(ihi) = 1 - tau(ihi);
    elseif gam < 4
        iok = (tau < sqrt(gam) * (2-sqrt(gam)));
        y(iok) = 1 - ((gam+tau(iok)).^2) / (4 * gam);
    end
    
    % Normalise so integral w.r.t. time in microseconds is transmission(obj[,phase])
    y = y * (10^-6 / pk_fwhh);
    
else
    y=zeros(size(t));
    y(t==0) = Inf;
end

end
