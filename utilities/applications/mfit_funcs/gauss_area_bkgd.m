function [y, name, pnames, pin] = gauss_area_bkgd(x, p, flag)
% Gaussian on linear background. Fits area and width (cf. gauss_bkd: height and width)
% 
%   >> y = gauss_bkgd(x,p)
%   >> [y, name, pnames, pin] = gauss_bkgd(x,p,flag)
%
% Input:
% =======
%   x   vector of x-axis values at which to evaluate function
%   p   vector or parameters needed by the function:
%           p = [area, centre, st_deviation, bkgd_const, bkgd_slope]
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
    % Simply calculate function at input values
    y=(abs(p(1))/(p(3)*sqrt(2*pi)))*exp(-0.5*((x-p(2))/p(3)).^2) + (p(4)+x*p(5));
else
    % Return parameter names or interactively prompt for parameter values
	y=[];
	name='Gaussian';
	pnames=str2mat('Area','Centre','Sigma','Constant','Slope');
	if flag==1
        pin=zeros(size(p));
    elseif flag==2
		mf_msg('Click on peak maximum');
		[centre,height]=ginput(1);
		mf_msg('Click on half-height');
		[width,dummy]=ginput(1);
		sigma=0.8493218*abs(width-centre);
		mf_msg('Click on left background');
		[x1,y1]=ginput(1);
		mf_msg('Click on right background');
		[x2,y2]=ginput(1);
        const=(x2*y1-x1*y2)/(x2-x1);
        slope=(y2-y1)/(x2-x1);
        if isnan(const)||isnan(slope); const=0; slope=0; end;
        height=height-(const+slope*centre);
        area=height*sigma*sqrt(2*pi);
		pin=[area,centre,sigma,const,slope];
	end
end
