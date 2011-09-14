function type=cut_type(w)
% Get cut type
%   - 'bare', 'sx_mfit'
if isempty(w.appendix)
    type='bare';
else
    type='sx_mfit';
end
