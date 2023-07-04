function [nbytes, S] = serial_size (obj)
% Return the size of the serialized object
%
%   >> nbytes = serial_size (obj)
%   >> [nbytes, S] = serial_size (obj)
%
% Overload with a custom method to avoid conversion to a structure, which may be
% computationally expensive, if all that is required is the serialized size.
% The algorithm used by this method explicitly converts to the custom structure
% used by the serializable class (hence the optional return of S). If
% overloaded, then nbytes must be identical to what is created by this method.
%
% Input:
% ------
%   obj     Object or object array to be serialized
%
% Output:
% -------
%   nbytes  Number of bytes that will be required by the structure S (below) 
%           from which when serialized
%
%   S       Structure with information required to restore
%           the object using the "from_struct" method.

S = to_struct (obj);
nbytes = serialise_size (S);   % calls utility function, not this method
% adds 1 as first byte of the serializable class would be serializable
% class ID

end
