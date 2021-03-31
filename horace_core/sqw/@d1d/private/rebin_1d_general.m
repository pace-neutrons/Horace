function [sout,eout,nout]=rebin_1d_general(xin,xout,sin,ein,nin)
%
% A gereral rebinning function for 1-dimensional datasets.
%
% Inputs:   xin - array of x coordinates (bin boundaries) for original data
%           xout - array of x coordinates (bin boundaries) for output
%           sin - signal array of original data (has 1 element fewer than xin)
%           ein - error array (variance, or error^2) of original data
%           nin - npix array of original data
%
% Outputs:  sout - signal array of output (has 1 element fewer than xout)
%           eout - error array of output
%           nout - npix array of output
%
% R.A.E. 25/8/09
%


%========
%Check if arrays are column vectors. If row vectors then reshape them,
%otherwise return error message.

if ~isvector(xin)
    error('Rebinning error: input array of bin boundaries must be a vector');
end
if ~isvector(xout)
    error('Rebinning error: output array of coordinates must be a vector');
end
if ~isvector(sin)
    error('Rebinning error: input array of signal must be a vector');
end
if ~isvector(ein)
    error('Rebinning error: input array of errorbars must be a vector');
end
if ~isvector(nin)
    error('Rebinning error: input array of npix must be a vector');
end
   
%
%Have now established that all inputs are vectors. Now must check that
%their sizes are consistent:
if numel(sin)~=numel(ein) || numel(sin)~=numel(nin)
    error('Rebinning error: input arrays of signals, errors and npix must all be the same size');
end
if numel(xin)~=(numel(sin)+1)
    error('Rebinning error: input array of signals must have 1 element fewer than array of bin boundaries');
end

%Check all inputs are column vectors. If not then reshape them so that they
%are:
if ~iscolvector(xin)
    xin=xin';
end
if ~iscolvector(xout)
    xout=xout';
end
if ~iscolvector(sin)
    sin=sin';
end
if ~iscolvector(ein)
    ein=ein';
end
if ~iscolvector(nin)
    nin=nin';
end

%Check that the ranges of xout and xin are consistent. xout should extend
%further than xin.
if max(xin)>max(xout)
    error('Rebinning error: maximum of output bin boundaries must be >= max of input bin boundaries');
end
if min(xin)<min(xout)
    error('Rebinning error: minimum of output bin boundaries must be <= min of input bin boundaries');
end

%====================

%Check for points where nin is not zero, but errorbar is, and vice versa:
nin_test=double(nin>0);%make this just have zeros or ones
%Must also define points where nin=0 to have ein=0 and sin=0:
ein=ein.*nin_test; sin=sin.*nin_test;
%Likewise for points where ein=0:
sin(ein==0)=0; nin(ein==0)=0;
%also deal with points where sin and/or ein is nan:
ein(isnan(sin))=0; nin(isnan(sin))=0; sin(isnan(sin))=0;
sin(isnan(ein))=0; nin(isnan(ein))=0; ein(isnan(ein))=0;

%We also must convert error to fractional error.
ein_original=ein;
ein=ein./sin;%fractional variance
ein(isnan(ein) | isinf(ein))=0;

%
%Put the data into matrix form, and sort according to ascending xin:
binlo=xin(1:end-1); binhi=xin(2:end);
data_in=[binlo binhi sin ein nin];
data=sortrows(data_in,1);
xinnew=sort(xin);
xinlo=xinnew(1:end-1);%input lower boundaries
xinhi=xinnew(2:end);
xcen=0.5.*(xinlo+xinhi);%input bin centres

%Check for repeated values. This screws things up totally at the moment. A
%later version of this code will address this point, but throw up an error
%for now:
xshift_up=circshift(xinnew,-1); xshift_down=circshift(xinnew,1);
if any(xshift_up==xinnew) || any(xshift_down==xinnew)
    error('Rebinning error: input dataset should not have repeated bin boundaries');
