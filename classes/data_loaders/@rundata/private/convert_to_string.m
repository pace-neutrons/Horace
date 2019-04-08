function str= convert_to_string(run)
% convert rundata class to a plain string representation
% allowing later conversion back into the run
%
%
% $Revision:: 830 ($Date:: 2019-04-08 17:54:30 +0100 (Mon, 8 Apr 2019) $)
%
v = serialize_(run);
str_arr =num2str(v);
str = reshape(str_arr,1,numel(str_arr));