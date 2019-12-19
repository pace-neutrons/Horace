function [xout,yout,eout,nout]=combine_1d(x1,y1,e1,n1,x2,y2,e2,n2,tol)
%
% Combine two 1d datasets where the x-axis is specified by bin boundaries
% Include the option of a tolerance for the combination (i.e. combine and
% rebin)
%
% Inputs:   x1 - vector specifying bin boundaries on x-axis of 1st dataset.
%           y1 - vector specifying signal of 1st dataset (length is 1 less
%           than length of x1).
%           e1 - vector specifying variances (error^2) of 1st dataset (length is 1
%           less than length of x1).
%           n1 - number of pixels in 1st dataset.
%           x2, y2, e2, n2 - defined similarly for 2nd dataset.
%           tol - optional input. Output x-axis will be a vector of form
%           [lo:tol:hi], where lo and hi are the upper and lower limits of
%           dataset #1 respectively. If no tol specified then the x-axis of
%           the output is the same as that of dataset #1.
%
% R.A.E. 14/9/09
%

%It is important that we deal entirely with column vectors, so check that
%inputs are of this form:
if ~iscolvector(x1) && isvector(x1)
    x1=x1';
elseif iscolvector(x1)
    %do nothing
else
    error('Combine error: 1st set of x-coordinates must be in the form of a column vector');
end
%
if ~iscolvector(y1) && isvector(y1)
    y1=y1';
elseif iscolvector(y1)
    %do nothing
else
    error('Combine error: 1st signal array must be in the form of a column vector');
end
%
if ~iscolvector(e1) && isvector(e1)
    e1=e1';
elseif iscolvector(e1)
    %do nothing
else
    error('Combine error: 1st error array must be in the form of a column vector');
end
%
if ~iscolvector(n1) && isvector(n1)
    n1=n1';
elseif iscolvector(n1)
    %do nothing
else
    error('Combine error: 1st npix array must be in the form of a column vector');
end
%
if ~iscolvector(x2) && isvector(x2)
    x2=x2';
elseif iscolvector(x2)
    %do nothing
else
    error('Combine error: 2nd set of x-coordinates must be in the form of a column vector');
end
%
if ~iscolvector(y2) && isvector(y2)
    y2=y2';
elseif iscolvector(y2)
    %do nothing
else
    error('Combine error: 2nd signal array must be in the form of a column vector');
end
%
if ~iscolvector(e2) && isvector(e2)
    e2=e2';
elseif iscolvector(e2)
    %do nothing
else
    error('Combine error: 2nd error array must be in the form of a column vector');
end
%
if ~iscolvector(n2) && isvector(n2)
    n2=n2';
elseif iscolvector(n2)
    %do nothing
else
    error('Combine error: 2nd npix array must be in the form of a column vector');
end
%

%Determine the data range:
lo1=min(x1); hi1=max(x1);
lo2=min(x2); hi2=max(x2);
if isempty(tol)
    if lo1<=lo2 && hi1>=hi2
        xnew=x1;
    elseif lo2<=lo1 && hi2>=hi1
        xnew=x2;
    elseif lo2<lo1 && hi2<=hi1
        %use x2 for lower end of dataset, and x1 for the upper end
        xnew=x2(x2<lo1);
        xnew=[xnew; x1];
    elseif lo1<lo2 && hi1<=hi2
        %use x1 for lower end of dataset, and x2 for upper end
        xnew=x1(x1<lo2);
        xnew=[xnew; x2];
    end
else
    if lo1<=lo2 && hi1>=hi2
        xnew=[lo1:tol:(hi1+tol-eps)]';%extra bit is to ensure the upper limit is not too low
    elseif lo2<=lo1 && hi2>=hi1
        xnew=[lo2:tol:(hi2+tol-eps)]';
    elseif lo2<lo1 && hi2<=hi1
        xnew=[lo2:tol:(hi1+tol-eps)]';
    elseif lo1<lo2 && hi1<=hi2
        xnew=[lo1:tol:(hi2+tol-eps)]';
    end
end
    
[sig1,err1,npix1]=rebin_1d_general(x1,xnew,y1,e1,n1);%conversion from absolute error to fractional
%error is done internally by the rebinning function
[sig2,err2,npix2]=rebin_1d_general(x2,xnew,y2,e2,n2);
xout=xnew;
%the following errors are absolute. For the calculation of yout and eout we
%must convert them to fractional errors.
err1_old=err1; err2_old=err2;
err1=err1./sig1; err2=err2./sig2;%fractional variance
err1(isnan(err1) | isinf(err1))=0;
err2(isnan(err2) | isinf(err2))=0;
%
biggest=[max(sig1) max(sig2)];
err1(err1==0)=1e5.*max(biggest);
err2(err2==0)=1e5.*max(biggest);
yout=(sig2./err2 + sig1./err1)./(1./err2 + 1./err1);
eout=1./(1./err2 + 1./err1);
nout=npix1+npix2;
nout(err1_old==0 & err2_old==0)=0;
yout(err1_old==0 & err2_old==0)=0;
eout(err1_old==0 & err2_old==0)=0;
%
%Convert error back to absoute from fractional:
eout=eout.*yout;

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
    error('Combine error: logic flaw');
end