function pdf = recompute_pdf_ (obj)
% Compute the pdf_table object for the double disk chopper pulse shape
%
%   >> pdf = recompute_pdf_ (obj)
%
% Input:
% -------
%   obj         IX_doubledisk_chopper object (scalar only)
%
% Output:
% -------
%   pdf         pdf_table object


if ~isscalar(obj)
    error('IX_doubledisk_chopper:recompute_pdf_:invalid_argument',...
        'Method only takes a scalar double disk chopper object')
end

[tlo, thi] = pulse_range (obj);
if tlo==0
    % delta function transmission
    pdf = pdf_table(0, Inf);
    
else
    % Non-zero width or no transmission
    npnt = 100;
    t = linspace (tlo, thi, npnt);
    y = pulse_shape (obj, t);
    pdf = pdf_table (t,y);
    
end

end
