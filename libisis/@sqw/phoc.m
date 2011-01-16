function [figureHandle, axesHandle, plotHandle] = phoc(win,varargin)
% Overplot histogram of a 1d dataset on an existing figure, irrespective of its type.
%
% Optional inputs:
%   >> phoc(win)
%   >> phoc(win,'color','red')
%
% See help for libisis\ph for more details of further options

% R.A. Ewings 14/10/2008

for i=1:numel(win)
    if dimensions(win(i))~=1
        if numel(win)==1
            error('sqw object is not one dimensional')
        else
            error('Not all elements in the array of sqw objects are one dimensional')
        end
    end
end

[figureHandle_, axesHandle_, plotHandle_] = phoc(IXTdataset_1d(win),varargin{:});

% Output only if requested
if nargout>=1, figureHandle=figureHandle_; end
if nargout>=2, axesHandle=axesHandle_; end
if nargout>=3, plotHandle=plotHandle_; end
