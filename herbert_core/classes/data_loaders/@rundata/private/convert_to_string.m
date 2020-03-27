function str= convert_to_string(run)
% convert rundata class to a plain string representation
% allowing later conversion back into the run
%
%
% $Revision:: 840 ($Date:: 2020-02-10 16:05:56 +0000 (Mon, 10 Feb 2020) $)
%
v = serialize_(run);
str_arr =num2str(v);
str = reshape(str_arr,1,numel(str_arr));
