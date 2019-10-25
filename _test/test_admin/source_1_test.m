function c=source_1_test(arg)
%
%  Function to test herbert to mslcie synchronization
%
% $Revision:: 833 ($Date:: 2019-10-24 20:46:09 +0100 (Thu, 24 Oct 2019) $)
%

a=arg;
b=get(herbert_config,'use_mex_C');
c=a+b;
end