function rd = rundata_from_string(str)
% build rundata object from its string representation obrained earlier by
% serialize function

len = numel(str)/3;
sa = reshape(str,len,3);
iarr = uint8(str2num(sa));

rd = deserialize_(iarr);

