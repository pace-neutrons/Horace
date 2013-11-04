function [xout,yout,sout,eout,nout]=symmetrise_2d_1axis(xin,yin,sin,ein,nin,midpoint)
%
% Symmetrise 2d data about a line at constant x.
%
% R.A.E. 16/9/09
%

%First do some error checking:
if ~isequal(size(sin),size(ein)) || ~isequal(size(sin),size(nin))
    error('Symmetrise error: input arrays of signals, errors and npix must all be the same size');
end
if ~isequal(size(xin),size(yin))
    error('Symmetrise error: input array of x and y coordinates must be the same size');
end
if ~isequal(size(xin),(size(sin)+1))
    error('Symmetrise error: input array of coordinates must have 1 fewer row and 1 fewer column than signal array');
end
%Check that xin and yin are the results of an "ndgrid" command:
if ~isequal((xin-circshift(xin,[0,-1])),zeros(size(xin)))
    error('Symmetrise error: the 1st input array of x coordinates must be of ndgrid form (all elements in each row the same');
end
if ~isequal((yin-circshift(yin,-1)),zeros(size(yin)))
    error('Symmetrise error: the input array of y coordinates must be of ndgrid form (all elements in each column the same');
end
%==========================================================================

%Make vectors giving the x and y coordinates:
xval=xin(:,1); yval=yin(1,:);%these do not need to be sorted, because they should be
%sorted already...

%We must create a second dataset which is a mirror image of the first:
x2=(2.*midpoint)-xval;
y2=yval;
reflsin=[x2(2:end) sin];
reflsin=sortrows(reflsin,1);%sort so that we get data in order of ascending x
reflsin(:,1)=[];
reflein=[x2(2:end) ein];
reflein=sortrows(reflein,1);
reflein(:,1)=[];
reflnin=[x2(2:end) nin];
reflnin=sortrows(reflnin,1);
reflnin(:,1)=[];
%
[reflxin,reflyin]=ndgrid(sort(x2),yval);
%

%Rebin both datasets on to a new set of coordinates that is to the right of
%the midpoint:
max1=max(xval); max2=max(x2);
if max1>=max2
    x_rebin=xval(xval>=midpoint);
else
    x_rebin=x2(x2>=midpoint);
end
%
if min(x_rebin)>midpoint+eps
    x_rebin=[midpoint; x_rebin];
end
%


%Now reshape the arrays so that only data within the range of x_rebin is
%considered:
xin_old=xval; x2_old=sort(x2);%keep the old values for the following manipulations (and reference in debug)
xin([xin_old<midpoint],:)=[]; yin([xin_old<midpoint],:)=[];
sin([xin_old(1:end-1)<midpoint],:)=[];
ein([xin_old(1:end-1)<midpoint],:)=[]; nin([xin_old(1:end-1)<midpoint],:)=[];
reflxin([x2_old<midpoint],:)=[]; reflyin([x2_old<midpoint],:)=[];
reflsin([x2_old(1:end-1)<midpoint],:)=[];
reflein([x2_old(1:end-1)<midpoint],:)=[]; reflnin([x2_old(1:end-1)<midpoint],:)=[];


%==
[xtemp1,ytemp1,stemp1,etemp1,ntemp1]=rebin_2d_1axis(xin,yin,x_rebin,sin,ein,nin);
[xtemp2,ytemp2,stemp2,etemp2,ntemp2]=rebin_2d_1axis(reflxin,reflyin,x_rebin,reflsin,reflein,reflnin);

%
%Now combine the two rebinned datasets:
[xout,yout,sout,eout,nout]=combine_2d(xtemp1,ytemp1,stemp1,etemp1,ntemp1,...
    xtemp2,ytemp2,stemp2,etemp2,ntemp2,[]);

