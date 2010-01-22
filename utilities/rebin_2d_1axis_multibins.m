function [cumulsum,esum,nsum]=rebin_2d_1axis_multibins(ind,binfrac,snew,enew,nnew,xinnew,eps,xlo,xhi,i)
%
% 2d rebinning subroutine for the case where one or more input bin
% boundaries lie within an output bin
%

%First deal with what happens if an element of npix was zero:
enew(snew==0 & enew==0)=1e5.*(max(max(snew)));%this gives such points zero weight in the calculation

[sz1,sz2]=size(snew);
binfrac=repmat(binfrac,1,sz2);

%Determine bits on either end (if there are any):
dlo=xinnew(ind(1))-xlo(i); dhi=xhi(i)-xinnew(ind(end));
if ind(1)~=1
   lofrac=eps+dlo./(xinnew(ind(1)) - xinnew(ind(1)-1));
   lofrac=repmat(lofrac,1,sz2);
end
if ind(end)~=length(xinnew)
   hifrac=eps + dhi./(xinnew(ind(end)+1) - xinnew(ind(end)));
   hifrac=repmat(hifrac,1,sz2);
end

%accumulate signal and error. note that we must check if binfrac has only a
%single row, because if so then we need to use the sum command differently
if exist('lofrac','var') && exist('hifrac','var')
   binfrac=[lofrac; binfrac; hifrac];
   cumulsum=sum(binfrac.*snew([ind(1)-1:ind(end)],:)./enew([ind(1)-1:ind(end)],:),1)./...
       sum(binfrac./enew([ind(1)-1:ind(end)],:),1);
   esum=1./...
       sum(binfrac./enew([ind(1)-1:ind(end)],:),1);
   %nsum=double((sum(binfrac,1))>0);
   nsum=double((sum(binfrac.*nnew([ind(1)-1:ind(end)],:),1)));
elseif exist('hifrac','var')
   binfrac=[binfrac; hifrac];
   cumulsum=sum(binfrac.*snew([ind(1):ind(end)],:)./enew([ind(1):ind(end)],:),1)./...
       sum(binfrac./enew([ind(1):ind(end)],:),1);
   esum=1./...
       sum(binfrac./enew([ind(1):ind(end)],:),1);
%    nsum=double((sum(binfrac,1))>0);
   nsum=double((sum(binfrac.*nnew([ind(1):ind(end)],:),1)));
elseif exist('lofrac','var')
   binfrac=[lofrac; binfrac];
   cumulsum=sum(binfrac.*snew([ind(1)-1:ind(end)-1],:)./enew([ind(1)-1:ind(end)-1],:),1)./...
       sum(binfrac./enew([ind(1)-1:ind(end)-1],:),1);
   esum=1./...
       sum(binfrac./enew([ind(1)-1:ind(end)-1],:),1);
   %nsum=double((sum(binfrac,1))>0);
   nsum=double((sum(binfrac.*nnew([ind(1)-1:ind(end)-1],:),1)));
else
   cumulsum=sum(binfrac.*snew([ind(1):ind(end)-1],:)./enew([ind(1):ind(end)-1],:),1)./...
       sum(binfrac./enew([ind(1):ind(end)-1],:),1);
   esum=1./...
       sum(binfrac./enew([ind(1):ind(end)-1],:),1);
   %nsum=double((sum(binfrac,1))>0);
   nsum=double((sum(binfrac.*nnew([ind(1):ind(end)-1],:),1)));
end

%Now convert the nsum bit to either zeros or ones:
%nsum(nsum>0)=1;