function y = conv_hh (x, w1, w2)
% Convolution of two normalised hat functions centred at x=0
%
%   >> y = conv_hh (x, w1, w2)
%
%   w1, w2  Full width of two hat functions. Absolute value used
%           for negative values
%
% Works even if w1=w2=0, when gives y=Inf at x=0, and y=0 everywhere else.

% Based on original version by Joost van Duijn
%
% Irrespective of the input widths, the convolution will be calculated as
% that of of a broad top hat (width w) with a narrow top hat
% (width delta).
%
%             ____|____ delta*p*q
%            /    |    \
%           /     |    |\
% _________/______|____|_\___________ x
%                 0    |  w/2+delta/2
%                      w/2-delta/2

if abs(w1)>=abs(w2)
    w = abs(w1);
    delta=abs(w2);
else
    w = abs(w2);
    delta = abs(w1);
end

xmod= abs(x);
y= zeros(size(xmod));
range2= xmod<=((w-delta)/2);
range1= xmod<=((w+delta)/2) & ~range2;
y(range2)= 1/w;
y(range1)= (1/(w*delta))*(((w+delta)/2)-xmod(range1));
