function [fig_handle, axes_handle, plot_handle] = ps2(w,varargin)
% Overplot a surface plot of an IX_dataset_2d or array of IX_dataset_2d, with colour scale from a second source
%
%   >> ps2(w)       % Use error bars to set colour scale
%   >> ps2(w,wc)    % Signal in wc sets colour scale
%                   % (IX_dataset_2d with same array size as w, or a numeric array)
%
% Advanced use:
%   >> ps2(...,'name',fig_name)        % draw with name = fig_name
%
% Differs from ps in that the signal sets the z axis, and the colouring is set by the 
% error bars, or another object. This enable a function of three variables to be plotted
% (e.g. dispersion relation where the 'signal' array hold the energy
% and the error array hold the spectral weight).
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = ps2(w,...) 

% Check input arguments
[ok,mess]=parse_args_simple_ok_syntax({'name'},varargin{:});
if ~ok
    error(mess)
end

if ~isa(w,'IX_dataset_2d')
    error('First argument must be a 2D data object class IX_dataset_2d')
end

% Perform plot
if numel(varargin)>0 && (isa(varargin{1},class(w))||(isnumeric(varargin{1})&&rem(numel(varargin),2)==1))
    % Find out if two IX_datset_2d passed into function, and check they have consistent sizes
    wc=varargin{1};
    if isa(wc,class(w))
        if numel(w)==numel(wc)
            for i=1:numel(w)
                if size(w(i).signal)~=size(wc(i).signal)
                    error('The signal arrays of corresponding pairs of datasets in the two arrays of datasets do not have the same size')
                end
            end
        else
            error('The number of datasets must be the same in the two arrays of datasets to be plotted')
        end
    else
        if numel(w)==1
            sz=size(wc);
            if ~(numel(sz)==2 && all(size(w.signal)==sz))
                error('Size of signal array of the dataset and the numeric array do not match')
            end
        else
            error('Can only have one dataset if second argument is a numeric array')
        end
    end
else
    [fig_,axes_,plot_,ok,mess]=plot_twod (w,varargin{:},'newplot',false,'type','surface2');
    if ~ok
        error(mess)
    end
end

% Output only if requested
if nargout>=1, fig_handle=fig_; end
if nargout>=2, axes_handle=axes_; end
if nargout>=3, plot_handle=plot_; end
