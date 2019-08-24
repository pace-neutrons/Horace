function [y,t] = table_pulse_shape (pdf, t)
% Return normalised pulse width function
%
%   >> [y,t] = table_pulse_shape (pdf, t)
%
% Input:
% -------
%   pdf         pdf_table object
%
%   t           Array of times at which to evaluate pulse shape (microseconds)
%               If empty, uses a suitable set of points
%
% Output:
% -------
%   y           Pulse shape. Normalised so pulse has unit area
%
%   t           If input was not empty, same as imput argument
%               If input was empty, the default set of points


if isempty(t)
    t = pdf.x;
    y = pdf.f;
else
    y = interp1(pdf.x, pdf.f, t, 'linear', 0);
end
