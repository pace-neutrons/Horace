function [xnew,ynew,sout,eout,nout]=rebin_2d(xin,yin,sin,ein,nin,xout,yout)
%
% Generic 2d rebinning function.
%
% Rebins a 2-dimensional dataset along both the x- and y-axes, provided the
% direction of these axes are the same for the input and output bins.
%
% Inputs:   xin - matrix of x coordinates (bin boundaries) for original data
%           yin - matrix of y coordinates (bin boundaries) for original data
%           xout - vector of x coordinates (bin boundaries) for output
%           (empty if no rebinning to be performed along x-axis)
%           yout - vector of y coordinates (bin boundaries) for output
%           (empty if no rebinning to be performed along y-axis)
%           sin - signal array of original data (has 1 fewer rows and columns than xin and yin)
%           ein - error array of original data
%           nin - npix array of original data
%
% Outputs:  xnew - matrix of output x coordinates (bin boundaries, ndgrid format) 
%           ynew - matrix of output y coordinates (bin boundaries, ndgrid format)
%           sout - signal array of output (has 1 fewer rows than xout and 1 fewer columns than yout)
%           eout - error array of output
%           nout - npix array of output
%
% Note that by "error" we mean variance (or error^2)
%
% R.A.E. 14/9/09
%

if isempty(xout) && isempty(yout)
    %return unchanged arrays
    xnew=xin; ynew=yin; sout=sin; eout=ein; nout=nin;
elseif ~isempty(xout) && ~isempty(yout)
    [xnew1,ynew1,sout1,eout1,nout1]=rebin_2d_1axis(xin,yin,xout,sin,ein,nin);
    %use same function to do the y-axis by "rotating" by 90 degrees:
    [ynew2,xnew2,sout2,eout2,nout2]=rebin_2d_1axis(ynew1',xnew1',yout,sout1',eout1',nout1');
    xnew=xnew2'; ynew=ynew2'; sout=sout2'; eout=eout2'; nout=nout2';
elseif isempty(yout) && ~isempty(xout)
    [xnew,ynew,sout,eout,nout]=rebin_2d_1axis(xin,yin,xout,sin,ein,nin);
else
    [ynew1,xnew1,sout1,eout1,nout1]=rebin_2d_1axis(yin',xin',yout,sin',ein',nin');
    xnew=xnew1'; ynew=ynew1'; sout=sout1'; eout=eout1'; nout=nout1';
end
