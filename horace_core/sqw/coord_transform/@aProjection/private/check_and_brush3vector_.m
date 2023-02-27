function val = check_and_brush3vector_(val)
% Helper function verifying setting 3 vector defining direction
% and modifying it to have standard row form avoiding small values in
% some directions when other directions are not small.

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

