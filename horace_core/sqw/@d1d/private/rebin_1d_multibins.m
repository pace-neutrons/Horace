function [cumulsum,esum,nout]=rebin_1d_multibins(ind,binfrac,snew,enew,nnew,xinnew,eps,xlo,xhi,i)
%
% Subroutine to deal with the case when more than one input bin boundary
% lies in an output bin.
%
% RAE 3/9/09
%

%Must first deal with cases where npix=0 - i.e. a given element of snew and
%enew is zero:
enew(snew==0 & enew==0)=1e5.*max(snew);%i.e. make this point have zero weight in the calculations

%Determine bits on either end (if there are any):
dlo=xinnew(ind(1))-xlo(i); dhi=xhi(i)-xinnew(ind(end));
if ind(1)~=1
   lofrac=eps+dlo./(xinnew(ind(1)) - xinnew(ind(1)-1));
end
if ind(end)~=length(xinnew)
   hifrac=eps + dhi./(xinnew(ind(end)+1) - xinnew(ind(end)));
end
%accumulate signal and error:
if exist('lofrac','var') && exist('hifrac','var')
   binfrac=[lofrac; binfrac; hifrac];
   cumulsum=sum(binfrac.*snew(ind(1)-1:ind(end))./enew(ind(1)-1:ind(end)))./...
       sum(binfrac./enew(ind(1)-1:ind(end)));
   esum=1./...
       sum(binfrac./enew(ind(1)-1:ind(end)));
   nout=sum(binfrac.*nnew(ind(1)-1:ind(end)));
elseif exist('hifrac','var')
   binfrac=[binfrac; hifrac];
   cumulsum=sum(binfrac.*snew(ind(1):ind(end))./enew(ind(1):ind(end)))./...
       sum(binfrac./enew(ind(1):ind(end)));
   esum=1./...
       sum(binfrac./enew(ind(1):ind(end)));
   nout=sum(binfrac.*nnew(ind(1):ind(end)));
elseif exist('lofrac','var')
   binfrac=[lofrac; binfrac];
   cumulsum=sum(binfrac.*snew(ind(1)-1:ind(end)-1)./enew(ind(1)-1:ind(end)-1))./...
       sum(binfrac./enew(ind(1)-1:ind(end)-1));
   esum=1./...
       sum(binfrac./enew(ind(1)-1:ind(end)-1));
   nout=sum(binfrac.*nnew(ind(1)-1:ind(end)-1));
else
   cumulsum=sum(binfrac.*snew(ind(1):ind(end)-1)./enew(ind(1):ind(end)-1))./...
       sum(binfrac./enew(ind(1):ind(end)-1));
   esum=1./...
       sum(binfrac./enew(ind(1):ind(end)-1));
   nout=sum(binfrac.*nnew(ind(1):ind(end-1)));
end

