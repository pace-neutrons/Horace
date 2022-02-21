function ok = retain (obj, t)
% Retain time samples from a moderator pulse shape after rejection
%
%   >> ok = retain (obj, t)
%
% Uses rejection ratio from the probability distribution with repect to a 
% uniform distribution
%
% Input:
% ------
%   obj     IX_moderator object
%
%   t       Array of times (microseconds)
%
% Output:
% -------
%   ok      Logical array with the same size as t; true if the
%           corresponding point is retained, false if rejected
 

if ~isscalar(obj)
    error('IX_moderator:retain:invalid_argument',...
        'Method only takes a scalar object')
end

if ~obj.valid_
    error('IX_moderator:retain:invalid_argument',...
        'Moderator object is not valid')
end

ok = retain (pdf_table(obj), t);

end
