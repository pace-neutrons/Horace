function [cumulsum,esum,nsum]=rebin_2d_1axis_finegrid(snew,enew,nnew,xinnew,lonew,hinew,...
    eps,xlo,xhi,i)
%
% rebin in the case where the output grid is smaller than the input grid.
%

%Determine the fraction of the input bin that is sampled by the output bin:
lo=xlo(i); hi=xhi(i);
binind=find(lonew<=lo & hinew>=hi);%find index of bin being sampled
insize=hinew(binind)-lonew(binind);
outsize=hi-lo;
frac=outsize./insize;

[sz1,sz2]=size(snew);
frac=repmat(frac,1,sz2);

%Calculate the contributions to the output signal and error arrays. The
%output signal array values will be equal to the input signal array values,
%whereas the output error array values will be larger than those of the
%input.
cumulsum=(frac.*snew(binind,:)./enew(binind,:))./(frac./enew(binind,:)); 
esum=1./(frac./enew(binind,:));
%nsum=double(frac>0);
nsum=double(frac.*nnew(binind,:));