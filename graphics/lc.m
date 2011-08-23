function lc (clo, chi)
% Change intensity limits on current figure if it is  a surface and contour plot
%
%   >> lc (clo, chi)
% or
%   >> lc  clo  chi
%
%   >> lc    % set intensity limits to include all data
%

% Get figure
if isempty(findall(0,'Type','figure'))
    disp('No current figure - change intensity limits ignored')
    return
end

% Get intensity range
if nargin ==0
    % Get intensity axis limits for entire data range
    [xrange,yrange,ysubrange,zrange,zsubrange,crange] = graph_range(gcf);

elseif nargin ==2
    % Read parameters from either function syntax or command syntax
    crange=zeros(1,2);
    if isnumeric(clo) && isscalar(clo)
        crange(1)=clo;
    elseif ~isempty(clo) && isstring(clo)
        try
            crange(1) = evalin('caller',clo);
        catch
            error('Check input arguments');
        end
    else
        error('Check input arguments');
    end

    if isnumeric(chi) && isscalar(chi)
        crange(2)=chi;
    elseif ~isempty(chi) && isstring(chi)
        try
            crange(2) = evalin('caller',chi);
        catch
            error('Check input arguments');
        end
    else
        error('Check input arguments');
    end
    
    if crange(1)>=crange(2)
        error('Check clo < chi')
    end

else
    error 'Check number of input parameters'
end

% Change limits
set (gca, 'CLim', crange);

% Update colorslider, if present
colorslider('update')
