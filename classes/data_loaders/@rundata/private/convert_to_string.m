function str= convert_to_string(run)
% convert rundata class to a plain string representation
% allowing later conversion back into the run
%
%
% $Revision:: 833 ($Date:: 2019-10-24 20:46:09 +0100 (Thu, 24 Oct 2019) $)
%
v = serialize_(run);
str_arr =num2str(v);
str = reshape(str_arr,1,numel(str_arr));