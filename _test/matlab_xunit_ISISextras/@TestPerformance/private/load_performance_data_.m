function perf_data = load_performance_data_(obj)
% Load performance data
%
try
    perf_data = xml_read(obj.test_results_file);
catch
    perf_data = struct(obj.perf_suite_name_,'');
end

