function pdf = table_recompute_pdf (pp)
% Compute the pdf_table object for 'table' pulse shape
%
%   >> pdf = table_recompute_pdf (pp)
%
% Input:
% -------
%   pp          Arguments for computation of moderator time pulse. One of:
%                   - A probability distribution object (i.e. an object of
%                    class pdf_table)
%                   - A cell array with two numeric vectors with
%                    the same number of elements; pp{1} is the time
%                    in microseconds and pp{2} the value of the pusle shape
%                    pp{1} must be monotonic increasing; pp{2} need not be
%                    normalised, as this will be performed internally
%
% Output:
% -------
%   pdf         pdf_table object


if isscalar(pp) && isa(pp,'pdf_table')
    pdf = pp;
else
    try
        if iscell(pp)
            pdf = pdf_table(pp{:});
        else
            pdf = pdf_table(pp);
        end
    catch ME
        error(['Moderator parameters: ',ME.message])
    end
end
