function str= convert_to_string(run)
% convert rundata class to a plain string representation
% allowing later conversion back into the run
%
%
% $Revision: 371 $ ($Date: 2014-04-04 17:34:46 +0100 (Fri, 04 Apr 2014) $)
%
v = serialize_(run);
str_arr =num2str(v);
str = reshape(str_arr,1,numel(str_arr));