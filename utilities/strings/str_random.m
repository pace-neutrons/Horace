function str=str_random(n)
% Create random string with length n (default: n=12)
%
%   >> str=str_random
%
%   >. str=str_random(n)

% T.G.Perring 3 August 2010

ch='0123456789qwertyuiopasdfghjklzxcvbnmm';
time=now;
sec=86400*(time-floor(time));
msec=1000*(sec-floor(sec));
if nargin==0, n=12; end
ind=round(mod(36*rand(1,n)+msec,36)+0.5)+1;
str=ch(ind);
