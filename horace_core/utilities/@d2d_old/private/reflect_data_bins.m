function [xr,yr,sr,er,nr]=reflect_data_bins(xin,yin,sin,ein,nin,R,trans)
%
% use a reflection matrix and a translation vector to modify a co-ordinate
% set and corresponding signal, error, npix arrays. This function is a
% subroutine of the generic d2d symmetrisation routines.
%
%

%inputs xin,yin are 4xn arrays
%inputs sin,ein,nin are 1xn arrays

x1=xin(1,:); x2=xin(2,:); x3=xin(3,:); x4=xin(4,:);
y1=yin(1,:); y2=yin(2,:); y3=yin(3,:); y4=yin(4,:);

Rnew=R([1:2],[1:2]);%change reflection matrix from 3x3 to 2x2, since everything will
%remain in the data plane.

c1=[x1; y1]; c2=[x2; y2]; c3=[x3; y3]; c4=[x4; y4];

transnew=trans(1:2);
sz=size(c1);
transrep=repmat(transnew,1,sz(2));

c1t=c1-transrep; c2t=c2-transrep; c3t=c3-transrep; c4t=c4-transrep;

c1r=Rnew*c1t; c2r=Rnew*c2t; c3r=Rnew*c3t; c4r=Rnew*c4t;

c1new=c1r+transrep; c2new=c2r+transrep; c3new=c3r+transrep; c4new=c4r+transrep;

xr=[c1new(1,:); c2new(1,:); c3new(1,:); c4new(1,:)];
yr=[c1new(2,:); c2new(2,:); c3new(2,:); c4new(2,:)];

sr=sin; er=ein; nr=nin;