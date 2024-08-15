function [perf_res,perf_res1]=gen_sqw_task_performance(obj,field_names_map,combine_only)
% test to check the performance of gen_sqw task

test_fld_names = field_names_map('gen_sqw');
% delete existing tmp files as gen_sqw keeps existing in
% 'tmp_only' mode
%obj.delete_tmp_files();

[psi,efix,alatt,angdeg,u,v,omega,dpsi,gl,gs]=obj.gen_sqw_parameters();
emode=1;%direct geometry

%profile on
% generate
if combine_only
    tmp_files = obj.test_source_files_list_;
    for i=1:numel(tmp_files)
        [fp,fn] = fileparts(tmp_files{i});
        tmp_files{i}= fullfile(fp,[fn,'.tmp']);
    end
    jd = [];
else
    ts = tic();
    [tmp_files,~,~,jd]=gen_sqw (obj.test_source_files_list_,'',...
        obj.sqw_file, efix, ...
        emode, alatt, angdeg,u, v, psi, omega, dpsi, gl, gs,...
        'replicate','tmp_only');
    perf_res1=obj.assertPerformance(ts,test_fld_names{1},...
        'all tmp files generation');
    % combine
end
ts = tic();
write_nsqw_to_sqw (tmp_files, obj.sqw_file,'-allow_equal_headers','-keep_runid',jd);
perf_res=obj.assertPerformance(ts,test_fld_names{2},...
    'calc headers and combine all tmp files');
%profile off
%profile viewer

