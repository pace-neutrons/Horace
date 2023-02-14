function val = check_3vector_(val)
% Verify input 3-vector describing the direction can be considered valid

if ~(isnumeric(val) && numel(val) ==3)
    error('HORACE:aProjection:invalid_argument',...
        'Input should be non-zero length numeric vector with 3 components. It is: "%s"',...
        disp2str(val))
end
cand = val(:)'; % make it row vector
is_small = abs(cand)<aProjection.tol_;
if any(is_small)
    if all(is_small)
        error('HORACE:aProjection:invalid_argument',...
            'Input can not be a 0-vector: [%g,%g,%g] with all components smaller then tol = %g',...
            cand(1),cand(2),cand(3),aProjection.tol_)
    else
        cand(is_small) = 0;
    end
end
val = cand;

