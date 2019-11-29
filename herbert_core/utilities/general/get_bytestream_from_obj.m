function  stream = get_bytestream_from_obj(anyData,varargin)
% wrapper around system getByteStreamFromArray function which
% converts any Matlab object into array of bytes. The stream then can be
% converted back into whole object by the reverse function: getArrayFromByteStream
%
% Usage:
%>>stream = get_bytestream_from_obj(anyData)
%          where anyData is an arbitrary object and stream is the array of
%          bytes with uint8 type
%
%If second function argument is provided, the routine tries to use mex file
%(used in testing/debugging situations)
%
%
% $Revision:: 833 ($Date:: 2019-10-24 20:46:09 +0100 (Thu, 24 Oct 2019) $)
%

if nargin>1
    stream = byte_stream(anyData,'Serialize');
else
    
    try
        stream= getByteStreamFromArray(anyData);
    catch
        stream = byte_stream(anyData,'Serialize');
    end
end