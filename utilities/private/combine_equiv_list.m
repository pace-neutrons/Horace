function combine_equiv_list(data_source,proj,pos,step,erange,outfile,zonelist)
%
% Called by combine_equivalent_zones, combine_equiv_keyword and
% combine_equiv_basic
%
% RAE 30/3/2010

%This is the function we call when we actually want to do the combination
%of a specified list of symmetrically equivalent points

%First we must work out the ranges for each of the zones we're interested
%in. Package these up as another cell array which is n-by-3, where n is the
%number of equivalent zones.
if ~(numel(step)==3 || numel(step)==1)
    error('COMBINE_EQUIV_LIST:invalid_argument','step variable should have 1 or 3 components')
end

if isa(step,'qe_range')
    if numel(step)==1 % if qe_range is the same for all q-directions, triple it
        step=[step,step,step];
    end
else % list of cut ranges devined by step sizes provided
    if numel(step)==1  % make 3 equivalent qe_ranges classes
        step=[qe_range(step),qe_range(step),qe_range(step)];
    else % convert step in every direction into default qe_range class
        step=[qe_range(step(1)),qe_range(step(2)),qe_range(step(3))];
    end
end
%First we work out which element of zonelist corresponds to pos:
ind = -1;
for i=1:numel(zonelist)
    if isequal(zonelist{i},pos)
        ind=i;
        break;
    end
end
% extend zone list to the primary zone if it is not there yet
if ind == -1
    zonelist{end+1} = pos;
    %ind = numel(zonelist);
end


% define ranges for each zone to combine
range=cell(numel(zonelist),1);
% for tagging parallel jobs results
zoneid = cell(numel(zonelist),1);
for i=1:numel(zonelist)
    step(1).center = zonelist{i}(1);
    step(2).center = zonelist{i}(2);
    step(3).center = zonelist{i}(3);
    range{i}=[step(1),step(2),step(3),qe_range(erange(1),erange(2),erange(3))];
    zoneid{i}= i;
end

%Get directory in which the data live. This is where we will save temporary
%files.
[sourcedir,source_name]=fileparts(data_source);
% add these files to cleanup to remove them in case of errors or at the end
% of calculations:

%==========================================================================
%First create all of the 4-dimensional cuts from the data that we need. We
%will save them to temporary files with silly names, which must be deleted
%when this function has finished running.

disp('');
disp('----------------------------------------------------------------');
disp('                    Starting symmetrisation                     ');
disp('----------------------------------------------------------------');
disp('');
disp('Taking cuts from equivalent zones, converting coordinats        ');
disp(' and saving results to temporary files                          ');
disp('');
disp('----------------------------------------------------------------');
disp('');

%Note -  we have to make a check here to ensure that we do not already have
%some files called horacetempsyminternal... otherwise we could end up reading the
%wrong data... delete any pre-existing files of this name.

%Suppress output messages from Horace, otherwise the screen is flooded with
%lots of useless info...
% Turn off horace_info output, but save for automatic cleanup on exit or cntl-C (TGP 30/11/13)
%info_level = get(hor_config,'horace_info_level');
%cleanup_obj=onCleanup(@()set(hor_config,'horace_info_level',info_level));
%set(hor_config,'horace_info_level',-1);
[outdir,outfile] = fileparts(outfile);
if isempty(outdir)
    outdir = sourcedir;
end
outfile = fullfile(outdir,[outfile,'.sqw']);

% function to combine all parameters into single structure, suitable for
% serialization

[use_separate_matlab,num_matlab_sessions]=get(hor_config,...
    'accum_in_separate_process','accumulating_process_num');
% define function to combine job parameters into list of structures,
% suitable for serialization
job_par_fun = @(id,x,y)(combine_equivalent_zones_job.param_f(...
    id,x,y(1),y(2),y(3),y(4),proj,pos,data_source,outdir));

