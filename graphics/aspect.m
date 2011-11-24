function aspect(varargin)
% Set aspect ratio given the length of one unit length along each of the plot axes
%
%   >> aspect(x_ulen, y_ulen)
%   >> aspect([x_ulen, y_ulen])
%
%   >> aspect(x_ulen, y_ulen, z_ulen)
%   >> aspect([x_ulen, y_ulen, z_ulen])
%
%   >> aspect(mode)     % where mode is either 'auto' or 'manual'.
%
% Input: 
% ------
%	axesHandle  Handle of the axes which is to be scaled.
%   x_ulen      Defines the unit length along the x axis
%   y_ulen      Defines the unit length along the y axis
%   z_ulen      Defines the unit length along the z axis]
%   mode        Either 'auto' or 'manual'
%
% When the mode is set to 'auto', matlab chooses the aspect ratio which
% fills the figure the best.

if nargin==0
    error('No arguments given')
end

% Get current plot (if there is one)
if isempty(findall(0,'Type','figure'))
    disp('No current figure - operation ignored.');
end
a=get(gca,'DataAspectRatio');

% Branch on input arguments
if nargin==1 && ischar(varargin{1})
    if isstringmatchi(varargin{1},'auto')
        set(axesHandle_,'DataAspectRatioMode','auto');
    elseif isstringmatchi(varargin{1},'manual')
        set(axesHandle_,'DataAspectRatioMode','auto');
    else
        error('Input arguments must be unit length along axes or ''auto'' or ''manual''')
    end
    
elseif iscellnum(varargin)  % all numeric input
    u=zeros(1,3);
    if nargin==1 && (numel(varargin{1})==2 || numel(varargin{1})==3)
        u(1)=varargin{1}(1);
        u(2)=varargin{1}(2);
        if numel(varargin{1})==3
            u(3)=varargin{1}(3);
        end
    elseif nargin==2 && isscalar(varargin{1}) && isscalar(varargin{2})
        u(1)=varargin{1};
        u(2)=varargin{2};
    elseif nargin==3 && isscalar(varargin{1}) && isscalar(varargin{2}) && isscalar(varargin{3})
        u(1)=varargin{1};
        u(2)=varargin{2};
        u(3)=varargin{3};
    else
        error('Input arguments must be unit lengths along axes')
    end
    u=abs(u);
    u(~isfinite(u))=0;   % Inf, NaN considered as zero
    
    if all(u~=0)
        aspect_ratio = [1/u(1), 1/u(2), 1/u(3)];
    elseif sum(u==0)==1
        if u(1)==0
            aspect_ratio = [a(1)/max(a(2)*u(2),a(3)*u(3)), 1/u(2), 1/u(3)];
        elseif u(2)==0
            aspect_ratio = [1/u(1), a(2)/max(a(3)*u(3),a(1)*u(1)), 1/u(3)];
        elseif u(3)==0
            aspect_ratio = [1/u(1), 1/u(2), a(3)/max(a(1)*u(1),a(2)*u(2))];
            % aspect_ratio = [1/u(1), 1/u(2), a(3)*((1/u(1)+1/u(2))/(a(1)+a(2)))];    % seems to give the same
        end
    else  % no u or only one non-zero: no rescaling
        return
    end 
    set(gca,'DataAspectRatio',aspect_ratio);

else
    error('Input arguments must be unit length along axes or ''auto'' or ''manual''')
end
