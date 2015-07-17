function run_inspector(w,varargin)
%
% run_inspector(w)
%
% Creates a new window displaying the parts of an sqw dataset that came
% from individual runs, i.e. it is an animation of the result of a "split"
% command.
%
% The animation can be run using the following keyboard shortcuts (or by
% moving the scroll bar with the mouse):
%
%     Enter (Return) -- play/pause video (5 frames-per-second default).
%     Backspace -- play/pause video 5 times slower.
%     Right/left arrow keys -- advance/go back one frame.
%     Page down/page up -- advance/go back 10 frames.
%     Home/end -- go to first/last frame of video.
%
% Currently only works for 1d and 2d sqw data
%
% Optional inputs (multiple combinations allowed), with preceding keywords
%
% run_inspector(w,'col',[c_lo,c_hi]) - for the 2d slice case, allows you
%       to specify the limits of the colourbar. If not specified then each plot
%       will have different colour limits, determined by the min/max intensity.
%
% run_inspector(w,'ax',[x_lo,x_hi,y_lo,y_hi]) - for both 1d and 2d cases,
%       allows you to specify the limits of the x and y axes of the plot. The
%       default behaviour is to use the axes of the original (unsplit) object

%RAE 30/1/15

%Do some checks on the data:
if ~isa(w,'sqw') || ~is_sqw_type(w)
    error('Input dataset has to be sqw object with full contributing run information present');
end

if numel(w)~=1
    error('run inspector can only be used for a single sqw object, rather than an array of objects')
end

[nd,sz]=dimensions(w);
if nd<1 || nd>2
    error('Input dataset must be an sqw object that is 2d or 1d');
end


% Determine keyword arguments, if present
if nargin>1 && nargin<4
    %One keyword used
    if strcmp(varargin{1},'col') && isvector(varargin{2}) && ...
            numel(varargin{2})==2 && varargin{2}(2)>varargin{2}(1)
        clim=varargin{2};
    elseif strcmp(varargin{1},'ax') && isvector(varargin{2}) && ...
            numel(varargin{2})==4 && varargin{2}(2)>varargin{2}(1) && ...
            varargin{2}(4)>varargin{2}(3)
        axlim=varargin{2};
    else
        error('Check keyword argument is either ''col'' or ''ax'', and that color_hi>color_lo / ax_hi>ax_lo');
    end
elseif nargin>3 && nargin<6
    %Both keywords used
    if strcmp(varargin{1},'col') && isvector(varargin{2}) && ...
            numel(varargin{2})==2 && varargin{2}(2)>varargin{2}(1)
        clim=varargin{2};
    elseif strcmp(varargin{1},'ax') && isvector(varargin{2}) && ...
            numel(varargin{2})==4 && varargin{2}(2)>varargin{2}(1) && ...
            varargin{2}(4)>varargin{2}(3)
        axlim=varargin{2};
    else
        error('Check first keyword argument is either ''col'' or ''ax'', and that color_hi>color_lo / ax_hi>ax_lo');
    end
    %
    if strcmp(varargin{3},'col') && isvector(varargin{4}) && ...
            numel(varargin{4})==2 && varargin{4}(2)>varargin{4}(1)
        clim=varargin{4};
    elseif strcmp(varargin{3},'ax') && isvector(varargin{4}) && ...
            numel(varargin{4})==4 && varargin{4}(2)>varargin{4}(1) && ...
            varargin{4}(4)>varargin{4}(3)
        axlim=varargin{4};
    else
        error('Check second keyword argument is either ''col'' or ''ax'', and that color_hi>color_lo / ax_hi>ax_lo');
    end
elseif nargin==1
    %Default behaviour, so do nothing
else
    error('Check number of input arguments - should be either 1, 3 or 5');
end

%=======================================

%Now switch between 1d and 2d cases
if nd==1
    if exist('axlim','var')
        run_inspector_videofig(numel(w.header),@run_inspector_animate_1d,{split(w),axlim},5,10,[],'Name','Horace Run Inspector');
    else
        run_inspector_videofig(numel(w.header),@run_inspector_animate_1d,{split(w),[]},5,10,[],'Name','Horace Run Inspector');
    end
elseif nd==2
    if exist('axlim','var') && ~exist('clim','var')
        run_inspector_videofig(numel(w.header),@run_inspector_animate_2d,{split(w),[],axlim},5,10,[],'Name','Horace Run Inspector');
    elseif ~exist('axlim','var') && exist('clim','var')
        run_inspector_videofig(numel(w.header),@run_inspector_animate_2d,{split(w),clim,[]},5,10,[],'Name','Horace Run Inspector');
    elseif exist('axlim','var') && exist('clim','var')
        run_inspector_videofig(numel(w.header),@run_inspector_animate_2d,{split(w),clim,axlim},5,10,[],'Name','Horace Run Inspector');
    else
        run_inspector_videofig(numel(w.header),@run_inspector_animate_2d,{split(w),[],[]},5,10,[],'Name','Horace Run Inspector');
    end
end


    
    
    