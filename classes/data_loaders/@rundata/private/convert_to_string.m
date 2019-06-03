function str= convert_to_string(run)
% convert rundata class to a plain string representation
% allowing later conversion back into the run
%
%
% $Revision:: 831 ($Date:: 2019-06-03 09:47:08 +0100 (Mon, 3 Jun 2019) $)
%
v = serialize_(run);
str_arr =num2str(v);
str = reshape(str_arr,1,numel(str_arr));