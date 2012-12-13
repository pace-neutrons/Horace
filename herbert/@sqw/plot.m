function [figureHandle, axesHandle, plotHandle] = plot(w,varargin)
% Plot 1D, 2D or 3D sqw object or array of objects
%
%   >> plot(w)
%
% Equivalent to:
%   >> dp(w)              % 1D dataset
%
%   >> da(w)              % 2D dataset
%
%   >> sliceomatic(w)     % 3D dataset

nd=zeros(size(w));
for i=1:numel(w)
    nd(i)=dimensions(w(i)); % find out what dimensionality dataset we have.
end

if ~all(nd==nd(i))
    error('Not all objects to be plotted have the same dimensionality')
else
    nd=nd(1);
    if nd==0 || nd>=4
        error('Dataset is neither 1d, 2d, nor 3d, so cannot be plotted');
    end
end

if nd==1
    [figureHandle_, axesHandle_, plotHandle_] = dp(w,varargin{:});
elseif nd==2
    [figureHandle_, axesHandle_, plotHandle_] = da(w,varargin{:});
else
    % fixes problem on dual monitor systems. Need checks about negative side
    % effects on other systems.
    mode = get(0, 'DefaultFigureRendererMode');
    rend = get(0, 'DefaultFigureRenderer');
    set(0, 'DefaultFigureRendererMode', 'manual');
    set(0,'DefaultFigureRenderer','zbuffer');

    [figureHandle_, axesHandle_, plotHandle_] = sliceomatic(w,varargin{:});
    set(0, 'DefaultFigureRendererMode', mode);
    set(0,'DefaultFigureRenderer',rend );
end

% Output only if requested
if nargout>=1, figureHandle=figureHandle_; end
if nargout>=2, axesHandle=axesHandle_; end
if nargout>=3, plotHandle=plotHandle_; end
