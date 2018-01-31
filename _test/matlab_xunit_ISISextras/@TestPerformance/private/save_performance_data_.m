function perf_data_ = save_performance_data_(obj)
% Load performance data
%
try
    root_name = obj.root_name_;
    perf_data_ = obj.perf_data;
    xml_write(obj.test_results_file,perf_data_,root_name);
catch
    warning('TEST_PERFORMANCE:runtime_error','Can not write peformance results to file %s',obj.test_results_file);
end

