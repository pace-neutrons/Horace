function fn = build_default_perf_test_fname_(class_constructor_full_path_and_name)
% build default performance test file name
%

[fp,fn] = fileparts(class_constructor_full_path_and_name);
if isempty(fp)
    fp = fileparts(fileparts(mfilename));
end
if isempty(fn)
    fn = 'TestPerformance';
end
fn = fullfile(fp,[fn,'_PerfRez.xml']);
