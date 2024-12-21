function [is,mess] = eq_to_tol_type_equal(obj1,obj2,name_a,name_b)
%EQ_TO_TOL_TYPE_EQUAL Helper function used by equal_to_tol to validate
% if type of two objects is equal for purposes of equal_to_tol comparison
% procedure
%
% Provided to be overloadable by some special classes
%
% Inputs:
% obj1    -- object 1 to compare
% obj2    -- object 2 to compare
%
% Optional:
% name_a  -- the name of first object in comparison
% name_b  -- the name of second object in comparison
%            These names become part of information message in case if
%            objects types are different
%
% Returns:
% is      -- true if objects types are equal and false if not.
% mess    -- the message providing additinal information about object types
%            it the types are different
%
is   = true;
mess = '';

% Check that corresponding objects have the same type
if isempty(obj1)&&isempty(obj2) % empty objects are the same type regardless of Matlab type
    return;
end

if nargin<3
    name_a = 'input_1';
end
if nargin<4
    name_b = 'input_2';
end
if isa(obj1,'function_handle')
    if isa(obj2,'function_handle')
        return;
    else
        is = false;
        mess = sprintf('Objects have different types. "%s" is a "function_handle" and "%s" class: "%s"', ...
            name_a,name_b,class(obj2));
    end
end
if ~isa(obj2,class(obj1))
    if isnumeric(obj1) && isnumeric(obj2)
        is = ismember({class(obj1),class(obj2)},{'single','double','int32','uint32','int64','uint64'});
        if all(is) % alow numerical comparion of different types of numerical objects
            return;
        end
    elseif istext(obj1) && istext(obj2)
        % allow strings and character arrays to be equal.
        return
    end
    is = false;
    mess = sprintf('Objects have different types. "%s" has class: "%s" and "%s" class: "%s"', ...
        name_a,class(obj1), name_b,class(obj2));
end
end