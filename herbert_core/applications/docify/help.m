function [out, docTopic] = help(varargin)
    % Customized overloaded help function
    % 1. If the help topic has docify directives, run docify and use its result
    % 2. Otherwise use the builtin help
    % This function assumes that the input is a string, like the built-in function
    %
    % A limitation of this function is that it cannot be used to look up
    % properties defined within the same file as a classdef
    % E.g. `help mfclass/fun` will produce the docstring in the original
    % mfclass.m file and *not* the docified version.
    % However, docify does not support such substitution in any case.
    %
    % Another limitation is that inherited methods in separate files
    % e.g. IX_data_1d/acosh which is inherited from IX_dataset
    % are not processed (they are not resolved).
    % E.g. `help IX_dataset/acosh` returns the docified version
    % but  `help IX_data_1d/acosh` returns the raw docify code.

    % Create a handle to the original Matlab help function
    persistent builtin_help;
    if isempty(builtin_help)
        builtin_help = get_shadowed_function_handle('help', mfilename('fullpath'));
    end
    
    if nargin == 0 && isscalar(dbstack)
        % Replicate Matlab behaviour where we get the help of the 
        % previous command entered if user just types `help` on the CLI
        helpProcess = get_previous_help(nargout);
    elseif strcmpi(varargin{1}, 'help')
        % Show docstring for builtin help
        helpProcess = show_builtin_help(nargout);
    elseif nargin == 1
        mfilename = check_docify(varargin{1});
        if ~isempty(mfilename)
            % Topic has docify strings, parse it
            helpProcess = docify_help(varargin{1}, mfilename, nargout, nargin);
        end
    end
    if ~exist('helpProcess', 'var') || isempty(helpProcess)
        % Calls the builtin help function
        if nargout == 0
            builtin_help(varargin{:});
        else
            [out, docTopic] = builtin_help(varargin{:});
        end
    else
        helpProcess.prepareHelpForDisplay;
        if nargout > 0
            out = helpProcess.helpStr;
            if nargout > 1
                docTopic = helpProcess.docLinks.referencePage;
                if isempty(docTopic)
                    docTopic = helpProcess.docLinks.productName;
                end
            end
        end
    end
end

function process = get_previous_help(n_out)
    process = helpUtils.helpProcess(n_out, 0, {});
    process.isAtCommandLine = true;
    process.getHelpText;
end

function process = show_builtin_help(n_out)
    list = which('help', '-all');
    f = strncmp(list, matlabroot, numel(matlabroot));
    if any(f)
        topic = list{find(f, 1, 'first')};
    else
        topic = 'help';
    end
    process = helpUtils.helpProcess(n_out, 1, {topic});
    process.getHelpText;
end
