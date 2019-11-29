function [dt, t_av, fwhh] = table_pulse_width (pdf, ei)
% Calculate pulse width quantities (microseconds)
%
%   >> [dt, tav, fwhh] = table_pulse_width (pp, ei)
%
% Input:
% -------
%   pdf         pdf_table object
%   ei          Incident energy (meV) (array or scalar)
%
% Output:
% -------
%   dt          Standard deviation of pulse width (microseconds)
%   t_av        First moment (microseconds)
%   fwhh        Full width half height (microseconds)


[dtsqr, t_av] = var (pdf);
dt = sqrt(dtsqr);

if numel(ei)~=1
    dt=dt*ones(size(ei));
    t_av=t_av*ones(size(ei));
end

if nargout==3
    fwhh = width(pdf);
    if numel(ei)~=1
        fwhh=fwhh*ones(size(ei));
    end
end
