function [y, name, pnames, pin] = expon_bkgd(x, p, flag)
% Exponential function on a linear background
% 
%   >> y = expon(x,p)
%   >> [y, name, pnames, pin] = expon(x,p,flag)
%
% Input:
% =======
%   x   Vector of x-axis values at which to evaluate function
%   p   Vector of parmaeters: defines y = p(1)*exp(-x/p(2))
%           p = [height_at_x=0, decay, bkgd_const, bkgd_slope]
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
%           iflag=2: = values of the parameters returned from interactive prompting
%

if nargin==2
    % Simply calculate function at input values
    y=p(1)*exp(-x/p(2)) + (p(3)+x*p(4));
else
    % Return parameter names or interactively prompt for parameter values
	y=[];
	name='Exponential';
	pnames=str2mat('Height','Decay','Constant','Slope');
	if flag==1
        pin=[];
    elseif flag==2
		mf_msg('Click on one point');
		[x1,y1]=ginput(1);
		mf_msg('Click on 2nd point');
		[x2,y2]=ginput(1);
		mf_msg('Click on left background');
		[xb1,yb1]=ginput(1);
		mf_msg('Click on right background');
		[xb2,yb2]=ginput(1);
        const=(xb2*yb1-xb1*yb2)/(xb2-xb1);
        slope=(yb2-yb1)/(xb2-xb1);
        if isnan(const)||isnan(slope); const=0; slope=0; end;
        y1=y1-(const+slope*x1);
        y2=y2-(const+slope*x2);
        tau = (x2-x1)/log(y1/y2);
        ht  = y1*exp(x1/tau);
		pin=[ht,tau,const,slope];
	end
end
