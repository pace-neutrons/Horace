function [] = lz (zlo, zhi)
%LZ Change limits of existing plot
%
%   >> lz (zlo, zhi)
%or
%   >> lz  zlo  zhi
%

if nargin ==0
% set x axis limits to maximum required to plot entire data range
    [xlo, xhi, ylo, yhi, ymin, ymax, zlo_temp, zhi_temp] = graph_range;
    if zlo_temp > zhi_temp
        error 'Change of z limits inapplicable on this graph'
    end

elseif nargin ==2
% read parameters from either function syntax or command syntax
    try
        zlo_temp = evalin('caller',zlo);
    catch
        zlo_temp = zlo;
    end
    try
        zhi_temp = evalin('caller',zhi);
    catch
        zhi_temp = zhi;
    end

    % check input parameters are numbers
    if (~isnumeric(zlo_temp) | ~isnumeric(zhi_temp))
        error 'Check input arguments (lz)'
    end
    
else
    error 'Check number of input parameters (lz)'
end

set (gca, 'CLim', [zlo_temp zhi_temp]);
colorbar

