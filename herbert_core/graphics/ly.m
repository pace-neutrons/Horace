function varargout = ly (varargin)
% Change y limits current figure
%
% Replot with change of limits:
%   >> ly (ylo, yhi)
% or
%   >> ly  ylo  yhi
% or
%   >> ly           % set y limits to include all data
% or
%   >> ly ('round') % set y limits to rounded limits that encompass data
%   >> ly  round 
%
% Return current limits (without changing range):
%   >> [ylo, yhi] = ly
%
% Replot with several limits in sequence (hit <CR> to move to next in sequence)
%   >> ly ([ylo1,yhi2],[ylo2,yhi2],...)
% or
%   >> ly ({[ylo1,yhi2],[ylo2,yhi2],...})


% Get figure
if isempty(findall(0,'Type','figure'))
    disp('No current figure - change y limits ignored')
    return
end

% Get y range
if nargin==0  || (nargin==1 && ischar(varargin{1}))
    if nargout==0
        % Get y axis limits in the current range of y:
        [~, subrange] = graph_range(gcf,'evaluate');
        
        yrange=subrange.y;
        if yrange(1)==yrange(2)
            error('The upper and lower limits of the data are equal')
        end
        
        % Read 'round' from either function syntax or command syntax
        if nargin==1
            if strcmpi(varargin{1},'round')
                yrange = round_range (yrange);
            else
                error('Unrecognised option')
            end
        end
        
        yrange={yrange};
    else
        % Return current y-axis limits
        range = get(gca,'Ylim');
        if nargout>=1, varargout{1} = range(1); end
        if nargout>=2, varargout{2} = range(2); end
        return
    end
    
elseif nargin==2 && (~isnumeric(varargin{1})||numel(varargin{1})==1) && (~isnumeric(varargin{2})||numel(varargin{2})==1)
    % Read scalar ylo and yhi from either function syntax or command syntax
    ylo=varargin{1};
    yhi=varargin{2};
    
    yrange=zeros(1,2);
    if isnumeric(ylo) && isscalar(ylo)
        yrange(1)=ylo;
    elseif ~isempty(ylo) && is_string(ylo)
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
    elseif ~isempty(yhi) && is_string(yhi)
        try
            yrange(2) = evalin('caller',yhi);
        catch
            error('Check input arguments');
        end
    else
        error('Check input arguments');
    end
    
    if yrange(1)>=yrange(2)
        error('Check ylo < yhi')
    end
    
    yrange={yrange};
    
elseif nargin==1 && iscell(varargin{1})
    % Must be cell array of pairs of limits
    nlim=numel(varargin{1});
    for i=1:nlim
        if ~isnumeric(varargin{1}{i})||numel(varargin{1}{i})~=2
            error('Check y-limits are a cell array of two-element numeric vectors')
        elseif varargin{1}{i}(1)>=varargin{1}{i}(2)
            error('Check ylo < yhi  for all pairs of limits')
        end
    end
    yrange=varargin{1};
    
else
    % One or more two element numeric vectors
    for i=1:nargin
        if ~isnumeric(varargin{i})||numel(varargin{i})~=2
            error('Check syntax of y-limits')
        elseif varargin{i}(1)>=varargin{i}(2)
            error('Check ylo < yhi  for all pairs of limits')
        end
    end
    yrange=varargin;
    
end

% Change limits
for i=1:numel(yrange)
    set (gca, 'YLim', yrange{i})
    if i~=numel(yrange), input('hit <CR> to continue'), end
end
