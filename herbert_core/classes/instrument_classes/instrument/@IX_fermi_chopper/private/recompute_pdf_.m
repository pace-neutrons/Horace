function pdf = recompute_pdf_ (obj)
% Compute the pdf_table object for the Fermi chopper pulse shape
%
%   >> pdf = recompute_pdf_ (obj)
%
% Input:
% -------
%   obj     IX_fermi_chopper object (scalar)
%
% Output:
% -------
%   pdf     pdf_table object for the chopper pulse as a function of time


if ~isscalar(obj)
    error('IX_fermi_chopper:recompute_pdf_:invalid_argument',...
        'Method only takes a scalar object')
end

% Calculate widths
[pk_fwhh, gam] = get_pulse_props_ (obj, obj.energy, obj.phase);

if pk_fwhh==0 && gam==0
    % Delta function transmission
    pdf = pdf_table(0, Inf);
    
else
    % Non-zero width or no transmission
    if obj.transmission()>0
        npnt = 100;
        [tlo, thi] = pulse_range (obj);
        t = linspace (tlo, thi, npnt);
        y = pulse_shape (obj, t);
        pdf = pdf_table (t, y);
    else
        pdf = pdf_table();  % null pdf
    end
end

end
