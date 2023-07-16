function [is, mess, name_a, name_b, namer, argi] = process_inputs_for_eq (...
    lhs_obj, rhs_obj, narg_out, names, varargin)
% The common part of eq operator children can use to process
% common eq or ne operator options and common comparison code,
% i.e. comparison for object type and shapes
%
% Input:
% ------
% lhs_obj  -- left hand side object or array of objects to
%             compare
% rhs_obj  -- right hand side object or array of objects to
%             compare
% narg_out -- number of output arguments requested; defines the
%             if non-equal result throws or returns message
% names    -- 2-element cellarray of the names of the objects
%             to be used in the output message should the object
%             fail the equality requirement.
%
% Optional:
% varargin -- list of optional parameters of comparison to
%             process, as accepted by equal_to_tol operation.
%             Note: the default is tolerance (relative and absolute)
%             of 1e-9 is acceptable
%
% Output:
% -------
% is       -- true if the objects precomparison is true and
%             false if it is not. Precomparison checks object
%             equality of the object types and the
% mess     -- empty if narg_out == 1 or message, describing the
%             reason why comparing objects are different.
% name_a   -- the name the lhs object to compare
% name_b   -- the name the rhs object to compare
% namer    -- a function used to produce names of the objects
%             to compare in case of array of objects

[is, mess, name_a, name_b, namer, argi] = process_inputs_for_eq_ (...
    lhs_obj, rhs_obj, narg_out, names, varargin{:});

end
