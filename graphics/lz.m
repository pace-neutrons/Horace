function lz (zlo, zhi)
% Change z limits current figure
%
%   >> lz (zlo, zhi)
% or
%   >> lz  zlo  zhi
%
%   >> lz    % set z limits to include all data
%

% Get figure
if isempty(findall(0,'Type','figure'))
    disp('No current figure - change z limits ignored')
    return
end

% Get z range
if nargin ==0
    % Get z axis limits for entire data range
    [xrange,yrange,ysubrange,zrange_dummy,zrange] = graph_range(gcf);

elseif nargin ==2
    % Read parameters from either function syntax or command syntax
    zrange=zeros(1,2);
    if isnumeric(zlo) && isscalar(zlo)
        zrange(1)=zlo;
    elseif ~isempty(zlo) && isstring(zlo)
        try
            zrange(1) = evalin('caller',zlo);
        catch
            error('Check input arguments');
        end
    else
        error('Check input arguments');
    end

    if isnumeric(zhi) && isscalar(zhi)
        zrange(2)=zhi;
    elseif ~isempty(zhi) && isstring(zhi)
        try
            zrange(2) = evalin('caller',zhi);
        catch
            error('Check input arguments');
        end
    else
        error('Check input arguments');
    end
    
else
    error 'Check number of input parameters'
end

% Change limits
set (gca, 'ZLim', zrange);
