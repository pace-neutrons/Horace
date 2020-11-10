function [xout,yout,sout,eout,nout]=combine_2d(x1,y1,s1,e1,n1,x2,y2,s2,e2,n2,tol)
%
% Combine two 2d datasets.
%
% Inputs:   x1 - matrix specifying bin boundaries on x-axis of 1st dataset
% (ndgrid format)
%           y1 - matrix specifying bin boundaries on y-axis of 1st dataset
% (ndgrid format)
%           s1 - matrix specifying signal of 1st dataset (size is 1
%           less than x1 along both directions).
%           e1 - matrix specifying variances (error^2) of 1st dataset (size is 1
%           less than x1 along both directions).
%           n1 - number of pixels in 1st dataset.
%           x2, y2, e2, n2 - defined similarly for 2nd dataset.
%           tol=[tolx,toly] - optional input. Output x-axis will be a vector of form
%           [lo:tolx:hi], where lo and hi are the upper and lower limits of
%           the x-axis of the combined dataset. Similarly for toly. Note that if you only
%           wish to specify a tolerance along the x-axis then tol=[tolx,0],
%           and for the y-axis only tol=[0,toly].
%
% RAE 15/9/09
%


%First do some error checking:
if ~isequal(size(s1),size(e1)) || ~isequal(size(s1),size(n1))
    error('Combine error: 1st input arrays of signals, errors and npix must all be the same size');
end
if ~isequal(size(x1),size(y1))
    error('Combine error: 1st input array of x and y coordinates must be the same size');
end
if ~isequal(size(x1),(size(s1)+1))
    error('Combine error: 1st input array of coordinates must have 1 fewer row and 1 fewer column than signal array');
end
%Check that x1 and y1 are the results of an "ndgrid" command:
if ~isequal((x1-circshift(x1,[0,-1])),zeros(size(x1)))
    error('Combine error: the 1st input array of x coordinates must be of ndgrid form (all elements in each row the same');
end
if ~isequal((y1-circshift(y1,-1)),zeros(size(y1)))
    error('Combine error: the 1st input array of y coordinates must be of ndgrid form (all elements in each column the same');
end
%==
if ~isequal(size(s2),size(e2)) || ~isequal(size(s2),size(n2))
    error('Combine error: 2nd input arrays of signals, errors and npix must all be the same size');
end
if ~isequal(size(x2),size(y2))
    error('Combine error: 2nd input array of x and y coordinates must be the same size');
end
if ~isequal(size(x2),(size(s2)+1))
    error('Combine error: 2nd input array of coordinates must have 1 fewer row and 1 fewer column than signal array');
end
%Check that x2 and y2 are the results of an "ndgrid" command:
if ~isequal((x2-circshift(x2,[0,-1])),zeros(size(x2)))
    error('Combine error: the 2nd input array of x coordinates must be of ndgrid form (all elements in each row the same');
end
if ~isequal((y2-circshift(y2,-1)),zeros(size(y2)))
    error('Combine error: the 2nd input array of y coordinates must be of ndgrid form (all elements in each column the same');
end

%==========================================================================
%==========================================================================

%Determine the data range:
xlo1=min(min(x1)); xhi1=max(max(x1));
xlo2=min(min(x2)); xhi2=max(max(x2));
ylo1=min(min(y1)); yhi1=max(max(y1));
ylo2=min(min(y2)); yhi2=max(max(y2));

if isempty(tol)
    tol=[0,0];
end

[row1,col1]=size(x1);
[row2,col2]=size(x2);

