function [w, tlo, thi] = table_pulse_width2 (pdf, frac, ei)
% Calculate pulse width quantities (microseconds)
%
%   >> [w, tlo, thi] = table_pulse_width2 (pdf, frac, ei)
%
% Input:
% -------
%   pdf         pdf_table object
%   frac        Fraction of peak height at which to determine the width
%   ei          Incident energy (meV) (array or scalar)
%
% Output:
% -------
%   w           Width across the peak (microseconds)
%   tlo         Short time fractional height (microseconds)
%   thi         High time fractional height (microseconds)


w = width(pdf, frac);
tlo = pdf.x(1);
thi = pdf.x(end);
if numel(ei)~=1
    w=w*ones(size(ei));
    tlo=tlo*ones(size(ei));
    thi=thi*ones(size(ei));
end
