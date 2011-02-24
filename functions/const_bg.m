function y=const_bg(x,pin)
%
% Background function to return an array the same size as x, all of whose
% entries are a constant
%

if ~isscalar(pin)
    error('Input parameters must be a single number');
end
    

y=pin.*ones(size(x));