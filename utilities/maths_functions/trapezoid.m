function y = trapezoid (x, w1_in, w2_in, w3_in, h12_in, h23_in)
% Trapezoid i.e. generally *not* flat topped
%
%   >> y = trapezoid (x, w1, w2, w3, h12, h23)
%
% Defined by the lines joining the points:
%   (0,0)-(w1,h12)-(w1+w2,h23)-(w1+w2+w3,0)
%
% and shifted so that it has zero first moment.
%
% Works even if w1=w2=0, when gives y=Inf at x=0, and y=0 everywhere else.

y= zeros(size(x));
w1=abs(w1_in); w2=abs(w2_in); w3=abs(w3_in); h12=abs(h12_in); h23=abs(h23_in);

xav=(h23*(w2+2*w3)*(w2+w3)-h12*(w2+2*w1)*(w2+w1))/(h23*(w2+w3)+h12*(w2+w1))/6;
x0=x+xav;
range1=(x0>-(w1+w2/2) & x0<-w2/2);
range2=(x0>=-w2/2 & x0<=w2/2);
range3=(x0<(w3+w2/2) & x0>w2/2);

y(range1)=(h12/w1)*(x0(range1)+(w1+w2/2));
y(range2)=(h23+h12)/2 + (h23-h12)*(x0(range2)/w2);
y(range3)=(h23/w3)*((w3+w2/2)-x0(range3));
