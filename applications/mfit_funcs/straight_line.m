function [y, name, pnames, pin] = straight_line(x, p, flag)
% Straight line
% 
%   >> y = straight_line(x,p)
%   >> [y, name, pnames, pin] = straight_line (x,p,flag)
%
% Input:
% =======
%   x   Vector of x-axis values at which to evaluate function
%   p   Vector of parameters needed by the function
%           y = p(1) + p(2)*x
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
    y=p(1)+p(2)*x;
else
	y=[];
	name='Straight line';
	pnames=str2mat('Intercept','slope');
	if flag==1
        pin=zeros(size(p));
    elseif flag==2
		mf_msg('Click on line');
		[x1,y1]=ginput(1);
		mf_msg('Click on another point');
		[x2,y2]=ginput(1);
        const=(x2*y1-x1*y2)/(x2-x1);
        slope=(y2-y1)/(x2-x1);
        if isnan(const)||isnan(slope); const=0; slope=0; end;
		pin=[const,slope];
	end
end
