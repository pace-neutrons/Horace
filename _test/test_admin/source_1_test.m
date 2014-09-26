function c=source_1_test(arg)
%
%  Function to test herbert to mslcie synchronization
%
% $Revision: 268 $ ($Date: 2014-03-13 14:11:31 +0000 (Thu, 13 Mar 2014) $)
%

a=arg;
b=get(herbert_config,'use_mex_C');
c=a+b;
end