%Create new temporary files for all of the required zones. If there are no
%data in the specified zone we must be able to continue without getting an
%error:
zone_files =cell(numel(zonelist),1);
if use_separate_matlab
    % combine job parameters into list of structures,
    % suitable for serialization
    
    job_par = cellfun(job_par_fun,zoneid,zonelist',range);
    %
    %----------------------------------------------------------------------
    n_workers = num_matlab_sessions;
    if numel(job_par)<n_workers;
        n_workers = numel(job_par);
    end
    jm = JobDispatcher(source_name);
    [n_failed,outputs,job_distr_by_id] = ...
        jm.send_jobs('combine_equivalent_zones_job',job_par,n_workers);
    
    zone_files = analyze_and_combine_job_outputs(n_failed,outputs,...
        job_distr_by_id,job_par);
    %----------------------------------------------------------------------
else% Go serial.
    n_zones = numel(zonelist);
    for i=1:n_zones 
        % combine all inputs, necessary to convert coordinates of one zone
        % into the coordinates of other zone into signle compact structure;
        params  = job_par_fun(zoneid{i},zonelist{i},range{i});
        params.n_zone = i;
        params.n_tot_zones = n_zones;
        
        % move coordunates of current zone into specified coordinates
        zone_files{i} = move_zone1_to_zone0(params);
    end
end
% transfrom list of subfiles generated for each zone into 1-level celarray
% of file names
zone_fnames_list = flatten_cell_array(zone_files);

    function clear_tmp_file(name)
        if exist(name,'file')==2
            delete(name);
        end
    end
%Generate file names for each transformed zone

for i=1:numel(zone_fnames_list)
    zone_fnames_list{i} = fullfile(outdir,zone_fnames_list{i});
end
clobj1 = onCleanup(@()cellfun(@(fn)clear_tmp_file(fn),zone_fnames_list));
%==================================

%We need to work out how each of the Brillouin zones in zonelist relate to
%the pos argument. This will then tell us how we must transform the
%co-ordinates in the pix arrays.
disp('');
disp('Combining data on disk');
disp('');
disp('----------------------------------------------------------------');
disp('');

%Finally save the correct output to disk:
an_sqw = sqw();
write_nsqw_to_sqw (an_sqw, zone_fnames_list, outfile,'allow_equal_headers');

%if nargout>0
%    wout = read_sqw(outfile);
%    varargout{1}=wout;
%end

disp('');
disp('----------------------------------------------------------------');
disp('                    Symmetrisation finished                     ');
disp('----------------------------------------------------------------');
disp('');
end

function  zone_files = analyze_and_combine_job_outputs(n_failed,outputs,...
    job_distr_by_id,job_par)

n_workers = numel(outputs);
if n_failed>0 % Try to recalculate failed parallel jobs serially
    warning('COMBINE_ZONES:separate_process_combining',' %d out of %d jobs to generate tmp files reported failure',...
        n_failed,n_workers);
    
    if isempty(outputs)
        outputs = cell(n_workers,1);
        not_failed= false(n_workers,1);
    else
        not_failed = cellfun(@(x)isstruct(x),outputs);
    end
    % go over outputs and calculate outputs which are failed
    % serially
    for i=1:numel(outputs)
        if not_failed(i)
            continue;
        end
        fail_par_num = job_distr_by_id{i};
        z_files = cell(numel(fail_par_num),1);
        for ii = 1:numel(fail_par_num)
            ind = fail_par_num{ii};
            z_files{ii} = move_zone1_to_zone0(job_par(ind ));
        end
        n_failed=n_failed-1;
        outputs{i} = struct('zone_id',i,...
            'zone_files',z_files);
    end
end
% all failed

if n_failed == n_workers
    error('COMBINE_ZONES:separate_process_combining',[' All parallel jobs failed.'...
        'Try to run the combining on main Matlab session']);
else
    zone_files = cell(numel(outputs),1);
    for i=1:numel(outputs)
        zone_files{i} = outputs{i}.zone_files;
    end
end
end