%First we will sort out the data along the x-axis
if isnan(tol(1)) || tol(1)==0
    if xlo1<=xlo2 && xhi1>=xhi2
        xnew=x1(:,1);
    elseif xlo2<=xlo1 && xhi2>=xhi1
        xnew=x2(:,1);
    elseif xlo2<xlo1 && xhi2<=xhi1
        %use x2 for lower end of dataset, and x1 for the upper end
        xnew=x2(:,1);
        xnew=xnew(xnew<xlo1);
        xnew=[xnew; x1(:,1)];
    elseif xlo1<xlo2 && xhi1<=xhi2
        %use x1 for lower end of dataset, and x2 for upper end
        xnew=x1(:,1);
        xnew=xnew(xnew<xlo2);
        xnew=xnew(:,1);
        xnew=[xnew; x2(:,1)];
    end
else
    if xlo1<=xlo2 && xhi1>=xhi2
        xnew=[xlo1:tol(1):(xhi1+tol(1)-eps)];%will use rebin function, for which x-axis of output needs
        %only to be a vector
    elseif xlo2<=xlo1 && xhi2>=xhi1
        xnew=[xlo2:tol(1):(xhi2+tol(1)-eps)];
    elseif xlo2<xlo1 && xhi2<=xhi1
        xnew=[xlo2:tol(1):(xhi1+tol(1)-eps)];
    elseif xlo1<xlo2 && xhi1<=xhi2
        xnew=[xlo1:tol(1):(xhi2+tol(1)-eps)];%extra bit due to chance of rounding errors
    end
end
%
%Next we'll deal with the y-axis:
if isnan(tol(2)) || tol(2)==0
    if ylo1<=ylo2 && yhi1>=yhi2
        ynew=y1(1,:);
    elseif ylo2<=ylo1 && yhi2>=yhi1
        ynew=y2(1,:);
    elseif ylo2<ylo1 && yhi2<=yhi1
        %use y2 for lower end of dataset, and y1 for the upper end
        ynew=y2(1,:);
        ynew=ynew(ynew<ylo1);
        ynew=ynew(1,:);
        ynew=[ynew y1(1,:)];
    elseif ylo1<ylo2 && yhi1<=yhi2
        %use y1 for lower end of dataset, and y2 for upper end
        ynew=y1(1,:);
        ynew=ynew(ynew<ylo2);
        ynew=ynew(1,:);
        ynew=[ynew y2(1,:)];
    end
else
    if ylo1<=ylo2 && yhi1>=yhi2
        ynew=[ylo1:tol(2):(yhi1+tol(2)-eps)];
    elseif ylo2<=ylo1 && yhi2>=yhi1
        ynew=[ylo2:tol(2):(yhi2+tol(2)-eps)];
    elseif ylo2<ylo1 && yhi2<=yhi1
        ynew=[ylo2:tol(2):(yhi1+tol(2)-eps)];
    elseif ylo1<ylo2 && yhi1<=yhi2
        ynew=[ylo1:tol(2):(yhi2+tol(2)-eps)];
    end
end
%


[xval1,yval1,sig1,err1,npix1]=rebin_2d(x1,y1,s1,e1,n1,xnew,ynew);
[xval2,yval2,sig2,err2,npix2]=rebin_2d(x2,y2,s2,e2,n2,xnew,ynew);
[xout,yout]=ndgrid(xnew,ynew);

%As with the rebinning function, to perform calculations we must convert
%error from absolute error to fractional error:
err1_old=err1; err2_old=err2;
err1=err1./sig1; err2=err2./sig2;%fractional variance
err1(isnan(err1) | isinf(err1))=0;
err2(isnan(err2) | isinf(err2))=0;
%
biggest=[max(max(sig1)) max(max(sig2))];
err1=err1+((err1==0).*1e5.*max(biggest));
err2=err2+((err2==0).*1e5.*max(biggest));
sout=(sig2./err2 + sig1./err1)./(1./err2 + 1./err1);
eout=1./(1./err2 + 1./err1);
nout=npix1+npix2;
nout(err1_old==0 & err2_old==0)=0;
sout(err1_old==0 & err2_old==0)=0;
eout(err1_old==0 & err2_old==0)=0;
%
%Convert fractional error back to absolute error:
eout=eout.*sout;
