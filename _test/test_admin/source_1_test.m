function c=source_1_test(arg)
%
%  Function to test herbert to mslcie synchronization
%
% $Revision:: 830 ($Date:: 2019-04-08 16:16:02 +0100 (Mon, 8 Apr 2019) $)
%

a=arg;
b=get(herbert_config,'use_mex_C');
c=a+b;
end