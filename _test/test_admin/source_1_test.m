function c=source_1_test(arg)
%
%  Function to test herbert to mslcie synchronization
%
% $Revision:: 832 ($Date:: 2019-08-11 23:25:59 +0100 (Sun, 11 Aug 2019) $)
%

a=arg;
b=get(herbert_config,'use_mex_C');
c=a+b;
end