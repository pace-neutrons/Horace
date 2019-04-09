function c=source_1_test(arg)
%
%  Function to test herbert to mslcie synchronization
%
% $Revision:: 830 ($Date:: 2019-04-09 10:03:50 +0100 (Tue, 9 Apr 2019) $)
%

a=arg;
b=get(herbert_config,'use_mex_C');
c=a+b;
end