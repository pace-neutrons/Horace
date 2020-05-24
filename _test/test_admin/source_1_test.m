function c=source_1_test(arg)
%
%  Function to test herbert to mslcie synchronization

a=arg;
b=get(herbert_config,'use_mex');
c=a+b;
end