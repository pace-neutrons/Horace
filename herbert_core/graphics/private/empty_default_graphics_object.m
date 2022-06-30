function fig_handle=empty_default_graphics_object()
% Default empty graphics object that spans across R2014a and R2014b
if verLessThan('matlab','8.4')
    fig_handle=[];
else
    fig_handle=repmat(matlab.graphics.GraphicsPlaceholder,0);
end
