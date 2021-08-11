function perf_val=combine_task_performance(obj,varargin)
% Test the speed of tmp file combine operations only.
%
% tmp files should to be available so the method can be
% deployed after test_gensqw_performance method has been run
% with hor_config class delete_tmp option set to false. In this
% case tmp files created by gen_sqw method are kept and this
% method will test combine operations only.
%
% if tmp files are not available, the method generates them,
% which may take significant time (not included in the combine
% performance evaluations)
%
% Usage:
% tob.combine_performance_test([n_workers],[addinfo],['-keep_tmp'])
% where:
% n_workers, if present, specify the number of parallel
%            workers to run the test routines with.
% addinfo   if present n_workers have to be present too. (set it
%            to 0
%
% As this test method violates unit test agreement, demanding
% test method independence on each other, it does not start
% from the name test to avoid running it by automated test
% suites.
[ok,mess,keep_tmp,argi] = parse_char_options(varargin,{'-keep_tmp'});
if ~ok
    error('test_SQW_GENCUT:invalid_argument',mess);
end
if numel(argi) >= 0
    n_workers = 0;
else
    n_workers = argi{1};
end
if numel(argi)>1
    addinfo = argi{2};
else
    addinfo = '';
end
[clob_wk,hpc] = check_and_set_workers_(obj,n_workers);


wk_dir = obj.working_dir;
spe_files = obj.test_source_files_list_;
tmp_files = cellfun(@(fn)(replace_fext(wk_dir,fn)),spe_files,'UniformOutput',false);

% check all tmp files were generated
f_exist = cellfun(@(fn)(exist(fn,'file')==2),tmp_files,'UniformOutput',true);
if ~all(f_exist)
    warning('Some tmp files necessary to run the test do not exist. Generating these files which will take some time');
    % set up the exactly the same parameters as defined below
    % in test_gensqw_performance method.
    [psi,efix,alatt,angdeg,u,v,omega,dpsi,gl,gs]= obj.gen_sqw_parameters();
    
    gen_sqw (spe_files,'','dummy_sqw', efix, emode, ...
        alatt, angdeg,u, v, psi, omega, dpsi, gl, gs,...
        'replicate','tmp_only');
end

combine_method = obj.combine_method_name(addinfo);

obj.add_to_files_cleanList(obj.sqw_file)
test_name = ['combine_tmp_using_',combine_method];

ts = tic();
write_nsqw_to_sqw(tmp_files,obj.sqw_file);
%

perf_val=obj.assertPerformance(ts,...
    test_name,...
    'performance of the tmp-files combine procedure');

% spurious check to ensure the cleanup object is not deleted
% before the end of the test
assertTrue(isa(clob_wk,'onCleanup'))

if ~keep_tmp
    obj.delete_files(tmp_files);
end

function fn = replace_fext(fp,fn)
[~,fn] = fileparts(fn);
fn = fullfile(fp,[fn,'.tmp']);

