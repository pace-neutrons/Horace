function [y, name, pnames, pin] = soft_hat(x, p, flag)
% Hat function broadened by Gaussians (different at each end) and with an overall slope.
% 
%   >> y = soft_hat(x,p)
%   >> [y, name, pnames, pin] = soft_hat(x,p,flag)
%
% Input:
% =======
%   x   Vector of x-axis values at which to evaluate function
%   p   Vector of parameters needed by the function
%           p(1)    Height of hat function at half way point
%           p(2)    Gradient of hat function
%           p(3)    Start of Hat function
%           p(4)    Finish of hat function
%           p(5)    FWHH of Gaussian convoluting the start of hat
%           p(6)    FWHH of Gaussian convoluting the finish of hat
%
% Optional:
%   flag    Alternative behaviour to follow other than function evaluation [optional]:
%           flag=1  (identify) returns just the function name and parameters
%           flag=2  (interactive guess) returns starting values for parameters
%
% Output:
% ========
%   y       Vector of calculated y-axis values
%
% if flag=1 or 2:
%   y       =[]
%   name    Name of function (used in mfit and possibly other fitting routines)
%   pnames  Parameter names
%   pin     iflag=1: = [];
%           iflag=1: = values of the parameters returned from interactive prompting

% T.G.Perring

if nargin==2
    sig2fwhh=sqrt(8*log(2));
    rt2=sqrt(2);
    height=p(1); grad=p(2); x1=p(3); x2=p(4); sig1=abs(p(5))/sig2fwhh; sig2=abs(p(6))/sig2fwhh;
    % linearly interpolate sig for x1<x<x2
    sig = ((x2-x)*sig1-(x1-x)*sig2)/(x2-x1);    
    sig(x<x1)=sig1;
    sig(x>x2)=sig2;
    % calculate blurred hat function with gradient
    e1=(x1-x)./(rt2*sig);
    e2=(x2-x)./(rt2*sig);
    y=(erf(e2)-erf(e1)).*((height+grad*(x-(x2+x1)/2))/2);
else
	y=[];
	name='psd_calib';
	pnames=str2mat('Hat height','Hat gradient','Hat start','Hat end','Start FWHH','End FWHH');
	if flag==1
        pin=[];
    elseif flag==2
		mf_msg('Hat start - full height');
		[x1,h1]=ginput(1);
		mf_msg('Hat start - half height');
		[hat_start,dummy]=ginput(1);
		mf_msg('Hat start - quarter height');
		[start_fwhh,dummy]=ginput(1);
        start_fwhh=abs(start_fwhh-hat_start)/0.28642942;
		mf_msg('Hat end - full height');
		[x2,h2]=ginput(1);
		mf_msg('Hat end - half height');
		[hat_end,dummy]=ginput(1);
		mf_msg('Hat end - quarter height');
		[end_fwhh,dummy]=ginput(1);
        end_fwhh=abs(end_fwhh-hat_end)/0.28642942;
        hat_height=(h1+h2)/2;
        grad=(h2-h1)/(x2-x1);
        if isnan(grad); grad=0; end;        
		pin=[hat_height,grad,hat_start,hat_end,start_fwhh,end_fwhh];
	end
end
