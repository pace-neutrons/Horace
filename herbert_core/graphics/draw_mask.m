function [msk,varargout] = draw_mask(fig_info,varargin)
%DRAW_MASK Given 2-dimensional image, draw shape on this image and generate
%mask which excludes selected part of the image.
% Resulting mask may be used by 'mask' function to remove selected areas
% of sqw, d2d or IX_dataset_2D objects
%
%Inputs:
% fig_info  -- either:
%              number which represents existing image,
%        or
%              graphical axis handle (e.g. obtained by calling gca for current image)
%        or
%              plottable Horace object (sqw, dnd or IX_dataset_2D) to draw
%              mask on it. If Horace object is provided, "mask_vertices"
%              option is not used and image processing toolbox is available
%              the object gets plotted to allow interactive mask drawing.
%
% Optional:            (all keys may be abbreviated to 3 symbols)
% 'mask_vertices'   -- if this option is provided, one have to supply
%                      array of points which define mask, namely surrounds
%                      the points to be masked. The points have to be
%                      provided as 2xNP array where first colum define x
%                      and second column y coordinates of the hull
%                      surrounding masked points. The coordinates of these
%                      points have to be expressed in image coordinates.
%  IMPORTANT:
%                       This key disables image drawing capability and is
%                       mandatory if image processing toolbox is not
%                       present. In this case, one needs to measure and
%                       provide mask points manualy.
%
% '-freehand_draw'   -- use MATLAB "drawfreehand" routine to draw mask on
%                       the image provided. If this key is not provided,
%                       routine uses MATLAB's "drawpolygon" routine to draw
%                       the mask. Option is ignored if fig_info is Horace
%                       dataset and points are provided. Its available only
%                       if image processing toolbox is installed.
% '-keep_area'      -- If option provided, area surrounded by input points
%                      is kept and external area is masked. By default,
%                      mask excludes selected part of the image.
% '-disable_ipt'    -- disable image processing toolbox capabilities even
%                      if they are present. Usually for testing
%
% Returns:
% msk       -- logical mask to be used with mask algorithm to
% Optional
% ax        -- handle to axis where mask is drawn or structure with
%              XLim,YLim fields containing image ranges.
% mask_vertices
%           -- array of points used for masking. Same as input points if
%              mask is build on Horace object rather than image. Result of
%              drawpolygon or drawfreehand function containing polygon
%              vertices if input is graphical object.

persistent img_processing_toolbox_present;
if isempty(img_processing_toolbox_present)
    img_processing_toolbox_present = license('test','image_toolbox');
end

options = {'mask_vertices','-freehand_draw','-keep_area','-test_fig_info','-disable_ipt'};
[ok,mess,mask_vertices_provided,draw_using_free,keep_area,test_fig_info,disable_ipt,argi] =...
    parse_char_options(varargin,options);
if ~ok
    error('HORACE:draw_mask:invalid_argument',mess);
end
use_ipt = img_processing_toolbox_present&&~disable_ipt;
if ~use_ipt && ~mask_vertices_provided
    error('HORACE:draw_mask:invalid_argument', ...
        ['Image processing toolbox is necessary to draw mask manually.\n' ...
        ' If it is not present, provide array of mask points']);
end

% check input and return image axis or information about image axis.
[h_axis,sz] = check_fig_info(fig_info,mask_vertices_provided);


if test_fig_info
    msk = h_axis;
    varargout{1} = sz;
    return;
end
if nargout>1
    varargout{1} = h_axis;
end
x_range = h_axis.XLim;
y_range = h_axis.YLim;

if mask_vertices_provided
    points = argi{1};
    if size(points,1)~=2
        error('HORACE:draw_mask:invalid_argument',[...
            'Size of input points defining mask hull has to be 2xNPoints.\n' ...
            'Provided points have size: %s'],disp2str(size(points)));
    end
    minma = min_max(points);
    if minma(1,1)<x_range(1)|| minma(1,2)>x_range(2)||minma(2,1)<y_range(1) ||minma(2,2)>y_range(2)
        error('HORACE:draw_mask:invalid_argument',[...
            '*** Some points provided as input located within ranges:\n' ...
            '    min: [%g, %g] ; max: [%g, %g]\n',...
            '    which are outside of the masked image ranges:\n' ...
            '    min: [%g, %g] ; max: [%g, %g]\n'],...
            minma(1,1),minma(2,1),minma(1,2),minma(2,2), ...
            x_range(1),y_range(1),x_range(2),y_range(2));
    end
    points = points';
