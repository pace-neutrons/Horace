function byte_array = serialize (obj)
% Serialize an object or array of objects
%
%   >> serialized_data = serialize (obj)
%
% Input:
% ------
%   obj         Object or object array to be serialized
%
% Output:
% -------
%   byte_array  Serialized data.
%               The input is first converted to a structure using the method
%               to_struct before calling the utility function serialize.

S = to_struct (obj);
byte_array = serialize (S);

end
