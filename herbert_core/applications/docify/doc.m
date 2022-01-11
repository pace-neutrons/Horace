function doc(varargin)
    % Customized overloaded doc function
    % 1. If the topic has docify directives, run docify and use its result
    % 2. Otherwise use the builtin doc
    % This function assumes that the input is a string, like the built-in function
    %
    % A limitation of this function is that it cannot be used to look up
    % properties defined within the same file as a classdef
    % E.g. `doc mfclass/fun` will produce the docstring in the original
    % mfclass.m file and *not* the docified version.
    % However, docify does not support such substitution in any case.
    %
    % In addition, because we only apply docify to the desired topic files
    % sub-files will not be docified - e.g. for `doc mfclass` the
    % headers of docifiable methods (e.g. "mfclass/set_fun") will *not*
    % be docified and appear as a line of dashes.
    % If you click on the link, it calls `doc` again on that file and it
    % will then be docified.
    %
    % Finally, another limitation is that inherited methods in separate
    % files e.g. IX_data_1d/acosh which is inherited from IX_dataset
    % are not processed (they are not resolved).
    % E.g. `doc IX_dataset/acosh` returns the docified version
    % but  `doc IX_data_1d/acosh` returns the raw docify code.

    % Create a handle to the original Matlab help function
    persistent builtin_doc;
    if isempty(builtin_doc)
        builtin_doc = get_shadowed_function_handle('doc', mfilename('fullpath'));
    end
    
    if nargin == 1
        if strcmpi(varargin{1}, 'doc')
            % Open up the page for doc
            displayDocPage(struct('topic', '(matlab)/doc', 'isElement', 0));
        else
            mfilename = check_docify(varargin{1});
            if ~isempty(mfilename)
                % Topic has docify strings, parse it
                helpProcess = docify_help(varargin{1}, mfilename, 2, nargin);
            end
        end
    end
    if ~exist('helpProcess', 'var') || isempty(helpProcess)
        % Calls the builtin doc function
        builtin_doc(varargin{:});
    else
        display_docify(helpProcess, varargin{1});
    end
end

function display_docify(helpProcess, topic)
    helpProcess.specifyCommand('help');
    helpProcess.prepareHelpForDisplay;
    helpStr = regexprep(helpProcess.helpStr, ...
        '<a href="matlab:help ', '<a href="matlab:doc ');
    html = help2html(topic, '', '-doc');
    html = regexprep(html,'(<!--\s*helptext\s*-->.*</pre>)', ...
        sprintf('%s</pre>',regexptranslate('escape', helpStr)));
    web(['text://' html], '-helpbrowser');
end
