function colorslider(varargin)
% Add, update or delete a colorslider to a graphics figure
%
% A colorslider is a colorbar (as created by the Matlab colorbar function)
% together with (1) boxes to edit the minimum and maximum values for the
% colorscale and (2) a slider adjacent to each of those boxes to enable those
% values up or down by clicking on those arrows.
%
% Syntax:
% -------
% Add to the current axes of the current figure:
%
%   >> colorslider              % Add a colorslider to the current axes.
%                               % Update all the existing colorbar, if already present
%
%   >> colorslider ('update')   % Update all colorsliders on current figure, if
%                               % already present
%                               % (use if resize the figure, to reshape slider boxes)
%
%   >> colorslider ('cleanup')  % Cleanup any orphaned sliders and edit boxes
%                               % on the entire figure
%
%   >> colorslider ('delete')   % Delete colorslider, if present
%
%
% Add to specified axes:
%
%   >> colorslider (axes_handle)
%   >> colorslider (axes_handle, 'update')
%   >> colorslider (axes_handle, 'cleanup')
%   >> colorslider (axes_handle, 'delete')
%
%   The axes_handle could be to other axes on the current figure, or to axes on
%   another figure entirely. This is particularly useful when there are several
%   subplots on figures; if the axes handles have been previously stored then a
%   colorbar can be added without changing the focus of the current axes and
%   then returning it again.
%
%   [This syntax mirrors that of the Matlab function colorbar in that by default
%   the colorbar is plotted on the current axes of the current figure, but if
%   alternative target axes are given on the figure is given that supports a
%   colorbar then it will be plotted there.]


% Adapted from script by Radu Coldea 02-Oct-1999, by Dean Whittaker 2-2-2007,
% and then Toby Perring


% Parse arguments
if nargin>=1 && is_stringmatchi(varargin{end},'delete')
    option='delete';
    narg=nargin-1;
elseif nargin>=1 && is_stringmatchi(varargin{end},'cleanup')
    option='cleanup';
    narg=nargin-1;
elseif nargin>=1 && is_stringmatchi(varargin{end},'update')
    option='update';
    narg=nargin-1;
else
    option='create';
    narg=nargin;
end


% If there is no current figure, then one is created with the default axes by a
% call to Matlab function gca. if there is a current figure, but it has no axes,
% then axes are created on that figure.by the call to gca. This seems to be the
% way that colorbar works, which we are aiming to mimic.
if narg==0
    axes_handle = gca;
elseif narg==1
    if ~isa(varargin{1},'handle') || ~isgraphics(varargin{1}) || ...
            ~strcmp(get(varargin{1},'Type'),'axes')
        error('HERBERT:graphics:invalid_argument', ...
            'The target for a colorslider must be a valid axes object')
    end
    axes_handle = varargin{1};
else
    error('HERBERT:graphics:invalid_argument', ...
        'Check number and type of input arguments')
end
fig_handle = ancestor(axes_handle, 'figure');


% Perform th appropriate colorslider operations according to the input option.
switch option
    case 'create'
        % Add a colorslider to the axes 
        % That is, delete a colorbar or colorslider if present, and then create
        % a colorslider regardless of whether or not one was present on entry.
        colorslider_delete(axes_handle)
        colorbar(axes_handle, 'off')    % delete any colorbar that is not part of a colorslider
        colorslider_create(axes_handle)
        
    case 'update'
        % Update all colorsliders on the figure
        % That is, delete and recreate on all axes where there is already a
        % colorslider present on the axes.
        axes_h = findobj(fig_handle, 'Type', 'Axes', '-depth', 1);
        for h = make_row(axes_h)    % index to for loop needs to be a row vector
            if ~isempty(get_colorbar_handle(h))
                colorslider_delete(h)
                colorbar(h, 'off')  % delete colorbar(s) not part of a colorslider
                colorslider_create(h)
            end
        end
        
    case 'cleanup'
        % Delete any orphaned sliders and edit boxes that could have been left
        % over if the Matlab function >> colorbar('off') was used. This will
        % have deleted the colorbar, but not the sliders and edit boxes.
        % This is performed for all axes on the figure, not just the current
        % axes.
        
        % === Will be done on exit from this function

        
    case 'delete'
        % Delete the colorslider on the axes, if present, but leave any colorbar
        % that is not part of a colorslider.
        colorslider_delete(axes_handle)
end


% Always do a cleanup, that is, delete any orphaned colorslider sliders and edit
% boxes across the whole figure.
colorslider_cleanup(fig_handle)
