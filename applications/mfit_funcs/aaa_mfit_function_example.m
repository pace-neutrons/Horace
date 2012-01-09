function [y, name, pnames, pin] = aaa_mfit_function_example(x, p, flag)
% Example of function for mfit and other fitting programs. Use as template
% for construction of other functions.
%
% Gaussian on linear background
% 
%   >> y = aaa_mfit_function_example(x,p)
%   >> [y, name, pnames, pin] = aaa_mfit_function_example(x,p,flag)
%
% Input:
% =======
%   x   vector of x-axis values at which to evaluate function
%   p   vector or parameters needed by the function e.g. centre, half-width etc.
%       In this case:
%           p = [height, centre, st_deviation, bkgd_const, bkgd_slope]
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
%
% Note:
% =====
%  The minimal implementation is to return the y values for a set of x-values and parameters
%  This will still work with mfit, although the interactive prompting of mfit and other
%  fitting programs will not work.
%
%  In the present case, the minimal implementation is:
%
%       function y = aaa_example(x,p)
%       y=p(1)*exp(-0.5*((x-p(2))/p(3)).^2) + (p(4)+x*p(5));

if nargin==2
    % Simply calculate function at input values
    y=p(1)*exp(-0.5*((x-p(2))/p(3)).^2) + (p(4)+x*p(5));
else
    % Return parameter names or interactively prompt for parameter values
	y=[];
	name='Gaussian';
	pnames=str2mat('Height','Centre','Sigma','Constant','Slope');
	if flag==1
        pin=[];
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
		pin=[height-(const+slope*centre),centre,sigma,const,slope];
	end
end
