function [cumulsum,esum,nsum]=rebin_1d_finegrid(snew,enew,nnew,xinnew,lonew,hinew,...
    eps,xlo,xhi,i)
%
% Subroutine to rebin in the case where the output grid is smaller than the input grid.
%
% R.A.E. 16/9/09
%

%Note that points where snew and enew are both zero can sometimes give rise
%to funny edge effects where the output errorbar is huge. Need to think
%about how to deal with this

%Determine the fraction of the input bin that is sampled by the output bin:
lo=xlo(i); hi=xhi(i);
binind=find(lonew<=lo & hinew>=hi);%find index of bin being sampled
insize=hinew(binind)-lonew(binind);
outsize=hi-lo;
frac=outsize./insize;


cumulsum=(frac.*snew(binind)./enew(binind))./(frac./enew(binind)); 
esum=1./(frac./enew(binind));
nsum=frac.*nnew(binind);