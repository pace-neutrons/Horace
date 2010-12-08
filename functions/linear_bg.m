function y=linear_bg(x,pin)
%
% Background function to return an array the same size as x, the values of
% which are defined by y=p(1) + p(2)*x
%

if ~isvector(pin) || length(pin)~=2
    error('Input parameters must be a vector of length 2');
end
    

y=pin(1) + pin(2).*x;