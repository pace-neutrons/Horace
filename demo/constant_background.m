function y=constant_background(x1,x2,p)
%
% constant background, specified by p in y=constant_background(x1,x2,p)
% background for 2d slice only
%

y=ones(size(x1)) .* p;
