function varargout = subsref(this, index)
% A Comprehensive Guide to Object Oriented Programming in MATLAB
%   Chapter 9 example subsref
%   (c) 2004 Andy Register

% Generic method

switch index(1).type

    case '.'
        if isempty(this)
            varargout = cell(0);
        else
            varargout = cell(1, max(length(this(:)), nargout));
        end
        try
            [varargout{:}] = get(this, index);
        catch
            rethrow(lasterror);
        end

        if length(index) > 1
            if length(this(:)) == 1
                varargout = {subsref([varargout{:}], index(2:end))};
            else
                [err_id, err_msg] = array_reference_error(index(2).type);
                error(err_id, err_msg);
            end
        end

    case '()'
        this_subset = this(index(1).subs{:});
        if length(index) == 1
            varargout = {this_subset};
        else
            % trick subsref into returning more than 1 ans
            varargout = cell(size(this_subset));
            [varargout{:}] = subsref(this_subset, index(2:end));
        end

    case '{}'
        error(['??? ' class(this) ' object, is not a cell array']);

    otherwise
        error(['??? Unexpected index.type of ' index(1).type]);
end

if length(varargout) > 1 & nargout <= 1
    if iscellstr(varargout) || any([cellfun('isempty', varargout)])
        varargout = {varargout};
    else
        try
            varargout = {[varargout{:}]};
        catch
            varargout = {varargout};
        end
    end
end
