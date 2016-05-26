function c=source_1_test(arg)
%
%  Function to test herbert to mslcie synchronization
%
% $Revision$ ($Date$)
%

a=arg;
b=get(herbert_config,'use_mex_C');
c=a+b;
end