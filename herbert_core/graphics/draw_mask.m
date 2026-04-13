function msk = draw_mask(fig_info,varargin)
%DRAW_MASK given 2-dimensional image, draw shape on this image and generate
% mask which covers parts of the image.
% Resulting mask may be used by 'mask' function to remove selected areas
% of sqw, d2d or IX_dataset_2D objects
%
%Inputs:
% fig_info  -- number which represents existing image, graphical axis
%              handle (e.g. obtained by calling gca for current image) or
%              plottable Horace object (sqw, dnd or IX_dataset_2D) to draw
%              mask on it. If Horace object is provided, the object gets
%              plotted
% Optional:
% '-freehand_draw' -- use MATLAB
%
% Returns:
% msk       -- logical mask to be used with mask algorithm to

% check input and return image axis
h_axis = check_fig_info(fig_info);

[ok,mess,draw_using_free,test_fig_info] = parse_char_options(varargin,{'-freehand_draw','-test_fig_info'});
if ~ok
    error('HORACE:draw_mask:invalid_argument',mess);
end
if test_fig_info
    msk = h_axis;
    return;
end

end

function h_axis = check_fig_info(fig_info)
% Read various forms of input information and return handle to plotting
% axis. Check if input info is responsible for 2D image.
if isnumeric(fig_info)
    fig_info = get_figure_handle (fig_info,'-single');
end
if isa(fig_info,'matlab.ui.Figure')
    fig_info = gca(fig_info);
end
if isa(fig_info,'matlab.graphics.axis.Axes')
    h_axis = fig_info;
    return;
end
if isa(fig_info,'data_plot_interface')
    if fig_info.NUM_DIMS ~= 2
        error('HORACE:draw_mask:invalid_argument',['input object contains %d dimensions.\n' ...
            'You can draw masks on images of 2-dimensional objects only'], ...
            fig_info.NUM_DIMS);
    end
    [~,h_axis] = plot(fig_info);
    return;
end
error('HORACE:draw_mask:invalid_argument',[ ...
    'draw_mask accepts 2D graphical objects with image axis or 2D plottable Horace objects\n' ...
    'Input class is %s'],class(fig_info))
end