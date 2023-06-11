function [obj,nbytes] = deserialize_ (byte_array, pos)
% %*******************************************************************************
% %*******************************************************************************
% %
% %   CAN DELETE THIS NOW, AS CODE PUT IN METHOD DESERIALIZE
% %
% %*******************************************************************************
% %*******************************************************************************
% % Recover the object or object array from the serialized byte_array
% %
% %   >> [obj, nbytes] = deserialize_ (byte_array, pos)
% %
% % Input:
% % ------
% %   byte_array  One-dimensional array of bytes
% %   pos         Location of the initial position within byte_array of the
% %               sequence to deserialize on the assumption that the byte stream
% %               from that point was created using the method serialize. One
% %               object (or object array) will be deserialized.
% %
% % Output:
% % -------
% %   obj         Deserialized object or object array
% %   nbytes      The number of bytes the object or object array occupies in the
% %               input array of bytes
% 
% [S, nbytes] = deserialise (byte_array, pos);
% obj = serializable.from_struct (S);
% 
% end
