function lx (xlo, xhi)
% Change x limits current figure
%
%   >> lx (xlo, xhi)
% or
%   >> lx  xlo  xhi
%
%   >> lx    % set x limits to include all data
%

% Get figure
if isempty(findall(0,'Type','figure'))
    disp('No current figure - change x limits ignored')
    return
end

% Get x range
if nargin ==0
    % Get x axis limits for entire data range
    xrange = graph_range(gcf);

elseif nargin ==2
    % Read parameters from either function syntax or command syntax
    xrange=zeros(1,2);
    if isnumeric(xlo) && isscalar(xlo)
        xrange(1)=xlo;
    elseif ~isempty(xlo) && isstring(xlo)
        try
            xrange(1) = evalin('caller',xlo);
        catch
            error('Check input arguments');
        end
    else
        error('Check input arguments');
    end

    if isnumeric(xhi) && isscalar(xhi)
        xrange(2)=xhi;
    elseif ~isempty(xhi) && isstring(xhi)
        try
            xrange(2) = evalin('caller',xhi);
        catch
            error('Check input arguments');
        end
    else
        error('Check input arguments');
    end
    
    if xrange(1)>=xrange(2)
        error('Check xlo < xhi')
    end

else
    error 'Check number of input parameters'
end

% Change limits
set (gca, 'XLim', xrange);
