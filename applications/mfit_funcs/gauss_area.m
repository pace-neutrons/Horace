function [y, name, pnames, pin] = gauss_area(x, p, flag)
% Gaussian. Fits area and width (cf. gauss which fits height and width)
% 
%   >> y = gauss_area(x,p)
%   >> [y, name, pnames, pin] = gauss_area(x,p,flag)
%
% Input:
% =======
%   x   Vector of x-axis values at which to evaluate function
%   p   Vector of parameters needed by the function:
%           p = [area, centre, st_deviation]
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

% T.G.Perring

if nargin==2
    % Simply calculate function at input values
    y=(p(1)/(abs(p(3))*sqrt(2*pi)))*exp(-0.5*((x-p(2))/p(3)).^2);
else
    % Return parameter names or interactively prompt for parameter values
	y=[];
	name='Gaussian';
	pnames=str2mat('Area','Centre','Sigma');
	if flag==1
        pin=zeros(size(p));
    elseif flag==2
		mf_msg('Click on peak maximum');
		[centre,height]=ginput(1);
		mf_msg('Click on half-height');
		[width,dummy]=ginput(1);
		sigma=0.8493218*abs(width-centre);
        area=height*sigma*sqrt(2*pi);
		pin=[area,centre,sigma];
	end
end
