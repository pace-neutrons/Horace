function [w,grid_size,urange] = calc_sqw(obj,grid_size_in,urange_in,varargin)
% generate sqw file from a single rundata file
%
%
%
%
% $Revision: 877 $ ($Date: 2014-06-10 12:35:28 +0100 (Tue, 10 Jun 2014) $)
%
keys_recognized = {'-cash_detectors'};
[ok,mess,cash_detectors,params] = parse_char_options(varargin,keys_recognized);
if ~ok
    error('RUNDATAH:invalid_arguments',['calc_urange: ',mess])
end
qspec_provided  = false;
if ~isempty(params) && strcmpi(params{1},'-qspec')
    detdcn = params{2};
    qspec_provided = true;
    rundata_par = {'S','ERR','en','efix','emode','alatt','angdeg','u','v',...
        'psi','omega','dpsi','gl','gs','-rad'};
else
    rundata_par = {'S','ERR','en','efix','emode','alatt','angdeg','u','v',...
        'psi','omega','dpsi','gl','gs','det_par','-rad','-nonan'};
end
horace_info_level=get(hor_config,'horace_info_level');

bigtic
% Read spe file and detector parameters
% -------------------------------------
% Masked detectors (i.e. containing NaN signal) are removed from data and detectors
if qspec_provided
    [data.S,data.ERR,data.en,efix,emode,alatt,angdeg,u,v,psi,omega,dpsi,gl,gs]=...
        obj.get_rundata(rundata_par{:});
    data.qspec = detdcn;
    det  = build_det_struct(1);
    det0 = build_det_struct(1);
else
    [data.S,data.ERR,data.en,efix,emode,alatt,angdeg,u,v,psi,omega,dpsi,gl,gs,det]=...
        obj.get_rundata(rundata_par{:});
    
    % Note: algorithm updates only if not already read from disk
    % Get the list of all detectors, including the detectors corresponding to masked detectors
    det0 = get_rundata(obj,'det_par');
end
[data.filepath,data.filename]=get_source_fname(obj);



if horace_info_level>-1
    bigtoc('Time to read spe and detector data:')
    disp(' ')
end


% Create sqw object
% -----------------
bigtic
if ~qspec_provided
    if cash_detectors
        detdcn = calc_or_restore_detdcn_(det);
    else
        detdcn = [];
    end
end
instrument = obj.instrument;
sample     = obj.sample;
%
% if transformation is provided, it will recalculate urange, and probably
% into something different from non-transfromed object urange.
if ~isempty(urange_in) && ~isempty(obj.transform_sqw_f_)
    urange_sqw = [];
else
    urange_sqw = urange_in;
end

[w, grid_size, urange]=calc_sqw_(efix, emode, alatt, angdeg, u, v, psi,...
    omega, dpsi, gl, gs, data, det, detdcn, det0, grid_size_in, urange_sqw,...
    instrument, sample);


if horace_info_level>-1
    bigtoc('Time to convert from spe to sqw data:',horace_info_level)
    disp(' ')
end

if ~isempty(obj.transform_sqw_f_)
    % we should assume that transformation maintains correct data urange
    % and correct sqw structure, though this urange and grid_size-s do not
    % always coincide with initial range and sizes
    w = obj.transform_sqw_f_(w);
    urange = w.data.urange;
    grid_size = size(w.data.s);
    if ~isempty(urange_in) % expand ranges to include urange_in
        urange = [min([urange_in(1,:),urange(1,:)]);max([urange_in(2,:),urange(2,:)])];
    end
end