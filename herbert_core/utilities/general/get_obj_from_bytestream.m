function  obj = get_obj_from_bytestream(bytestream,varargin)
% wrapper around system getArrayFromByteStream function which
% recovers a Matlab object from array of bytes, previously obtained using
% getByteStreamFromArray function.
%
% Usage:
%>>obj= get_obj_from_bytestream(bytestream)
%          where bytestream is an array of bytes and the object is
%          recovered from this array
%
%If second function argument is provided, the routine tries to use mex file
%(used in testing/debugging situations)
%
%
% $Revision:: 838 ($Date:: 2019-12-05 14:56:03 +0000 (Thu, 5 Dec 2019) $)
%

if nargin>1
    obj = byte_stream(bytestream,'Deserialize');
else
    try
        obj= getArrayFromByteStream(bytestream);
    catch
        obj = byte_stream(bytestream,'Deserialize');
    end
endd