function [xout,yout,eout,nout]=symmetrise_1d(xin,yin,ein,nin,midpoint)
%
% Symmetrise 1d dataset about a midpoint. If none supplied then assumes
% symmetrisation about the origin.
%
%

if isempty(midpoint)
    midpoint=0;
end

%It is important that we deal entirely with column vectors, so check that
%inputs are of this form:
if ~iscolvector(xin) && isvector(xin)
    xin=xin';
elseif iscolvector(xin)
    %do nothing
else
    error('Symmetrisation error: x-coordinates must be in the form of a column vector');
end
%
if ~iscolvector(yin) && isvector(yin)
    yin=yin';
elseif iscolvector(yin)
    %do nothing
else
    error('Symmetrisation error: signal array must be in the form of a column vector');
end
%
if ~iscolvector(ein) && isvector(ein)
    ein=ein';
elseif iscolvector(ein)
    %do nothing
else
    error('Symmetrisation error: error array must be in the form of a column vector');
end
%
if ~iscolvector(nin) && isvector(nin)
    nin=nin';
elseif iscolvector(nin)
    %do nothing
else
    error('Symmetrisation error: npix array must be in the form of a column vector');
end
%

%==========================================================================

%Sort the data:
data=[xin(2:end) yin ein nin];
data=sortrows(data,1);
xin=sort(xin); yin=data(:,2); ein=data(:,3); nin=data(:,4);

%We must create a second dataset which is a mirror image of the first:
x2=(2.*midpoint)-xin;
refldatamat=[x2(2:end) yin ein nin];
refldatamat=sortrows(refldatamat,1);%sort so that we get data in ascending order
%
x2=sort(x2); y2=refldatamat(:,2); e2=refldatamat(:,3); n2=refldatamat(:,4);
%

%Rebin both datasets on to a new set of coordinates that is to the right of
%the midpoint:
max1=max(xin); max2=max(x2);
if max1>=max2
    x_rebin=xin(xin>=midpoint);
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
xin_old=xin; x2_old=x2;%keep the old values for the following manipulations (and reference in debug)
xin(xin_old<midpoint)=[]; yin(xin_old(1:end-1)<midpoint)=[];
ein(xin_old(1:end-1)<midpoint)=[]; nin(xin_old(1:end-1)<midpoint)=[];
x2(x2_old<midpoint)=[]; y2(x2_old(1:end-1)<midpoint)=[];
e2(x2_old(1:end-1)<midpoint)=[]; n2(x2_old(1:end-1)<midpoint)=[];

%==
if ~isempty(xin) && ~isempty(yin) && ~isempty(ein) && ~isempty(nin)
    [stemp1,etemp1,ntemp1]=rebin_1d_general(xin,x_rebin,yin,ein,nin);
else
    stemp1=zeros(length(x_rebin)-1,1); etemp1=stemp1; ntemp1=stemp1;
end
if ~isempty(x2) && ~isempty(y2) && ~isempty(e2) && ~isempty(n2)
    [stemp2,etemp2,ntemp2]=rebin_1d_general(x2,x_rebin,y2,e2,n2);
else
    stemp2=zeros(length(x_rebin)-1,1); etemp2=stemp2; ntemp2=stemp2;
end

%
%Now combine the two rebinned datasets:
[xout,yout,eout,nout]=combine_1d(x_rebin,stemp1,etemp1,ntemp1,x_rebin,stemp2,etemp2,ntemp2,[]);



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
    error('Symmetrise error: logic flaw');
end