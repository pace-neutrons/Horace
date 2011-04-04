function ly (ylo, yhi)
% Change y limits current figure
%
%   >> ly (ylo, yhi)
% or
%   >> ly  ylo  yhi
%
%   >> ly    % set y limits to include all data
%

% Get figure
if isempty(findall(0,'Type','figure'))
    disp('No current figure - change y limits ignored')
    return
end

% Get y range
if nargin ==0
    % Get y axis limits for entire data range
    [xrange,yrange_dummy,yrange] = graph_range(gcf);

elseif nargin ==2
    % Read parameters from either function syntax or command syntax
    yrange=zeros(1,2);
    if isnumeric(ylo) && isscalar(ylo)
        yrange(1)=ylo;
    elseif ~isempty(ylo) && isstring(ylo)
        try
            yrange(1) = evalin('caller',ylo);
        catch
            error('Check input arguments');
        end
    else
        error('Check input arguments');
    end

    if isnumeric(yhi) && isscalar(yhi)
        yrange(2)=yhi;
    elseif ~isempty(yhi) && isstring(yhi)
        try
            yrange(2) = evalin('caller',yhi);
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
if yrange(1)>=yrange(2)
    error('Check ylo < yhi')
end
set (gca, 'YLim', yrange);