end

%define a small number (to be used later)
dx=diff(xinnew);
eps=1e-5*min(dx);%ensures that our small number is much smaller that the width of the input bins


%Make vector of lower bin boundaries, and vector of upper bin boundaries
%for output:
xout=sort(xout);%ensures that output bin boundaries are also sorted in ascending order
xlo=xout(1:end-1);
xhi=xout(2:end);

lonew=data(:,1); hinew=data(:,2); snew=data(:,3); enew=data(:,4); nnew=data(:,5);

sout=[]; eout=[]; nout=[];

%Rebin algorithm:
for i=1:length(xlo)
   cumulsum=[]; esum=[];
   inbin=(xinnew>xlo(i) & xinnew<xhi(i));%gives us index of a data bin that is inside an output bin
   ind=find(inbin);%returns the indices of these points
   if length(ind)==1
%        %we have a data boundary in output bin, but it is not fully
%        %contained therein
       binfrac=[];
       [cumulsum,esum,nsum]=rebin_1d_multibins(ind,binfrac,snew,enew,nnew,xinnew,eps,xlo,xhi,i);
       %
       %Create final signal, error, npix arrays.
       if ~isempty(cumulsum)
           sout=[sout; cumulsum];
           eout=[eout; esum];
           %nout=[nout; 1];
           nout=[nout; nsum];
       else
           sout=[sout; 0];
           eout=[eout; 0];
           nout=[nout; 0];
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
           sout=[0; sout];
           eout=[0; eout];
           nout=[0; nout];
       end
       if hirange
           sout=[sout; 0];
           eout=[eout; 0];
           nout=[nout; 0];
       end
       
       if ~lorange && ~hirange
           %Otherwise the input bins are larger than the output bins, i.e. we
           %are rebinning on to a finer grid.
           
           [cumulsum,esum,nsum]=rebin_1d_finegrid(snew,enew,nnew,xinnew,lonew,hinew,eps,xlo,xhi,i);
           if ~isempty(cumulsum)
               sout=[sout; cumulsum];
               eout=[eout; esum];
               nout=[nout; nsum];
           else
               sout=[sout; 0];
               eout=[eout; 0];
               nout=[nout; 0];
           end
           
       end
   else
       %one or more data points are contained within this output bin
       binfrac=ones(length(ind)-1,1);
       [cumulsum,esum,nsum]=rebin_1d_multibins(ind,binfrac,snew,enew,nnew,xinnew,eps,xlo,xhi,i);
       %
       %Create final signal, error, npix arrays.
       if ~isempty(cumulsum)
           sout=[sout; cumulsum];
           eout=[eout; esum];
           nout=[nout; nsum];
       else
           sout=[sout; 0];
           eout=[eout; 0];
           nout=[nout; 0];
       end
   end
    
end

%Check that sout, eout, nout are consistent with xout:
if length(sout)<=(length(xout)-2)
    difflen=(length(xout)-length(sout))-1;
    extra=zeros(difflen,1);
    sout=[sout; extra];
    eout=[eout; extra];
    nout=[nout; extra];
end

%Also test for NaNs, or zero errorbar. Convention is that for points with
%nout=0 we will set eout=sout=0, and vice versa:
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
%errors. Replace such points with sout=eout=nout=0:
sout(eout>(1e3.*max(ein)))=0;
nout(eout>(1e3.*max(ein)))=0;
eout(eout>(1e3.*max(ein)))=0;

%And finally convert error back from fractional error to absolute error:
eout=eout.*sout;

%==========================================================================
%==========================================================================

function out=iscolvector(in)
%
% determine if input vector is a column vector. inputs have already been
% checked to determine if they are vectors.
%
[sz1,sz2]=size(in);
if sz1==1 && sz2>=1
    out=false;
elseif sz1>=1 && sz2==1
    out=true;
else
    error('Rebinning error: logic flaw');
end