function free=free_parse(free_in,np)
% Determine if an argument is a valid free and expand input argument to full argument
%
%   >> free=free_parse(free_in,np)
%
% Input:
% ------
%   free_in    Description of which parameters are free and which are fixed
%
%               If there is only one function, that is, it applies globally
%              to all datasets, then free_in must be:
%                - An empty argument (which means all parameters are free)
%                - A row vector of zeros and ones (or a row of logicals)
%                 indicating which parameters are fixed or free for a function.
%                Equivalently:
%                - A cell array with a single row vector
%
%               If there is more than one function, that is they apply locally,
%              one function per dataset, then free_in must be:
%                - An empty argument (which means all parameters are free for all functions)
%                - A cell array of row vectors, one per function
%                - A single row vector (or a cell array with a single row vector) which
%                 will be repeated for each function
%
%   np          Array with number of parameters for each function. Can
%              have zero length (i.e. no functions)
%
% Output:
% -------
%   free       Cell array with same size as input argument np, of logical
%              row vectors, where the number of elements of the ith vector
%              equals the number of parameters for the ith function, and with
%              elements =true for free parameters, =false for fixed parameters
%               If not OK, free={}
%
%
%  EXAMPLES of free_in:
%   If just one function:
%      [0,1,1,0]
%     {[0,1,1,0]}   % valid, but it is unnecessary to make it a cell
%
%   If two functions:
%      [0,1,1,0]    % applies to both functions; valid if both have four parameters
%     {[0,1,1,0]}   % equivalent syntax
%     {[0,1,1,0],[0,0,1,0]}     % to have different free parameters
%     {[0,1,1,0],[0,0,1]}       % if the functions have four and three parameters respectively

if isempty(free_in)    % Empty argument; assume all parameters are free

    free = arrayfun(@(n) true(n, 1), np, 'UniformOutput', false);

elseif iscell(free_in)
    if isscalar(free_in)   % the parameter list is assumed to apply for every function
        if ~all(np(:)==np(1))
            error('HERBERT:free_parse:invalid_argument', ...
                  'A single free parameter list is only valid if all functions have same number of parameters')
        end

        free_tmp = free_parse_single(free_in{1},np(1));
        free = repmat({free_tmp}, size(np));

    elseif numel(free_in)==numel(np)

        free = cellfun(@free_parse_single, free_in, num2cell(np), ...
                       'UniformOutput', false, 'ErrorHandler', @errorFunc);

    else
        error('HERBERT:free_parse:invalid_argument', ...
              'Array of free parameters lists is not scalar or does not have same size as array of data sources')
    end

elseif isnumeric(free_in)||islogical(free_in)     % Assume applies to all functions
    if ~all(np(:)==np(1))
        error('HERBERT:free_parse:invalid_argument', ...
              'A single free parameter list is only valid if all functions have same number of parameters')
    end

    free_tmp = free_parse_single(free_in,np(1));

    free = repmat({free_tmp}, size(np));

else
    error('HERBERT:free_parse:invalid_argument', ...
          'Free parameter list must be empty, numeric or logical array or a cell array of numeric or logical arrays')
end

end

function free=free_parse_single(free_in,np)
% Determine if an argument is a valid free and expand input argument to full argument
%
%   >> free=free_parse_single(free_in,np)
%
% Input:
% ------
%   free_in     Vector describing which parameters are free and which are fixed. Must be:
%               - empty, then all parameters are free
%               - numeric vector of zeros and ones, or logical vector
%   np          Number of parameters in total
%
% Output:
% -------
%   free        Logical row vector length np with elements =true for free parameters,
%              and =false for fixed parameters


% Original author: T.G.Perring
%
% $Revision:: 840 ($Date:: 2020-02-10 16:05:56 +0000 (Mon, 10 Feb 2020) $)

if isempty(free_in)
    free=true(1,np);
    return
end

if np>0
    mess='Free parameters argument must be a vector containing only ones and zeros and length matching number of parameters';
else
    mess='Free parameters argument must be an empty numeric or logical vector as the parameter list is empty';
end

validateattributes(free_in, {'numeric', 'logical'}, {'vector', 'binary', 'numel', np});

free = logical(free_in(:)');

end

function errorFunc(S, varargin)
    error(S.identifier, ["Error handling argument (%d): %s"], S.index, S.message)
end
