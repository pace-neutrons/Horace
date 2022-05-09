function [pix_or_pix_range,det0,axes_bl]  = convert_rundata_to_pix_(obj,run_data,axes_bl)
% Transform instrument's signal obtained from measurements and stored in
% rundata into Crystal Cartesian coordinate system and return these data in
% the form of PixelData object.

%
% if axes_block is missing, caclulate only pix_range in this coordinate
% system.
%
if nargin == 2 % axes_block is missing and we are calculating only pix range
    axes_bl = [];
    calc_all_pixels = false;
else
    calc_all_pixels  = true;
    hor_log_level  = config_store.instance().get_value('herbert_config','log_level');
    if hor_log_level>-1
        bigtic;
    end
end

qspec = run_data.qpsecs_cache;
if isempty(qspec)
    qspec_provided = false;        
else
    qspec_provided = true;
end
if ~qspec_provided || isempty(run_data.S)
    % load signal, error and everything else to memory
    run_data= run_data.get_rundata('-this');
end
det0 = run_data.det_par;

if calc_all_pixels && ~qspec_provided
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
end

% caclulate pixels in standard form:
% -----------------
if qspec_provided 
    detdcn = [];
else% calculate detectors directions, which are always cached now.
    % And compared with the stored detectors each time, to recalculate if
    % not
    detdcn = calc_or_restore_detdcn_(det0);
    if calc_all_pixels
        detdcn = detdcn(:,non_masked);
    end
end

if calc_all_pixels
    [pix_range,pix] = run_data.calc_projections(detdcn);
    if hor_log_level>-1
        bigtoc('Time to convert from spe to sqw data:',hor_log_level)
        disp(' ')
    end
    % returning pixels
    pix_or_pix_range = pix;

    if any(isinf(axes_bl.img_range(:)))
        pix_range = range_add_border(pix_range,obj.tol_);
        undef = isinf(axes_bl.img_range);
        axes_bl.img_range(undef) =pix_range(undef);
    end
else % pix are not calculated and we calculate range only
    pix_range = run_data.calc_projections(detdcn);
    % returning pixels range
    pix_or_pix_range = pix_range;
end
