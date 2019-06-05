function pdf = recompute_pdf_ (obj)
% Compute the pdf_table object for the Fermi chopper pulse shape
%
%   >> pdf = recompute_pdf_ (moderator)
%
% Input:
% -------
%   moderator   IX_fermi_chopper object (scalar only)
%
% Output:
% -------
%   pdf         pdf_table object


if ~isscalar(obj), error('Function only takes a scalar Fermi chopper object'), end

npnt = 100;
if obj.transmission()>0
    [tlo, thi] = pulse_range(obj);
    t = linspace(tlo,thi,npnt);
    y = pulse_shape(obj, t);
    pdf = pdf_table(t,y);
else
    pdf = pdf_table();
end
