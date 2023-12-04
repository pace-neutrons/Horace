function img = build_combined_img_(axes_bl,proj,img_sources, ...
    job_disp,hor_log_level)
%BUILD_COMBINED_IMG_  Collect images from mutiple input sources,
% add them together and return image (DnD object) combined from multiple
% images.
%
% Its assumed that the imput image sources have been checked for
% compartibility before, so this routine expect all them being compartible.
%
% Inputs:
% axes_bl -- the axes_block instance common for all contributing images
% proj    -- aProjectionBase class, common for all contributiong images.
% img_sources
%         -- cellarray of objects containing partial images to combine
% job_disp
%         -- instance of JobDispatcher, used in parallel combine and having
%            initialized parallel cluster attached to it.
% Returns:
% img    -- the image (DnD object) build as combination of contributing
%           images
%
%
combine_in_parallel = ~isempty(job_disp);
%
img = DnDBase.dnd(axes_bl,proj);

% Now read in binning information
% ---------------------------------
% We did not read in the arrays s, e, npix from the files because if have a 50^4 grid then the size of the three
% arrays is is total 24*50^4 bytes = 150MB. Firstly, we cannot afford to read all of these arrays as it would
% require too much RAM (30GB if 200 spe files); also if we just want to check the consistency of the header information
% in the files first we do not want to spend lots of time reading and accumulating the s,e,npix arrays. We can do
% that now, as we have checked the consistency.
if hor_log_level>-1
    disp(' ')
    disp('Reading and accumulating binning information of input file(s)...')
end

if combine_in_parallel
    %TODO:  check config for appropriate ways of combining the tmp and what
    %to do with cluster
    comb_using = config_store.instance().get_value('hpc_config','combine_sqw_using');
    if strcmp(comb_using,'mpi_code') % keep cluster running for combining procedure
        keep_workers_running = true;
    else
        keep_workers_running = false;
    end
    [common_par,loop_par] = accumulate_headers_job.pack_job_pars(img_sources);
    %
    [outputs,n_failed,~,job_disp]=job_disp.restart_job(...
        'accumulate_headers_job',common_par,loop_par,true,keep_workers_running );
    n_workers = job_disp.cluster.n_workers;

    %
    if n_failed == 0
        s_accum = outputs{1}.s;
        e_accum = outputs{1}.e;
        npix_accum = outputs{1}.npix;
    else
        job_disp.display_fail_job_results(outputs,n_failed,n_workers, ...
            'HORACE:write_nsqw_to_sqw:runtime_error');
    end
else
    % read arrays and accumulate headers directly
    [s_accum,e_accum,npix_accum] = accumulate_headers_job.accumulate_headers(img_sources);
end
[s_accum,e_accum] = normalize_signal(s_accum,e_accum,npix_accum);
%
img.s=s_accum;
img.e=e_accum;
img.npix=uint64(npix_accum);

