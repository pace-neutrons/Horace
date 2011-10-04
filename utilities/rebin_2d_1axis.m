function [xnew,ynew,sout,eout,nout]=rebin_2d_1axis(xin,yin,xout,sin,ein,nin)

%
% A rebinning function for 2-dimensional datasets.
% 
% Rebins a 2-dimensional dataset along the x-axis only, provided the
% direction of the x-axis is the same for the input and output bins.
%
% Inputs:   xin - matrix of x coordinates (bin boundaries) for original data
%           yin - matrix of y coordinates (bin boundaries) for original data
%           xout - vector of x coordinates (bin boundaries) for output
%           sin - signal array of original data (has 1 fewer rows and columns than xin and yin)
%           ein - error array of original data
%           nin - npix array of original data
%
% Outputs:  xnew - matrix of output x coordinates (bin boundaries, ndgrid format) 
%           ynew - matrix of output y coordinates (bin boundaries, ndgrid format)
%           sout - signal array of output (has 1 fewer rows than xout and 1 fewer columns than yin)
%           eout - error array of output
%           nout - npix array of output
%
% R.A.E. 25/8/09

%========
%Check that arrays are matrices of the correct size:

small=1e-5.*max(abs(xout));


if ~isequal(size(sin),size(ein)) || ~isequal(size(sin),size(nin))
    error('Rebinning error: input arrays of signals, errors and npix must all be the same size');
end
if ~isequal(size(xin),size(yin))
    error('Rebinning error: input array of x and y coordinates must be the same size');
end
if ~isequal(size(xin),(size(sin)+1))
    error('Rebinning error: input array of coordinates must have 1 more row and 1 more column than signal array');
end

%Check that xin and yin are the results of an "ndgrid" command:
if ~isequal((xin-circshift(xin,[0,-1])),zeros(size(xin)))
    error('Rebinning error: the input array of x coordinates must be of ndgrid form (all elements in each row the same');
end
if ~isequal((yin-circshift(yin,-1)),zeros(size(yin)))
    error('Rebinning error: the input array of y coordinates must be of ndgrid form (all elements in each column the same');
end

%Check that the ranges of xout and xin are consistent. xout should extend
%further than xin.
if max(max(xin))>(max(max(xout)+small))
    error('Rebinning error: maximum of output bin boundaries must be >= max of input bin boundaries');
end
if (min(min(xin)))<min(min(xout)-small)
    error('Rebinning error: minimum of output bin boundaries must be <= min of input bin boundaries');
end

%==========================================================================

%Before we do anything, we need to find points where npix is zero, or where
%the errorbar is zero, and set s=e=n=0:
nin_test=double(nin>0);%matrix of zeros and ones
sin=sin.*nin_test; ein=ein.*nin_test;
okerr=double(ein>0);
sin=sin.*okerr; nin=nin.*okerr;

%Likewise, we must find points where either sin or ein are NaN, and replace
%with zeros:
ein(isnan(sin))=0; nin(isnan(sin))=0; sin(isnan(sin))=0;
sin(isnan(ein))=0; nin(isnan(ein))=0; ein(isnan(ein))=0;

%We also must convert error to fractional error.
ein_original=ein;
ein=ein./sin;%fractional variance
ein(isnan(ein) | isinf(ein))=0;

%Sort according to ascending xin:
xinlo=xin([1:end-1],[1:end-1]); xinhi=xin([2:end],[1:end-1]);
%nin=double(nin>0);%make this just have zeros or ones

xtosort=xinlo(:,1);

snew=sortrows([xtosort sin],1); snew(:,1)=[];%2nd command gets rid of 1st col, which specifies x co-ord
enew=sortrows([xtosort ein],1); enew(:,1)=[];
nnew=sortrows([xtosort nin],1); nnew(:,1)=[];

%Check for repeated values. This screws things up totally at the moment. A
%later version of this code will address this point, but throw up an error
%for now:
xshift_up=circshift(xin(:,1),-1); xshift_down=circshift(xin(:,1),1);
if any(xshift_up==xin(:,1)) || any(xshift_down==xin(:,1))
    error('Rebinning error: input dataset should not have repeated bin boundaries');
end

%define a small number (to be used later)
dx=diff(xin(:,1));
eps=1e-5*min(dx);%ensures that our small number is much smaller that the width of the input bins

%Make vector of lower bin boundaries, and vector of upper bin boundaries
%for output:
xout=sort(xout);%ensures that output bin boundaries are also sorted in ascending order
xlo=xout(1:end-1);
xhi=xout(2:end);

%Note the largest errorbar in the input dataset:
maxerr=max(max(ein));

