function [] = lx (xlo, xhi)
%LX Change limits of existing plot
%
%   >> lx (xlo, xhi)
%or
%   >> lx  xlo  xhi
%
%   >> lx    % set y limits to include all data
%

if nargin ==0
% set x axis limits to maximum required to plot entire data range
    [xlo_temp, xhi_temp, ylo, yhi, ymin, ymax] = graph_range;

elseif nargin ==2
% read parameters from either function syntax or command syntax
    try
        xlo_temp = evalin('caller',xlo);
    catch
        xlo_temp = xlo;
    end
    try
        xhi_temp = evalin('caller',xhi);
    catch
        xhi_temp = xhi;
    end

    % check input parameters are numbers
    if (~isnumeric(xlo_temp) | ~isnumeric(xhi_temp))
        error 'Check input arguments (lx)'
    end
    
else
    error 'Check number of input parameters (lx)'
end

set (gca, 'XLim', [xlo_temp xhi_temp]);

