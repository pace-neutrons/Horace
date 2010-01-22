function [xout,yout,sout,eout,nout]=symmetrise_2d(xin,yin,sin,ein,nin,midpoint)
%
% Symmetrise 2d data about a line at constant x and or constant y.
% midpoint=[midpoint_x,midpoint_y]
% If you wish to symmetrise about 1 axis only, then the other element of
% midpoint must be set to be NaN
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
%
if isempty(midpoint)
    xout=xin; yout=yin; sout=sin; eout=ein; nout=nin;
    %i.e. no reflection, so return the inputs
    return;
end
%
if numel(midpoint)~=2 || ~isvector(midpoint)
    error('Symmetrise 2d error: "midpoint" argument must be a vector with 2 elements');
end
%
%==========================================================================

%The way to do the symmetrisation of the y-axis is to swap the x and y
%co-ordinates, and transpose the intensity etc matrices.
xtemp=xin; ytemp=yin; stemp=sin; etemp=ein; ntemp=nin;
if ~isnan(midpoint(1))
    [xtemp,ytemp,stemp,etemp,ntemp]=symmetrise_2d_1axis(xtemp,ytemp,stemp,...
        etemp,ntemp,midpoint(1));
end
%
if ~isnan(midpoint(2))
    [ytemp2,xtemp2,stemp2,etemp2,ntemp2]=symmetrise_2d_1axis(ytemp',xtemp',stemp',...
        etemp',ntemp',midpoint(2));
    xtemp=xtemp2'; ytemp=ytemp2'; stemp=stemp2'; etemp=etemp2'; ntemp=ntemp2';
end
%
xout=xtemp; yout=ytemp; sout=stemp; eout=etemp; nout=ntemp;












