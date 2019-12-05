function resolution_plot_private (x0,C,iax,flip)
% Plot resolution function on 2D axes
%
%   >> resolution_plot_private (x0,C,iax,flip,fig,newplot)
%
% Input:
% ------
%   x0      Origin of resolution function, [x1,x2] for axes iax(1) and iax(2)
%
%   C       Covariance matrix (4x4) in qx,qy,qz,en (units can be Angstrom^-1
%          or whatever the projection axes units are)
%
%   iax     Indicies of axes to plot (all unique, in range 1 to 4)
%           If length 2, these give the axes of the plot plane into C
%           If length 3, then the third axis is one for which an
%          ellipse section is drawn at a positive value along that axis
%
%   flip    If true, flip the plot axes; if false, not
%           For plotting if display axes are reversed from plot axes.


% Original author: T.G.Perring
%
% $Revision:: 1757 ($Date:: 2019-12-05 14:56:06 +0000 (Thu, 5 Dec 2019) $)


% Check input arguments
if ~(isnumeric(x0) && numel(x0)==2 && all(isfinite(x0)))
    error('Centre must be a numeric vector length 2')
end

if ~(isnumeric(C) && isequal(size(C),[4,4]))
    error('Covariance matrix has wrong size')
end

if ~(isnumeric(iax) && (numel(iax)==2 || numel(iax)==3) &&...
        numel(unique(iax))==numel(iax) && all(iax>=1) && all(iax)<=4)
    error('Check axes indicies')
end

% Plot parameters
frac = 0.5;     % fraction of maximum at which to draw contours

val = 2*log(1/frac);

% Get envelope and intersection(s)
% - Envelope
C2 = C(iax(1:2),iax(1:2));    % pick out the covariance elements for the plot axes
[x1e,x2e] = ellipse (C2(1,1), C2(1,2), C2(2,2), val);  % envelope

% - Intersection with x1-x2 plane for x3=0 and x3>0
if numel(iax)==3
    C3 = C(iax,iax);
    m = inv(C3);
    c = inv(m(1:2,1:2));
    % Intersection with x3=0
    [x1c_0,x2c_0] = ellipse (c(1,1), c(1,2), c(2,2), val);
    % Intersection with x3>0
    x3max = sqrt(val*C3(3,3));   % maximum value of x3
    x3 = round_mantissa(0.667*x3max);
    dx1 = x3*C3(1,3)/C3(3,3);
    dx2 = x3*C3(2,3)/C3(3,3);
    [x1c_pos,x2c_pos] = ellipse (c(1,1), c(1,2), c(2,2), val-x3^2/C3(3,3));
end

% Perform plot
% ------------
hold on

lwidth = aline;
lcol = acolor;
if iscell(lcol), lcol=lcol{1}; end    % may have more than one color set
if ~flip
    plot(x1e+x0(1),x2e+x0(2),'Color',lcol,'LineStyle','-','LineWidth',lwidth);
    hold on
    if numel(iax)==3
        plot(x1c_0+x0(1),x2c_0+x0(2),'Color',lcol,'LineStyle','--','LineWidth',lwidth);
        plot(x1c_pos+x0(1)+dx1,x2c_pos+x0(2)+dx2,'Color',lcol,'LineStyle','--','LineWidth',lwidth);
    end
else
    plot(x2e+x0(2),x1e+x0(1),'Color',lcol,'LineStyle','-','LineWidth',lwidth);
    hold on
    if numel(iax)==3
        plot(x2c_0+x0(2),x1c_0+x0(1),'Color',lcol,'LineStyle','--','LineWidth',lwidth);
        plot(x2c_pos+x0(2)+dx2,x1c_pos+x0(1)+dx1,'Color',lcol,'LineStyle','--','LineWidth',lwidth);
    end
end

hold off


%========================================================================================
function r=round_mantissa(x)
% Round a positive number to the nearest number with form n*10^m where n, m are integer
xlog = log10(x);
r = round(10^mod(xlog,1))*10^floor(xlog);


%========================================================================================
function [x1,x2] = ellipse (c11,c12,c22,A)
% Get a set of points that lie on the ellipse
%   [x1 x2]*Inv([c11 c12; c12 c22])*[x1; x2] = A  (A>0)

npnt = 500;     % number of points on the ellipse

% Get the orientation of the ellipsoid: angle theta to a minor axis x1'
theta = 0.5*atan2(-2*c12, c22-c11);
c = cos(theta);
s = sin(theta);

% Get the lengths of the principal axes along x1', x2'
cc = sqrt((c22-c11)^2+4*c12^2);
c1 = sqrt(A*((c22+c11)-cc)/2);
c2 = sqrt(A*((c22+c11)+cc)/2);

% Coordinate of points in x1',x2'
ang=linspace(0,2*pi,npnt);
x1prime = c1*cos(ang);
x2prime = c2*sin(ang);

% Transform to input coordinate frame
x1 = c*x1prime - s*x2prime;
x2 = s*x1prime + c*x2prime;

