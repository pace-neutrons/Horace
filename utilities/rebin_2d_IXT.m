function [xout,yout,sout,eout]=rebin_2d_IXT(xin,yin,sin,ein,xout,yout)
%
% Function to use the IXTdataset2d rebinning method. Ostensibly for speed
% comparison and consistency check with RAE's Matlab code.
%

%Note that input options for xout and yout as far as the IXT method are
%concerned are [lo,step,hi].
x_option=[min(xout),xout(2)-xout(1),max(xout)];
y_option=[min(yout),yout(2)-yout(1),max(yout)];

data_in=IXTdataset_2d(xin,yin,sin,ein);
data_out= rebin_xy(data_in,x_option,y_option);

getit=get(data_out);
xout=getit.x; yout=getit.y;
sout=getit.signal; eout=getit.error;