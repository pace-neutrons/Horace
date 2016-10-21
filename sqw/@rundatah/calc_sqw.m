function [w,grid_size,urange] = calc_sqw(obj,grid_size_in,urange_in,varargin)
% Generate single sqw file from given rundata class.
%
% Usage:
%>>[w,grid_size,urange] = rundata_obj.calc_sqw(grid_size_in,urange_in,varargin);
% or
%>>[w,grid_size,urange] = rundata_obj.calc_sqw(varargin);
%
% Where:
% rundata_obj -- fully defined rundata object
%
% grid_size_in   Scalar or [1x4] vector of grid dimensions in each direction
%                for sqw object to build from given rundata object.
%   urange_in    Range of data grid for output given as a [2x4] matrix:
%                [x1_lo,x2_lo,x3_lo,x4_lo;x1_hi,x2_hi,x3_hi,x4_hi]
%                If [] then uses the smallest hypercuboid that encloses the 
%                whole data range.
%                The ranges have to be provided in crystal cartezian
%                cooridnate system
% If the form without grid_size_in and urange_in is used, grid_size_in is
% assumed to be equal to [50,50,50,50] and urange_in = [].
%
% Optional inputs:
%
% '-cash_detectors' -- sting requesting to store calculated directions to
%                  each detector, defined for the instrument and use
%                  calculated values for each subsequent call to this
%                  method.
%                  Cashed values are shared between all existing rundata
%                  objects and recalculated if a subsequent rundata object
%                  has different detecotors.
%                  Should be used only when runnign number of subsequent
%                  calculations for rang of runfiles and if mex files are
%                  disabled. (mex files do not use cashed detectors
%                  positions)
%
% Outputs:
%   w               Output sqw object
%   grid_size       Actual size of grid used (size is unity along dimensions
%                  where there is zero range of the data points)
%   urange          Actual range of grid - the specified range if it was given,
%                  or the range of the data if not.
%
%
% $Revision$ ($Date$)
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
horace_info_level=config_store.instance().get_value('hor_config','log_level');

bigtic
% Read spe file and detector parameters
% -------------------------------------
% Masked detectors (i.e. containing NaN signal) are removed from data and detectors
if qspec_provided
    [data.S,data.ERR,data.en,efix,emode,alatt,angdeg,u,v,psi,omega,dpsi,gl,gs]=...
        obj.get_rundata(rundata_par{:});
    data.qspec = detdcn;
    det  = build_det_struct(1); % build fake detectors structure, consisting of
    det0 = build_det_struct(1); % one detector to satisfy the interface.
else
    [data.S,data.ERR,data.en,efix,emode,alatt,angdeg,u,v,psi,omega,dpsi,gl,gs,det]=...
        obj.get_rundata(rundata_par{:});
    
    % Note: algorithm updates only if not already read from disk
    % Get the list of all detectors, including the detectors corresponding to masked detectors
    det0 = get_rundata(obj,'det_par');
end
[data.filepath,data.filename]=get_source_fname(obj);
if ~exist('grid_size_in','var')
    grid_size_in = [50,50,50,50];
else
    if isempty(grid_size_in)
        grid_size_in = [50,50,50,50];
    else
        if size(grid_size_in) ~= [1,4]
            if size(grid_size_in) == [4,1]
                grid_size_in = grid_size_in';
            else
                error('RUNDATA:invalid_argument',...
                    'Grid size, if provided, should be 1x4 vector, containing number of bins in each of 3-q and one Energy transfer directions')
            end
        end
    end
end
if ~exist('urange_in','var')
    urange_in = [];
end

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
% into something different from non-transfromed object urange, so here we
% use native sqw object urange and account for input urange later.
if ~isempty(obj.transform_sqw_f_)
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