function [obj,nbytes] = deserialize_(byte_array,pos)
% recover the object from the serialized into array of bytes
% Inputs:
% byte_array -- 1D array of bytes, obtained by some
%               serialization operation
% pos        -- the location of the initial position of
%               the sequence to deserialize in the input byte
%               array. If absent, assumed to be 1;
% Returns:
% obj        -- deserialized object
% nbytes     -- the number of bytes the object occupies in the
%               input array of bytes

[ser,nbytes] = deserialise(byte_array,pos);
obj = serializable.from_struct(ser);