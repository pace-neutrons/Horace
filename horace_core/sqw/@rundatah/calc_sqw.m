function [w,grid_size,pix_range,detdcn] ...
    = calc_sqw(obj,grid_size_in,pix_db_range,varargin)
% Generate single sqw file from given rundata class.
%
% Usage:
%>>[w,grid_size,pix_range,detdcn] = rundata_obj.calc_sqw(grid_size_in,pix_db_range,varargin);
% or
%>>[w,grid_size,pix_range,detdcn] = rundata_obj.calc_sqw(varargin);
%
% Where:
% rundata_obj -- fully defined rundata object
%
% grid_size_in   Scalar or [1x4] vector of grid dimensions in each direction
%                for sqw object to build from given rundata object.
% pix_db_range   Range of data grid for output given as a [2x4] matrix:
%                [x1_lo,x2_lo,x3_lo,x4_lo;x1_hi,x2_hi,x3_hi,x4_hi]
%                If [] then uses the smallest hypercuboid that encloses the
%                whole data range.
%                The ranges have to be provided in crystal Cartesian
%                coordinate system, A^-1 scale
% If the form without grid_size_in and pix_range_in is used, grid_size_in is
% assumed to be equal to [50,50,50,50] and pix_range_in = [].
%
% Optional inputs:
%
% -qspec           if this option is provided, calculate q-dE vectors positions
%                  and store it in qspec_cache array or use contents of
%                  qspec_cache array provided instead of calculating
%                  q-dE vector values from detectors positions
%
% Outputs:
% w               Output sqw object
% grid_size       Actual size of grid used (size is unity along dimensions
%                 where there is zero range of the data points)
% pix_range      Actual range of pixels, contributed in the image.
%                the specified range if it was given,
%                or the range of the data if not.
%  detdcn        [3 x ndet] array of unit vectors, poinitng to the detector's
%                positions in the spectrometer coordinate system (X-axis
%                along the beam direction). ndet -- number of detectors
%                Can be later assigned to the next rundata object
%                property "detdcn_cache" to accelerate calculations. (not
%                fully implemented and currently workis with Matlab code
%                only)
% pix_range_nontransf -- if no transformation is provided, the value is
%                equal to pix_range. If there is a transformation, the
%                value describes the pixel range before the transformation
%
if ~exist('grid_size_in','var')
    grid_size_in = [];
end
grid_size = check_and_set_gridsize(grid_size_in);
%
if ~exist('pix_db_range','var')
    pix_db_range = [];
end

keys_recognized = {'-qspec'};
[ok,mess,cache_q_vectors] = parse_char_options(varargin,keys_recognized);
if ~ok
    error('HORACE:rundatah:invalid_arguments',['calc_pix_range: ',mess])
end
qspec_provided = false;
if cache_q_vectors
    if ~isempty(obj.qpsecs_cache)
        qspec_provided = true;
    end
else
    obj.qpsecs_cache = [];
end

hor_log_level=config_store.instance().get_value('herbert_config','log_level');

bigtic
% Read spe file and detector parameters
% -------------------------------------
if ~qspec_provided || isempty(obj.S)
    % load signal, error and everything else to memory
    obj= obj.get_rundata('-this');
end
det0 = obj.det_par;
% Masked detectors (i.e. containing NaN signal) are removed from data and detectors
[ignore_nan,ignore_inf] = config_store.instance().get_value('hor_config','ignore_nan','ignore_inf');
[obj.S,obj.ERR,obj.det_par,non_masked]  = obj.rm_masked(ignore_nan,ignore_inf);
if isempty(obj.S) || isempty(obj.ERR)
    error('HORACE:rundatah:invalid_arguments',...
        'File %s contains only masked detectors', obj.data_file_name);
end

if hor_log_level>-1
    bigtoc('Time to read spe and detector data:')
    disp(' ')
end


% Create sqw object
% -----------------
bigtic
if ~cache_q_vectors % detectors are always cached now. And compared with the 
    % stored detectors each time
    detdcn = calc_or_restore_detdcn_(det0);
    detdcn = detdcn(:,non_masked);
end
%
[w, grid_size, pix_range]=obj.calc_sqw_(detdcn, grid_size, pix_db_range);


if hor_log_level>-1
    bigtoc('Time to convert from spe to sqw data:',hor_log_level)
    disp(' ')
end

if ~isempty(obj.transform_sqw_f_)
    % we should assume that transformation maintains correct data pix_range
    % and correct sqw structure, though this pix_range and grid_size-s do not
    % always coincide with initial range and sizes
    w = obj.transform_sqw_f_(w);
    pix_range = w.data.pix.pix_range;
    grid_size = size(w.data.s);
end

function grid_size = check_and_set_gridsize(grid_size_in)
if isempty(grid_size_in)
    grid_size = [50,50,50,50];
else
    grid_size = grid_size_in(:)';

    if ~all(size(grid_size) == [1,4]) || any(grid_size < 1)
        error('HORACE:rundatah:invalid_argument',...
            'Grid size, if provided, should be 1x4 vector, containing number of bins in each of 3-q and one Energy transfer directions')
    end

end