%Intialise the outputs:
[sz1,sz2]=size(sin);
sout=[]; eout=sout; nout=sout;
xinnew=xin(:,1);
lonew=xinnew(1:end-1); hinew=xinnew(2:end);
filler=zeros(1,sz2);

%Make xnew and ynew matrices:
[xnew,ynew]=ndgrid(xout,yin(1,:));

%Now do the rebinning:
for i=1:length(xlo)
   cumulsum=[]; esum=[];
   inbin=(xinnew>xlo(i) & xinnew<xhi(i));%gives us index of a data bin that is inside an output bin
   ind=find(inbin);%returns the indices of these points
   if length(ind)==1
%        %we have a data boundary in output bin, but it is not fully
%        %contained therein
       binfrac=[];
       [cumulsum,esum,nsum]=rebin_2d_1axis_multibins(ind,binfrac,snew,enew,nnew,xinnew,eps,xlo,xhi,i);
       %
       %Create final signal, error, npix arrays.
       if ~isempty(cumulsum)
           sout=[sout; cumulsum];
           eout=[eout; esum];
%            ntmp=ones(size(cumulsum));
%            ntmp(cumulsum==0 & esum==0)=0;
%            ntmp(esum>(1e2.*maxerr))=0;
%            nout=[nout; ntmp];
           nout=[nout; nsum];
       else
           sout=[sout; filler];
           eout=[eout; filler];
           nout=[nout; filler];
       end
   elseif isempty(ind)
       %There are no input bin boundaries in this output bin. Variety of
       %possible reasons for this...
       %
       %Either the input and output bins do not overlap in this region
       %(e.g. the lower range of the output is lower than the lower range
       %of the input). This is relatively simple to deal with.
       lorange=xlo(i)<min(xinnew);
       hirange=xhi(i)>max(xinnew);
       if lorange
           sout=[filler; sout];
           eout=[filler; eout];
           nout=[filler; nout];
       end
       if hirange
           sout=[sout; filler];
           eout=[eout; filler];
           nout=[nout; filler];
       end
       
       if ~lorange && ~hirange
           %Otherwise the input bins are larger than the output bins, i.e. we
           %are rebinning on to a finer grid.
           
           [cumulsum,esum,nsum]=rebin_2d_1axis_finegrid(snew,enew,nnew,xinnew,lonew,hinew,eps,xlo,xhi,i);
           if ~isempty(cumulsum)
               sout=[sout; cumulsum];
               eout=[eout; esum];
%            ntmp=ones(size(cumulsum));
%            ntmp(cumulsum==0 & esum==0)=0;
%            ntmp(esum>(1e2.*maxerr))=0;
%            nout=[nout; ntmp];
               nout=[nout; nsum];
           else
               sout=[sout; filler];
               eout=[eout; filler];
               nout=[nout; filler];
           end
           
       end
   else
       %one or more data points are contained within this output bin
       binfrac=ones(length(ind)-1,1);
       [cumulsum,esum,nsum]=rebin_2d_1axis_multibins(ind,binfrac,snew,enew,nnew,xinnew,eps,xlo,xhi,i);
       %
       %Create final signal, error, npix arrays.
       if ~isempty(cumulsum)
           sout=[sout; cumulsum];
           eout=[eout; esum];
%            ntmp=ones(size(cumulsum));
%            ntmp(cumulsum==0 & esum==0)=0;
%            ntmp(esum>(1e2.*maxerr))=0;
%            nout=[nout; ntmp];
           nout=[nout; nsum];
       else
           sout=[sout; filler];
           eout=[eout; filler];
           nout=[nout; filler];
       end
   end
    
end

%Check that sout, eout, nout are consistent with xout:
[rowout,colout]=size(sout);
[rowx,colx]=size(xout);
if rowout<=rowx-2
    difflen=(rowx-rowout)-1;
    extra=zeros(difflen,colout);
    sout=[sout; extra];
    eout=[eout; extra];
    nout=[nout; extra];
end

%Also define the output such that if eout=0, sout=0 and nout=0, and so on.
nout(isnan(sout))=0;
eout(isnan(sout))=0;
sout(isnan(sout))=0;
%
nout(eout==0)=0;
sout(eout==0)=0;
%
sout(nout==0)=0;
eout(nout==0)=0;


%Penultimately test for points where we got a huge errorbar due to rounding
%errors. Replace such points with sout=eout=nout=0
sout(eout>(1e2.*max(max(ein))))=0;
nout(eout>(1e2.*max(max(ein))))=0;
eout(eout>(1e2.*max(max(ein))))=0;

%And finally convert the error back from fractional error to absolute
%error:
eout=eout.*sout;