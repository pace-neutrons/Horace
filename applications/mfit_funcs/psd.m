function [y, name, pnames, pin] = psd(x, p, flag)
% Hat function convoluted with Gaussians at ends,with quadratic top and
% Gaussian notches
% 
%   >> y = psd(x,p)
%   >> [y, name, pnames, pin] = psd(x,p,flag)
%
% Input:
% =======
%   x   vector of x-axis values at which to evaluate function
%   p   vector or parameters needed by the function
%           p(1)    Height of hat function at half way point
%           p(2)    Gradient of hat function
%           p(3)    Quadratic coefficient
%           p(4)    Start of Hat function
%           p(5)    Finish of hat function
%           p(6)    FWHH of Gaussian convoluting the start of hat
%           p(7)    FWHH of Gaussian convoluting the finish of hat
%           p(3n+4) Height of nth notch
%           p(3n+5) Position of nth notch
%           p(3n+6) FWHH of nth notch
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


if nargin==2
    sig2fwhh=sqrt(8*log(2));
    rt2=sqrt(2);
    gauconst=4*log(2);
    height=p(1); grad=p(2); quad=p(3); x1=p(4); x2=p(5); sig1=abs(p(6))/sig2fwhh; sig2=abs(p(7))/sig2fwhh;
    % linearly interpolate sig for x1<x<x2
    sig = ((x2-x)*sig1-(x1-x)*sig2)/(x2-x1);    
    sig(x<x1)=sig1;
    sig(x>x2)=sig2;
    % calculate blurred hat function with gradient
    e1=(x1-x)./(rt2*sig);
    e2=(x2-x)./(rt2*sig);
    y=(erf(e2)-erf(e1)).*((height+grad*(x-(x2+x1)/2)+quad*(x-(x2+x1)/2).^2)/2);
    % Compute number of Gaussians and subtract from hat function
    ngauss = floor((length(p)-6)/3);
    if 3*ngauss+7~=length(p); error('Check number of parameters'); end
    if ngauss>0
        pgauss=reshape(p(8:end),[3,ngauss]);
        ht=pgauss(1,:); cent=pgauss(2,:); fwhh=pgauss(3,:);
        for i=1:ngauss
            y = y - abs(ht(i))*exp(-gauconst*((x-cent(i))/fwhh(i)).^2);
        end
    end
else
	y=[];
	name='psd_calib';
    % Compute number of Gaussians
    ngauss = floor((length(p)-7)/3);
    pnames=str2mat('Hat height','Hat gradient','Hat quadratic','Hat start','Hat end','Start FWHH','End FWHH');
    if 3*ngauss+7~=length(p); error('Check number of parameters'); end
    if ngauss>0
        for i=1:ngauss
            ic=num2str(i);
            str=str2mat(['Gauss ',ic,' height'],['Gauss ',ic,' centre'],['Gauss ',ic,' FWHH']);
            pnames=char(pnames,str);
        end
    end
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
		pin=[hat_height,grad,0,hat_start,hat_end,start_fwhh,end_fwhh];
	end
end
