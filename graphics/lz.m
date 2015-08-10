function lz (zlo, zhi)
% Change z limits current figure
%
%   >> lz (zlo, zhi)
% or
%   >> lz  zlo  zhi
%
%   >> lz    % set z limits to include all data


% Get figure
if isempty(findall(0,'Type','figure'))
    disp('No current figure - change z limits ignored')
    return
end

% Find out if there is z data
present = graph_range (gcf,'present');
if ~(present.z || present.c)
    error('No z range to change')
end

% Get z range
if nargin==0
    % Get z axis limits in the current limits of x and y (or full range if c data)
    [range,subrange] = graph_range(gcf,'evaluate');
    if present.z
        zrange=subrange.z;
    else
        zrange=range.c;
    end
    
    if zrange(1)==zrange(2)
        error('The upper and lower limits of the data are equal')
    end
    
elseif nargin==2
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
    
    if zrange(1)>=zrange(2)
        error('Check zlo < zhi')
    end
    
else
    error 'Check number of input parameters'
end

% Change limits
if present.z
    set (gca, 'ZLim', zrange);
else
    set (gca, 'CLim', zrange);  % assume that crange is axis to be changed
    colorslider('update')       % update colorslider, if present
end
