function [sout,eout]=dnd_normalise_sigerr(s,e,n)
% Normalise the signal and error bars for manipulations of dnd such as addition, multiplication etc
% Output will contain NaN for those elements of s that had corresponding n=0.
n(find(n==0))=NaN;
sout=s./n;
eout=e./(n.^2);