function y = conv_hhh (x, w1, w2, w3)
% Convolution of three normalised hat functions centred at x=0
%   >> y = conv_hhh (x, w1, w2, w3)
%
%   w1, w2, w3  Full width of three hat functions. Absolute value used
%               for negative values.
%
% Works even if w1=w2=0, when gives y=Inf at x=0, and y=0 everywhere else.

wsort=sort(abs([w1,w2,w3]));
a=wsort(3); b=wsort(2); g=wsort(1);

x0=(a+b+g)/2;
x1=(a+b-g)/2;
x2=(a-b+g)/2;
x3=(a-b-g)/2;

xmod=abs(x);
y=zeros(size(x));
range4=(xmod<=abs(x3));
range3=(xmod>abs(x3))&(xmod<=x2);   % only appears if g>0
range2=(xmod>x2)&(xmod<=x1);        % only appears if b>0 and b>g
range1=(xmod>x1)&(xmod<=x0);        % only appears if g>0

if x3>=0
    y(range4)=1/a;
else % only occurs if g>0
    y(range4)=((b*g-x3^2)-xmod(range4).^2)/(a*b*g);
end
y(range3)=(b*g-0.5*(xmod(range3)-x3).^2)/(a*b*g);
y(range2)=(g/2+(x1-xmod(range2)))/(a*b);
y(range1)=(0.5/(a*b*g))*(x0-xmod(range1)).^2;
