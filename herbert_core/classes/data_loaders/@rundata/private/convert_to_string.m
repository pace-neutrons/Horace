function str= convert_to_string(run)
% convert rundata class to a plain string representation
% allowing later conversion back into the run
%
%
% $Revision:: 839 ($Date:: 2019-12-16 18:18:44 +0000 (Mon, 16 Dec 2019) $)
%
v = serialize_(run);
str_arr =num2str(v);
str = reshape(str_arr,1,numel(str_arr));;