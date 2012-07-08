function [figureHandle, axesHandle, plotHandle] = ps2(w,varargin)
% Overplot a surface plot of a 2D sqw object or array of sqw objects, with colour scale from a second source
%
%   >> ps2(w)       % Use error bars to set colour scale
%   >> ps2(w,wc)    % Signal in wc sets colour scale
%                   % (sqw or d2d object with same array size as w, or a numeric array)
%
% Differs from ps in that the signal sets the z axis, and the colouring is set by the 
% error bars, or another object. This enable a function of three variables to be plotted
% (e.g. dispersion relation where the 'signal' array hold the energy
% and the error array hold the spectral weight).
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = ps2(w,...) 


name_surface =  get_global_var('horace_plot','name_surface');

% Perform plot
if ~isa(w,'sqw')
    error('Object to plot must be an sqw object or array of objects')
end

[ok,mess]=all_2D_sqw(w);
if ~ok, error(mess), end

if numel(varargin)>0 && (isa(varargin{1},class(w))||isa(varargin{1},'d2d')||(isnumeric(varargin{1})&&rem(numel(varargin),2)==1))
    % Find out if two 2D passed into function, and check they have consistent sizes
    if isa(varargin{1},class(w))||isa(varargin{1},'d2d')
        if isa(varargin{1},class(w))
            [ok,mess]=all_2D_sqw(varargin{1});
            if ~ok, error(mess), end
        end
        if numel(w)==numel(varargin{1})
            wc=IX_dataset_2d(varargin{1});
            for i=1:numel(w)
                if size(w(i).data.s)~=size(wc(i).signal)
                    error('The signal arrays of corresponding pairs of datasets in the two arrays of datasets do not have the same size')
                end
            end
        else
            error('The number of datasets must be the same in the two arrays of datasets to be plotted')
        end
    else
        if numel(w)==1
            sz=size(varargin{1});
            if ~(numel(sz)==2 && all(size(w.data.s)==sz))
                error('Size of signal array of the dataset and the numeric array do not match')
            end
        else
            error('Can only have one dataset if second argument is a numeric array')
        end
        wc=varargin{1};
    end
    % Perform plot
    [figureHandle_, axesHandle_, plotHandle_] = ps2(IX_dataset_2d(w), wc, varargin{2:end}, 'name', name_surface);
    if ~ok
        error(mess)
    end
else
    [figureHandle_, axesHandle_, plotHandle_] = ps2(IX_dataset_2d(w), varargin{:}, 'name', name_surface);
    if ~ok
        error(mess)
    end
end

pax = w(1).data.pax;
dax = w(1).data.dax;                 % permutation of projection axes to give display axes
ulen = w(1).data.ulen(pax(dax));     % unit length in order of the display axes
energy_axis = 4;    % by convention in Horace
if pax(dax(1))~=energy_axis && pax(dax(2))~=energy_axis    % both plot axes are Q axes
    aspect(ulen(1), ulen(2));
end

colorslider

% Output only if requested
if nargout>=1, figureHandle=figureHandle_; end
if nargout>=2, axesHandle=axesHandle_; end
if nargout>=3, plotHandle=plotHandle_; end

%--------------------------------------------------------------------------------------------------
function [ok,mess]=all_2D_sqw(w)
for i=1:numel(w)
    if dimensions(w(i))~=2
        if numel(w)==1
            ok=false; mess='Dataset is not two dimensional sqw object or array of objects';
            return
        else
            ok=false; mess='Not all elements in the array of datasets are two dimensional sqw object or array of objects';
            return
        end
    end
end
ok=true; mess='';
