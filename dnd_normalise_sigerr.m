function [sout,eout]=dnd_normalise_sigerr(s,e,n)
% Normalise the signal and error bars for manipulations of dnd such as addition, multiplication etc
% Output will contain NaN for those elements of s that had corresponding n=0.
if length(size(s))~=4
    n(find(n==0))=NaN;
    sout=s./n;
    eout=e./(n.^2);
else
    n=double(n);    % NaN for int16 seems to be a zero! i.e. NaN is only a floating point concept (Matlab 7.1)
    n(find(n==0))=NaN;
    sout=s./double(n);
    eout=e./(double(n).^2);
end