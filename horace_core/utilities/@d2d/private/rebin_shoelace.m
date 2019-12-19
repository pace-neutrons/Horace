function [sout,eout,nout]=rebin_shoelace(xin,yin,sin,ein,nin,xout,yout)
%
% Function which rebins using the shoelace algorithm. For the case where
% the input and output axes are not parallel, so we specify the bins by
% their (4) corners, rather than their edges. Note that we do not specify
% that either input or rebinned datasets necessarily lie on an orthogonal
% grid.
%
% COMMENTS CONCERNING THE FORM OF THE INPUT GO HERE
%
% RAE/JRS 17/9/09
%

%This code is supposed to be a more general version of the test that was
%made in May 2009.

%==========================================================================
%Error checks
%=============
%Check format of inputs:
if ~isequal(size(xin),size(yin))
    error('Rebinning error: matrices specifying input bin corners'' x and y must be the same size');
end
[sz1,sz2]=size(xin);
if sz1~=4
    error('Rebinning error: input bins must be quadrilaterals');
end
if ~isequal(size(sin),size(ein)) || ~isequal(size(sin),size(nin))
    error('Rebinning error: matrices specifying signal, error, and npix must be the same size');
end
if ~isequal(size(xout),size(yout))
    error('Rebinning error: matries specify output bin corners'' x and y must be the same size');
end
[sz1,sz2]=size(xout);
if sz1~=4
    error('Rebinning error: output bins must be quadrilaterals');
end
%
%Need to have an error check to ensure that both input and output bins
%coordinates do actually define closed pixels on a closed grid. This is
%somewhat tricky to do, so need to think a bit about it. We want the
%coordinates to be of the form [sw1,sw2,...; se1,se2,...; ne1,ne2,...;
%nw1,nw2, ...]

%==========================================================================
%We must do some book keeping to ensure we get rid of NaNs, zero errorbars,
%etc. otherwise we get empty pixels where we shouldn't.
nin_test=double(nin>0);%matrix of zeros and ones
sin=sin.*nin_test; ein=ein.*nin_test;
okerr=double(ein>0);
sin=sin.*okerr; nin=nin.*okerr;

%Likewise, we must find points where either sin or ein are NaN, and replace
%with zeros:
ein(isnan(sin))=0; nin(isnan(sin))=0; sin(isnan(sin))=0;
sin(isnan(ein))=0; nin(isnan(ein))=0; ein(isnan(ein))=0;

%==========================================================================

%First up we must convert errors into fractional errors:
ein_original=ein;%for debug purposes
ein=ein./sin;
ein(isnan(ein) | isinf(ein))=0;%in case we divided by zero, or had zero/zero.


%First calculate the areas of all the input and output bins:
inarea=polyarea(xin,yin);
outarea=polyarea(xout,yout);

%Now determine for a given output bin which input bins are likely to
%contribute to it:
likely=shoelace_preprocess(xin,yin,xout,yout);%the output of this function is a cell array
%the number of cells is the same as the number of output bins. Each cell
%contains the indices of the input bins that MIGHT contribute to that
%output bin.

%Now let us do a bit of book-keeping. Put the relevant data into a set of
%cell arrays, each of which have one element per output bin.
[xtmp,ytmp,inarea_tmp,outarea_tmp,stmp,etmp,ntmp]=shoelace_rearrangement(xin,yin,...
    inarea,outarea,sin,ein,nin,likely);


%Now comes the nitty gritty of calculating the overlap area between input
%and output bins:
sz=size(xout);
nbin=sz(2);

%Be careful here about how we deal with empty elements.
for i=1:nbin
    if ~isempty(xtmp{i})
        %debug:
%         if i==955
%             why;
%         end
        Area{i}=shoelace_areacalc(xout(:,i),yout(:,i),xtmp{i},ytmp{i},inarea_tmp{i},outarea_tmp{i});
    else
        Area{i}=0;%for the case where output bins are out of range of any input bins.
    end
end

%==
area_fraction=cell(size(Area)); signal=area_fraction;
sigerror=area_fraction; npix=area_fraction;

% figure;
% patch(xin,yin,ones(1,4159));

for i=1:numel(Area)
    if any(Area{i}~=0)
%         patch(xout(:,i),yout(:,i),i); caxis([i-1 i]);
        area_fraction{i}=Area{i}./inarea(likely{i});
        frac=area_fraction{i};
        fracnew=frac(frac>0 & frac<1+eps);
        snew=stmp{i}; snew=snew(frac>0 & frac<1+eps);
        enew=etmp{i}; enew=enew(frac>0 & frac<1+eps);
        nnew=ntmp{i}; nnew=nnew(frac>0 & frac<1+eps);
        fracnew=fracnew(nnew>0);
        snew=snew(nnew>0); enew=enew(nnew>0); nnew=nnew(nnew>0);
        npix{i}=sum(fracnew.*nnew);
        signal{i}=sum(fracnew.*snew./(enew))./sum(fracnew./enew);
        sigerror{i}=1./sum(fracnew./enew);
    else
        npix{i}=0; signal{i}=0; sigerror{i}=0;
    end
end

sout=cell2mat(signal);
eout=cell2mat(sigerror);
nout=cell2mat(npix);

%Pernultimately check for nonsensical output (e.g. NaNs, or error=0 or Inf)
sout(eout==0 | isinf(eout) | isnan(eout))=0;
nout(eout==0 | isinf(eout) | isnan(eout))=0;
eout(eout==0 | isinf(eout) | isnan(eout))=0;
%
nout(isinf(sout) | isnan(sout))=0;
eout(isinf(sout) | isnan(sout))=0;
sout(isinf(sout) | isnan(sout))=0;
%
sout(nout==0)=0;
eout(nout==0)=0;
%

%Finally convert error back to absolute from fractional:
eout=eout.*sout;




