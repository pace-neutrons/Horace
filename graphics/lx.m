function varargout = lx (varargin)
% Change x limits current figure
%
% Replot with change of limits:
%   >> lx (xlo, xhi)
% or
%   >> lx  xlo  xhi
% or
%   >> lx       % set x limits to include all data
%
% Return current limits (without changing range):
%   >> [xlo, xhi] = lx
%
% Replot with several limits in sequence (hit <CR> to move to next in sequence)
%   >> lx ([xlo1,xhi2],[xlo2,xhi2],...)
% or
%   >> lx ({[xlo1,xhi2],[xlo2,xhi2],...})


% Get figure
if isempty(findall(0,'Type','figure'))
    disp('No current figure - change x limits ignored')
    return
end

% Get x range
if nargin==0
    if nargout==0
        % Get x axis limits for entire data range
        range = graph_range(gcf,'evaluate');
        xrange=range.x;
        
        if xrange(1)==xrange(2)
            error('The upper and lower limits of the data are equal')
        end
        xrange={xrange};
    else
        % Return current x-axis limits
        range = get(gca,'Xlim');
        if nargout>=1, varargout{1} = range(1); end
        if nargout>=2, varargout{2} = range(2); end
        return
    end
    
elseif nargin==2 && (~isnumeric(varargin{1})||numel(varargin{1})==1) && (~isnumeric(varargin{2})||numel(varargin{2})==1)
    % Read scalar xlo and xhi from either function syntax or command syntax
    xlo=varargin{1};
    xhi=varargin{2};
    
    xrange=zeros(1,2);
    if isnumeric(xlo) && isscalar(xlo)
        xrange(1)=xlo;
    elseif ~isempty(xlo) && is_string(xlo)
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
    elseif ~isempty(xhi) && is_string(xhi)
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
    
    xrange={xrange};
    
elseif nargin==1 && iscell(varargin{1})
    % Must be cell array of pairs of limits
    nlim=numel(varargin{1});
    for i=1:nlim
        if ~isnumeric(varargin{1}{i})||numel(varargin{1}{i})~=2
            error('Check x-limits are a cell array of two-element numeric vectors')
        elseif varargin{1}{i}(1)>=varargin{1}{i}(2)
            error('Check xlo < xhi  for all pairs of limits')
        end
    end
    xrange=varargin{1};
    
else
    % One or more two element numeric vectors
    for i=1:nargin
        if ~isnumeric(varargin{i})||numel(varargin{i})~=2
            error('Check syntax of x-limits')
        elseif varargin{i}(1)>=varargin{i}(2)
            error('Check xlo < xhi  for all pairs of limits')
        end
    end
    xrange=varargin;
    
end

% Change limits
for i=1:numel(xrange)
    set (gca, 'Xlim', xrange{i})
    if i~=numel(xrange), input('hit <CR> to continue'), end
end