else
    if draw_using_free
        shape = drawfreehand(h_axis);
    else
        shape = drawpolygon(h_axis);
    end
    points = shape.Position;
end
if nargout>2
    varargout{2} = points;
end
iy = floor((sz(1)-1)*(points(:,1)-x_range(1))/(x_range(2)-x_range(1)))+1;
ix = floor((sz(2)-1)*(points(:,2)-y_range(1))/(y_range(2)-y_range(1)))+1;

if use_ipt
    msk = poly2mask(ix,iy,sz(1),sz(2));
else
    msk = poly2mask_equiv(ix,iy,sz(1),sz(2));
end
if ~keep_area
    msk = ~msk;
end
end

function [h_axis,sz] = check_fig_info(fig_info,points_provided)
% Read various forms of input information and return handle to plotting
% axis. Check if input info is responsible for 2D image.
sz = [];
source = [];
if isnumeric(fig_info)
    fig_info = get_figure_handle (fig_info,'-single');
    source = src(fig_info);
    if ~isempty(source)
        sz = source.img_size;
    end
end

if isa(fig_info,'matlab.ui.Figure')
    if isempty(source)
        source = src(fig_info);
        if ~isempty(source)
            sz = source.img_size;
        end
    end

    fig_info = gca(fig_info);
end
if isa(fig_info,'matlab.graphics.axis.Axes')
    h_axis = fig_info;
    if isempty(sz)
        sz = ones(1,2);
        if ~isempty(h_axis.Children)
            sz(1) = numel(unique(h_axis.Children.XData));
            sz(2) = numel(unique(h_axis.Children.YData));
        end
    end
    return;
end
if isa(fig_info,'data_plot_interface')
    if fig_info.NUM_DIMS ~= 2
        error('HORACE:draw_mask:invalid_argument',['input object contains %d dimensions.\n' ...
            'You can draw masks on images of 2-dimensional objects only'], ...
            fig_info.NUM_DIMS);
    end
    if isa(fig_info,'PixelDataBase')
        error('HORACE:draw_mask:invalid_argument',...
            ['Building masks on Pixel Dataset is not implemented.' ...
            ' Contact HoraceHelp@stfc.ac.uk team if you think it should'])
    end
    sz = fig_info.img_size;
    if points_provided
        if isa(fig_info,'sqw')
            dat = fig_info.data;
            X_range = dat.img_range(:,dat.pax(1));
            Y_range = dat.img_range(:,dat.pax(2));
        elseif isa(fig_info,'d2d')
            dat = fig_info;
            X_range = dat.img_range(:,dat.pax(1));
            Y_range = dat.img_range(:,dat.pax(2));
        else %IX_dataset_2D
            X_range = min_max(fig_info.x)';
            Y_range = min_max(fig_info.y)';
        end
        h_axis = struct('XLim',X_range','YLim',Y_range');
    else
        [~,h_axis] = plot(fig_info);
    end
    return;
end
error('HORACE:draw_mask:invalid_argument',[ ...
    'draw_mask accepts 2D graphical objects with image axis or 2D plottable Horace objects\n' ...
    'Input class is %s'],class(fig_info))
end

function mask = poly2mask_equiv(x, y, m, n)
%POLY2MASK_EQUIV Create binary mask from polygon (no toolboxes)
%   x, y - polygon vertices in image/axes coordinates
%   m, n - mask size (rows, cols)

% Ensure column vectors
x = x(:);
y = y(:);

% Close polygon if needed
if x(1) ~= x(end) || y(1) ~= y(end)
    x(end+1) = x(1);
    y(end+1) = y(1);
end

% Pixel grid (pixel centers)
[X, Y] = meshgrid(1:n, 1:m);

% Point-in-polygon test
%[mask,on] = inpolygon(X, Y, x, y);
mask = inpolygon(X, Y, x, y);
end