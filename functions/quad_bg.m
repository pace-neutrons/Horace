function y=quad_bg(x,pin)
%
% Background function to return an array the same size as x, the values of
% which are defined by y=p(1) + p(2)*x + p(3)*x.^2
%

if ~isvector(pin) || length(pin)~=3
    error('Input parameters must be a vector of length 3');
end
    

y=pin(1) + pin(2).*x + pin(3).*(x.^2);