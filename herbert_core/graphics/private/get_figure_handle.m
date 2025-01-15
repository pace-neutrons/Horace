function fig_handle = get_figure_handle (varargin)
% Return the handle of the current figure or handle(s) of the indicated figure(s)
%
%   >> fig_handle = get_figure_handle            % current figure
%   >> fig_handle = get_figure_handle (fig)      % indicated figures(s)
%   >> fig_handle = get_figure_handle ('-all')   % all figures
%
% Demand that there is a one and only figure found (throws an error otherwise):
%   >> fig_handle = get_figure_handle (..., '-single')
%
% Normally fig would contain a single character string, or a scalar figure
% number or handle. However, you can give a cell array of names, or array of
% numbers or handles. These are therefore effectively search options from which
% to find instances of valid figures. The number of returned figure handles
% gives the number of valid figures.
%
% Note that:
% - There may be several figures with the same name (the name is not a unique
%   identifier); the figure handle will be retuned for all figures with a given
%   name.
% - Only unique figure handles are returned.
% - Only figure handles to currently existing figures are returned.
%  (A figure handle could still exist even if there is no corresponding figure,
%   for example if the handle was saved in a variable and the figure
%   later deleted. This function therefore acts as a filter on input figure
%   handles to remove those handles for which there is no longer a figure.)
%
%
% Input:
% ------
%   fig         Figure name or cell array of figure names
%          *OR* Figure number or array of figure numbers
%          *OR* Figure handle or array of figure handles
%
%               If fig is not given, or is [], the function returns the figure
%              handle for the current figure, if one exists.
%
%               Note: an empty character string or one containing just
%              whitespace is a valid name: the name is '' i.e. the empty string.
%
%               If fig is set to '-all', then the function returns the handles
%              of all figures.
%
% Optional argument:
%   '-single'   Throw an error with an informative message if there are no
%              figures or more than one figure that is found by input argument
%              fig.
%
% Output:
% -------
%   fig_handle  Column vector of handles of any figures found that match one of
%              the given name(s)/number(s)/handle(s).
%               Note that several figures can have the same name; the handles of
%              all figures with a given name are returned. Figure names for
%              which there are no corresponding figures are ignored.
%               Figure numbers or figure handles with no corresponding figure
%              are also ignored.
%
%               The function retains unique handles only. For example:
%                   >> fig_handle = get_figure_handle ([3,1,1,3,1])
%              will return just two figure handles, one for figure number 3, the
%              other for figure number 1. The order in which figure handles
%              appear in the output argument does not necessarily bear any
%              particular relationship to the order of elements in the input
%              argument fig.


% Parse input arguments
% ---------------------
% Check if option '-single' has been given
if nargin>0 && (is_string(varargin{end}) && ...
        strncmpi(varargin{end}, '-single', numel(varargin{end})))
    single_figure_only = true;
    narg = nargin - 1;
else
    single_figure_only = false;
    narg = nargin;
end
% Get fig argument, if present
if narg==1
    fig = varargin{1};
elseif narg~=0
    error('HERBERT:graphics:invalid_argument', 'Too many input arguments given')
end


% Find figure handles
% -------------------
if ~exist('fig','var') || (isnumeric(fig) && isempty(fig))
    % Case of no input - return the handle for the current figure, if it exists
    if ~isempty(findobj(0, 'Type', 'figure'))
        fig_handle = gcf; % current figure
    end
    
elseif isnumeric(fig)
    % Case of figure number(s)
    all_fig_handles = findobj(0, 'Type', 'figure');
    % Use arrayfun to deal with the fact that get(h, 'Number') returns a numeric
    % scalar if h is a single figure handle, but a cell array of numeric scalars
    % if h is an array of figure handles (i.e. 2 or more figures were found)
    all_fig_numbers = arrayfun(@(x)(get(x, 'Number')), all_fig_handles);
    [valid, loc] = ismember(fig, all_fig_numbers);
    fig_handle = all_fig_handles(loc(valid(:)));
    
elseif is_string(fig) || (iscell(fig) && all(cellfun(@is_string, fig(:))))
    % Could be a figure name or cell array of figure names
    if ~iscell(fig)
        fig = {fig};    % for convenience of code simplicity
    end
    fig = strtrim(fig); % strim leading and trailing whitespace
    if numel(fig)==1 && numel(fig{1})>2 && strncmpi(fig{1}, '-all', numel(fig{1}))
        % Return handles for all figures
        fig_handle = findobj(0, 'Type', 'figure');
    else
        % Get handles for those figures whose names appear in the input argument
        h = cellfun(@(x)(findobj('Name', x, 'Type', 'figure')), fig, ...
            'UniformOutput', false);
        fig_handle = vertcat(h{:});
    end
    
elseif isa(fig,'matlab.ui.Figure')
    % Handle(s) to graphics window(s)
    % Check that the figure handles are still valid - one or more figures
    % might have been deleted since the argument fig was filled.
    valid = isvalid(fig);
    fig_handle = fig(valid(:));
    
else
    error('HERBERT:graphics:invalid_argument', ...
        ['Check input could (an array of) figure number(s) or figure ', ...
        'handle(s), or a (cell array of) figure name(s)'])
end

% Pick out the unique figures
if numel(fig_handle) > 1
    fig_handle = unique (fig_handle, 'stable');
end


% Check if one and only one figure, and throw an error if not
% -----------------------------------------------------------
if single_figure_only
    if isempty(fig_handle)
        error('HERBERT:graphics:invalid_argument', ...
            ['There are no figures with the requested name(s), figure ', ...
            'handle(s) or figure number(s)'])
    elseif numel(unique(fig_handle))>1
        error('HERBERT:graphics:invalid_argument', ...
            ['There is more than one figure with the requested name(s), ', ...
            'figure handle(s) or figure number(s)'])
    end
end


% Reshape empty output object
% ---------------------------
% Ensure that an empty figure handle has size [0,0]. This is to be consistent
% with the output of findobj(0, 'Type', 'figure') if no figures are found, and
% ensures consistency of the size of empty output from the various if blocks
% above.
if isempty(fig_handle)
    fig_handle = reshape(fig_handle, 0, 0);
end
