function resolution_plot_private (x0,C,iax,flip,fig,newplot)
% Plot resolution function on 2D axes
%
%   >> resolution_plot_private (x0,C,iax,flip,fig,newplot)
%
% Input:
% ------
%   x0      Origin of resolution function, [x1,x2]
%
%   C       Covariance matrix (4x4) in qx,qy,qz,en
%
%   iax     Indicies of axes to plot (all unique, in range 1 to 4)
%           If length 2, these give the axes of the plot plane into C
%           If length 3, then the third axis is one for which an
%          ellipse section is drawn at a positive value along that axis
%
%   flip    If true, flip the plot axes; if false, not
%           For plotting if display axes are reversed from plot axes.
%
%   fig     Figure name or number on which to plot or overplot
%
%   newplot If true, create new plot; If false overplot


% Original author: T.G.Perring
%
% $Revision: 1524 $ ($Date: 2017-09-27 15:48:11 +0100 (Wed, 27 Sep 2017) $)


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
Cplane = C(iax(1:2),iax(1:2));    % pick out the covariance elements for the plot axes
m = inv(Cplane);
[x1e,x2e] = ellipse (m(1,1), m(1,2), m(2,2), val);  % envelope

% - Intersection with x1-x2 plane for x3=0
M = inv(C);
m = M(iax(1:2),iax(1:2));
[x1c,x2c] = ellipse (m(1,1), m(1,2), m(2,2), val);  % intersection with the plane

% - Intersection with x1-x2 plane for x3>0
if numel(iax)==3
    x3max = sqrt(val*C(iax(3),iax(3)));
    x3 = round_mantissa(0.667*x3max);
    % Offset of ellipse centre
    m = M(iax,iax);
    dx1 = x3 * (-m(2,2)*m(1,3)+m(1,2)*m(2,3)) / (m(1,1)*m(2,2)-m(1,2)*m(1,2));
    dx2 = x3 * (-m(1,1)*m(2,3)+m(1,2)*m(1,3)) / (m(1,1)*m(2,2)-m(1,2)*m(1,2));
    E = m(1,1)*dx1^2 + 2*m(1,2)*dx1*dx2 + m(2,2)*dx2^2 ...
        + 2*m(1,3)*dx1*x3 + 2*m(2,3)*dx2*x3 + m(3,3)*x3^2;
    [x1ch,x2ch] = ellipse (m(1,1), m(1,2), m(2,2), val-E);    % intersection with the plane at x3
end

% Perform plot
% ------------
default_fig_name = 'Resolution function';
[fig_out,ok,mess]=genie_figure_target(fig,newplot,default_fig_name);
if ~ok, error(mess), end

% Create new graphics window if required
if is_string(fig_out)
    new_figure = genie_figure_create (fig_out);
    if new_figure
        newplot=true;   % if had to create a new figure window
    end
else
    figure(fig_out); % overplotting on existing plot; make the current figure
end

% If newplot, delete any axes
if newplot
    delete(gca)     % not necessary if new_figure, but doesn't do any harm
else
    hold on;        % hold plot for overplotting
end

% Get genie line and colour characteristics, and plot
lwidth = aline;
lcol = acolor;
if ~flip
    plot(x1e+x0(1),x2e+x0(2),'Color',lcol,'LineStyle','-','LineWidth',lwidth);
    hold on
    plot(x1c+x0(1),x2c+x0(2),'Color',lcol,'LineStyle','--','LineWidth',lwidth);
    if numel(iax)==3
        plot(x1ch+x0(1)+dx1,x2ch+x0(2)+dx2,'Color',lcol,'LineStyle','--','LineWidth',lwidth);
    end
else
    plot(x2e+x0(2),x1e+x0(1),'Color',lcol,'LineStyle','-','LineWidth',lwidth);
    hold on
    plot(x2c+x0(2),x1c+x0(1),'Color',lcol,'LineStyle','--','LineWidth',lwidth);
    if numel(iax)==3
        plot(x2ch+x0(2)+dx2,x1ch+x0(1)+dx1,'Color',lcol,'LineStyle','--','LineWidth',lwidth);
    end
end

hold off

%========================================================================================
function r=round_mantissa(x)
% Round a positive number to the nearest number with form n*10^m where n, m are integer
xlog = log10(x);
r = round(10^mod(xlog,1))*10^floor(xlog);


%========================================================================================
function [x1,x2] = ellipse (m11,m12,m22,A)
% Get a set of points that lie on the ellipse m11*x1^2 + 2*m12*x1*x2 + m22*x2^2 = A

npnt = 500;     % number of points on the ellipse

% Get the orientation of the ellipsoid: angle theta to a principal axis x1'
theta = 0.5*atan2(2*m12, m11-m22);
c = cos(theta);
s = sin(theta);

% Get the lengths of the principal axes along x1', x2'
a1 = sqrt(A/(m11*c^2 + 2*m12*c*s + m22*s^2));
a2 = sqrt(A/(m11*s^2 - 2*m12*c*s + m22*c^2));

% Coordinate of points in x1',x2'
ang=linspace(0,2*pi,npnt);
x1prime = a1*cos(ang);
x2prime = a2*sin(ang);

% Transform to input coordinate frame
x1 = c*x1prime - s*x2prime;
x2 = s*x1prime + c*x2prime;
