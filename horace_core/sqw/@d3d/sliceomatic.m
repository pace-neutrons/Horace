function varargout = sliceomatic(w, varargin)
% Plots 3D sqw object using sliceomatic
%
%   >> sliceomatic (w)
%   >> sliceomatic (w, 'isonormals', true)     % to enable isonormals
%
%   >> sliceomatic (w,...,'-noaspect')  % Do not change aspect ratio
%                                       % according to data axes unit lengths
%
% To get handles to the graphics figure:
%   >> [figureHandle_, axesHandle_, plotHandle_] = sliceomatic(w,...)
%
%
% NOTES:
%
% - Ensure that the slice color plotting is in 'texture' mode -
%      On the 'AllSlices' menu click 'Color Texture'. No indication will
%      be made on this menu to show that it has been selected, but you can
%      see the result if you right-click on an arrow indicating a slice on
%      the graphics window.
%
% - To set the default for future Sliceomatic sessions -
%      On the 'Object_Defaults' menu select 'Slice Color Texture'

% Dean Whittaker 2008
% T.G.Perring 13 Nov 2008



% Strip trailing option, if present
[opt_adjust,opt_present]=data_plot_interface.adjust_aspect_option(varargin);

n_plots = numel(w);
figureHandle_ = cell(n_plots ,1);
axesHandle_   = cell(n_plots ,1);
plotHandle_   = cell(n_plots ,1);

for i= 1:n_plots
    pax = w(i).pax;
    dax = w(i).dax;                 % permutation of projection axes to give display axes
    ulabel = w(i).label(pax(dax)); % labels in order of the display axes
    ulen = w(i).axes.ulen(pax(dax));     % unit length in order of the display axes

    % Create sliceomatic window
    if i == 1
        name_sliceomatic0 =  get_global_var('horace_plot','name_sliceomatic');
        name_sliceomatic = name_sliceomatic0;
    else
        name_sliceomatic  = sprintf('%s-%d',name_sliceomatic0,i);
    end
    [figureHandle_{i}, axesHandle_{i}, plotHandle_{i}] = sliceomatic (IX_dataset_3d(w(i)),'x_axis',ulabel{1},'y_axis',ulabel{2},'z_axis',ulabel{3},...
        'name',name_sliceomatic,varargin{1:end-opt_present});

    % Rescale plot so that aspect ratios reflect relative lengths of Q axes
    adjust_aspect = w(i).axes.changes_aspect_ratio;
    if adjust_aspect || opt_adjust
        energy_axis = 4;    % by convention, the energy axis is always the 4th projection axis
        if isempty(find(pax==energy_axis, 1))   % none of the plot axes is an energy axis
            aspect = [1/ulen(1), 1/ulen(2), 1/ulen(3)];
        else
            aspect = [1/ulen(1), 1/ulen(2), 1/ulen(3)];
            a = get(gca,'DataAspectRatio');
            epax = find(pax(dax)==energy_axis); % index of the display axis corresponding to energy
            qpax = rem([epax,epax+1],3)+1;      % indices of the other two display axes (cyclic permutation)
            aspect(epax) = a(epax)/max([ulen(qpax(1))*a(qpax(1)), ulen(qpax(2))*a(qpax(2))]);
        end
        set(gca,'DataAspectRatio',aspect);
    end
end

% Output only if requested
if nargout>0
    figureHandle_ = [figureHandle_{:}];
    axesHandle_   = [axesHandle_{:}];
    plotHandle_   = [plotHandle_{:}];
    varargout = data_plot_interface.set_argout(nargout,figureHandle_, axesHandle_, plotHandle_);
end
