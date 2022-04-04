function [pix,det0,axes_bl]  = convert_rundata_to_pix_(obj,run_data,axes_bl)
% Transform instrument signal obtained from instrument into Crystal
% Cartesian coordinate system.
%
hor_log_level  = config_store.instance().get_value('herbert_config','log_level');
if hor_log_level>-1
    bigtic;
end
qspec = run_data.qpsecs_cache;
if isempty(qspec) || isempty(run_data.S)
    % load signal, error and everything else to memory
    run_data= run_data.get_rundata('-this');
end
det0 = run_data.det_par;
% Masked detectors (i.e. containing NaN signal) are removed from data and detectors
[ignore_nan,ignore_inf] = config_store.instance().get_value('hor_config','ignore_nan','ignore_inf');
[run_data.S,run_data.ERR,run_data.det_par,non_masked]  = run_data.rm_masked(ignore_nan,ignore_inf);
if isempty(run_data.S) || isempty(run_data.ERR)
    error('HORACE:instr_proj:invalid_arguments',...
        'File %s contains only masked detectors', obj.data_file_name);
end

if hor_log_level>-1
    bigtoc('Time to read spe and detector data:')
    disp(' ')
    bigtic
end

% caclulate pixels in standard form:
% -----------------
if isempty(qspec) % calculate detectors directions, which are always cached now.
    % And compared with the stored detectors each time, to recalculate if
    % not
    detdcn = calc_or_restore_detdcn_(det0);
    detdcn = detdcn(:,non_masked);
end
[pix_range,~,pix] = run_data.calc_projections(detdcn);

if hor_log_level>-1
    bigtoc('Time to convert from spe to sqw data:',hor_log_level)
    disp(' ')
end
if any(any(isinf(axes_bl.img_range)))
    pix_range = range_add_border(pix_range,obj.tol_);
    undef = isinf(axes_bl.img_range);
    axes_bl.img_range(undef) =pix_range(undef);
end
