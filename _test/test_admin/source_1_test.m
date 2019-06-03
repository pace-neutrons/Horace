function c=source_1_test(arg)
%
%  Function to test herbert to mslcie synchronization
%
% $Revision:: 831 ($Date:: 2019-06-03 09:47:08 +0100 (Mon, 3 Jun 2019) $)
%

a=arg;
b=get(herbert_config,'use_mex_C');
c=a+b;
end