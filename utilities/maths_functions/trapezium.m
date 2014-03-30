function y = trapezium (x, w1_in, w2_in, w3_in, h_in)
% Trapezium i.e. flat topped trapezoid
%
%   >> y = trapezium (x, w1, w2, w3, h)
%
% Defined by the lines joining the points:
%   (0,0)-(w1,h)-(w1+w2,h)-(w1+w2+w3,0)
%
% and shifted so that it has zero first moment.
%
% Works even if w1=w2=0, when gives y=Inf at x=0, and y=0 everywhere else.

y = trapezoid (x, w1_in, w2_in, w3_in, h_in, h_in);
