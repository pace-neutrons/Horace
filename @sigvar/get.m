function varargout = get(this, index)
% Get a named field from an object, or a structure with all
% fields.
%
%   >> val = get(object)           % returns structure of object contents 
%   >> val = get(object, 'field')  % returns named field, or an array of values
%                                  % if input is an array

% Generic method

% Original author: T.G.Perring
%
% $Revision: 101 $ ($Date: 2007-01-25 09:10:34 +0000 (Thu, 25 Jan 2007) $)

% Edited from:
% A Comprehensive Guide to Object Oriented Programming in MATLAB
%   Chapter 9 example get
%   (c) 2004 Andy Register

% one argument, display info and return
if nargin == 1
    if nargout == 0
        disp(struct(this(1)));
    else
        varargout = cell(1,max([1, nargout]));
        varargout{1} = struct(this(1));
    end
    return;
end

% if index is a string, we will allow special access
called_by_name = ischar(index);

% the set switch below needs a substruct
if called_by_name
    index = substruct('.', index);
end

% public-member-variable section
try
    if isempty(this)
        varargout = {};
    else
        varargout = {this.(index(1).subs)};
    end
catch
    error(['Reference to non-existent field ' index(1).subs '.']);
end

if length(varargout) > 1 && nargout <= 1
    if iscellstr(varargout) || any(cellfun('isempty', varargout))
        varargout = {varargout};
    else
        try
            varargout = {[varargout{:}]};
        catch
            varargout = {varargout};
        end
    end
end
