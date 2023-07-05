function [pin, np]=pin_parse(pin_in, fun)
% Check if form of parameter object is a valid parameter list for given functions
%
%   >> [np, pin]=pin_parse(pin_in, fun)
%
% Input:
% ------
%   pin_in      List of parameters for the function(s).
%
%               If there is only one function for which parameters are needed
%              pin is passed straight to the constructor for a parameter list,
%              mfclass_plist
%
%               If there is more than one function then if pin_in is a cell array
%              with the same size as input argument fun (see below), then pin_in{i}
%              is assumed to be the parameter list for the ith function. Otherwise,
%              pin_in is assumed to be the parameter list for every function.
%
%               If a function handle has not been given, then any empty value for the
%              corresponding pin_in for that function is interpreted as being OK, and
%              the corresponding pin set to mfclass_plist()
%
%   fun         Cell array of function handles (if just one, must still be a cell array)
%               Missing functions have element equal to []. Can be empty.
%
% Output:
% -------
%   pin         Array of valid parameter lists, one list per function. size(pin)==size(fun)
%              (constructed from pin_in according to description below)
%   np          Array of the number of parameters in the root numeric array for each function
%
%
%
% ---------------------
% EXAMPLES of pin_in:
% ---------------------
%   If just one function (i.e. fun is scalar):
%      [10, 2]
%     {[10, 2], 'filter', true}
%    {{[10, 2], 'filter', true}}   % valid, but perhaps not what you might expect:
%                               % pin will have a single, non-numeric argument
%                               % which is: {[10, 2], 'filter', true}
%
%   If two functions:
%      [10, 5, 2]                 % will apply to both functions
%     {[10, 5, 2]}                % equivalent alternative syntax
%     {[10, 2], [15, 3]}           % different parameters for each function
%     {[10, 2], 'filter', true}    % *** NOT VALID: not a single parameter list
%                                (interpreted as three parameter lists, the first
%                                 [10, 2], the second 'filter', the third true)
%     {{[10, 2], 'filter', true}}  % valid: now a single parameter list
%                               % and will apply to both functions
%     {{[10, 2], 'filter', true}, {[15, 3], 'hat', false}}  % different parameters for each function


% Original author: T.G.Perring

if ~isa(pin_in, 'mfclass_plist')

    switch numel(fun)
      case 0
        % No functions, so only valid input is empty
        if ~isempty(pin_in)
            error('HERBERT:pin_parse:invalid_argument', ...
                  'There are no function handles or place holders, but parameters have been provided.');
        end

        pin = repmat(mfclass_plist(), size(fun));
      case 1
        % Single function
        % If the argument is a cell array containing a single cell array, assume that the
        % inner cell array is the argument; otherwise, assume that a single parameter list has
        % been given
        if iscell(pin_in) && isscalar(pin_in) && iscell(pin_in{1})

            if ~isempty(fun{1})
                pin = mfclass_plist(pin_in{1});
            elseif isempty(pin_in{1})
                pin = mfclass_plist();

            else
                error('HERBERT:pin_parse:invalid_argument', ...
                      'A function has not been given, but parameters have been provided for it');
            end
        else
            if ~isempty(fun{1})
                pin = mfclass_plist(pin_in);
            elseif isempty(pin_in)
                pin = mfclass_plist();
            else
                error('HERBERT:pin_parse:invalid_argument', ...
                      'A function has not been given, but parameters have been provided for it');
            end
        end

      otherwise

        % Multiple functions
        % If the argument is a cell array with the same size as the array of
        % function handles, then assume that a cell array of parameter lists
        % has been provided.
        % Otherwise assume that a single parameter list has been given.
        if iscell(pin_in) && isequal(size(pin_in), size(fun))
            pin = repmat(mfclass_plist(), size(fun));
            for i=1:numel(pin)

                if isempty(fun{i}) && ~isempty(pin_in{i})
                    error('HERBERT:pin_parse:invalid_argument', ...
                          'function %s has not been given, but parameters have been provided for it', ...
                          arraystr(size(fun), i));
                end

                if isempty(fun{i})
                    continue
                end

                pin(i) = mfclass_plist(pin_in{i});
            end

        elseif iscell(pin_in) && isscalar(pin_in) && iscell(pin_in{1})
            pin = repmat(mfclass_plist(pin_in{1}), size(fun));
            empty_fun = cellfun(@isempty, fun);
            if any(empty_fun, 'all')

                if ~isempty(pin_in{1})
                    error('HERBERT:pin_parse:invalid_argument', ...
                          'function %s has not been given, but parameters have been provided for it', ...
                          arraystr(size(fun), find(empty_fun, 1)));
                end

                pin(empty_fun) = mfclass_plist();
            end
        else
            pin = repmat(mfclass_plist(pin_in), size(fun));
            empty_fun = cellfun(@isempty, fun);

            if any(empty_fun, 'all')
                if ~isempty(pin_in(empty_fun))
                    error('HERBERT:pin_parse:invalid_argument', ...
                          'function %s has not been given, but parameters have been provided for it', ...
                          arraystr(size(fun), find(empty_fun, 1)));
                end

                pin(empty_fun) = mfclass_plist();
            end
        end
    end
else
    % Array of mfclass_plist
    if numel(fun)==0

        if ~isempty(pin_in)
            error('HERBERT:pin_parse:invalid_argument', ...
                  'There are no function handles or place holders, but parameters have been provided.');
        end

        % Only valid input is empty array
        pin = repmat(mfclass_plist(), size(fun));

    elseif numel(pin_in)==numel(fun)
        pin = reshape(pin_in, size(fun));

    elseif isscalar(pin_in)
        pin = repmat(pin_in, size(fun));

    else
        error('HERBERT:pin_parse:invalid_argument', ...
              'Number of elements in parameter list object array does not match the number of functions');
    end
end

% Get the number of parameters
np=zeros(size(fun));
for i=1:numel(fun)
    np(i)=pin(i).np;
end

end
