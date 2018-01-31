function perf_test_name = get_class_name_(stack)
% loops through dbgstack and finds topmost constructor to assighn the test
% suite name to it

perf_test_name ='Interactive';
for i = numel(stack):-1:1
    cl_names = split(stack(i).name,'.');
    if numel(cl_names) <2 % call from a function
        continue;
    end
    if strcmp(cl_names{1},cl_names{2}) % its a constructor
        perf_test_name  = cl_names{1};
        break
    end

end


