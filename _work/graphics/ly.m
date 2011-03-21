function [] = ly (ylo, yhi)
%LY Change limits of existing plot
%
%   >> ly (ylo, yhi)
%or
%   >> ly  ylo  yhi
%
%   >> ly    % set y limits to include all data
%

if nargin ==0
% set y axis limits to maximum required to plot entire data range
    [xlo, xhi, ymin, ymax, ylo_temp, yhi_temp] = graph_range;

elseif nargin ==2
% read parameters from either function syntax or command syntax
    try
        ylo_temp = evalin('caller',ylo);
    catch
        ylo_temp = ylo;
    end
    try
        yhi_temp = evalin('caller',yhi);
    catch
        yhi_temp = yhi;
    end

    % check input parameters are numbers
    if (~isnumeric(ylo_temp) | ~isnumeric(yhi_temp))
        error ('Check input arguments (ly)')
    end
    
else
    error 'Check number of input parameters (ly)'
end

set (gca, 'YLim', [ylo_temp yhi_temp])