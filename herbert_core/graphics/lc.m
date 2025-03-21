function lc (clo, chi)
% Change intensity limits on current figure if it is a surface or contour plot
%
%   >> lc (clo, chi)
% or
%   >> lc  clo  chi
%
%   >> lc    % set intensity limits to include all data


% Get figure
if isempty(findall(0,'Type','figure'))
    disp('No current figure - change intensity limits ignored')
    return
end

% Find out if there is c data
present = graph_range (gcf,'present');
if ~present.c
    error('No c range to change')
end

% Get intensity range
if nargin==0 || (nargin==1 && ischar(clo))
    % Get intensity axis limits for entire data range
    [range,subrange] = graph_range(gcf,'evaluate');
    crange=range.c;
    
    if crange(1)==crange(2)
        error('The upper and lower limits of the data are equal')
    end
    
    % Read 'round' from either function syntax or command syntax
    if nargin==1
        if strcmpi(clo,'round')
            crange = round_range (crange);
        else
            error('Unrecognised option')
        end
    end
    
elseif nargin==2
    % Read parameters from either function syntax or command syntax
    crange=zeros(1,2);
    if isnumeric(clo) && isscalar(clo)
        crange(1)=clo;
    elseif ~isempty(clo) && is_string(clo)
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
    elseif ~isempty(chi) && is_string(chi)
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
colorslider('update')   % update colorslider, if present
