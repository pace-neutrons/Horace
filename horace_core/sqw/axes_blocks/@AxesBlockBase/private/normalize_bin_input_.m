function [npix,s,e,pix_cand,unique_runid,use_mex]=...
    normalize_bin_input_(obj,force_3Dbinning,pix_coord,mode_to_bin,varargin)
% verify inputs of the bin_pixels function and convert various
% forms of the inputs of this function into a common form, where the missing
% inputs are presented as empty outputs or zero-values arrays of the
% appropriate size
%
% Inputs:
% ------------
% force_3Dbinning -- if true, always neglect energy dimension in the
%              binning array
%
% pix_coord -- [3,npix] or [4,npix] or [4x3] numeric array of the pixel
%               coordinates. If
% mode_to_bin
%          -- operation mode specifying what the following routine should
%              process. The mode is defined by number of output arguments.
%              Depending on the requested outputs, different inputs have
%              to be provided.
% Optional:
% npix or nothing if mode == npix_only
% npix,s,e accumulators if mode is higher then sigerr_cell
% pix_cand  -- if mode is higher than sigerr_cell. It must be
%              present as a PixelData class instance,
%              containing information about pixels
% unique_runid -- if mode == sort_and_id or higher, input array of unique_runid-s
%                 calculated on the previous step.
%
% Outputs:
% --------
% npix  -- array to keep number of pixels belonging to each cell
% s,e   -- arrays to keep each cell's signal and error values or empty
%          values (depending on mode)
% pix_cand -- input pix_cand if mode>1 or empty string if it is 1
%
% use_mex -- if true, try to deploy mex code for binning, if false
%            use MATLAB
%
% The the examples input/output parameters and input normalization
% as the function of bin_pixes procedure parameters and mode parameter as
% the function of the input arguments are presented below:
%
% Usage:
%   mode:  0, npix_only  -------------- 2-3(inputs)
% >>npix = bin_pixels(obj,coord);
% >>npix = bin_pixels(obj,coord,npix);
%                                        3(inputs)
%          normalize_bin_input_(obj,coord,mode)
%   mode:  2,sig_err  -------------------   6(inputs)
% >>[npix,s,e] = bin_pixels(obj,coord,npix,s,e,pix_candidates);
%                                           7(inputs)
%          normalize_bin_input_(obj,coord,mode,npix,s,e,pix_candidates)
%   mode:  3 sigerr_cell   -------------------    6(inputs)
% >>[npix,s,e] = bin_pixels(obj,coord,npix,s,e,cellarray_to_bin) but
%                                                 7(inputs)
%                      normalize_bin_input_(obj,coord,mode,npix,s,e,cellarray_to_bin)
%   mode:  4 sort_pix  -------------------             6(inputs)
% >>[npix,s,e,pix_ok_sorted] = bin_pixels(obj,coord,npix,s,e,pix_candidates)
%                                        7(inputs)
%                      normalize_bin_input_(obj,coord,mode,npix,s,e,pix_candidates)

%   mode:  5  sort_and_id   -------------------                       6(inputs)
% >>[npix,s,e,pix_ok,unque_runid] = bin_pixels(obj,coord,npix,s,e,pix_candidates)
%                                        7(inputs)
%                      normalize_bin_input_(obj,coord,mode,npix,s,e,pix_candidates)
%   mode:  5  sort_and_id   -------------------                       7(inputs)
% >>[npix,s,e,pix_ok,unque_runid] = bin_pixels(obj,coord,npix,s,e,pix_candidates,unique_runid)
%                                        8(inputs)
%                      normalize_bin_input_(obj,coord,mode,npix,s,e,pix_candidates,unique_runid)

%   mode:  6  nosort_and_idx   -------------------                       6(inputs)
% >>[npix,s,e,pix_ok,unque_runid,pix_id] = bin_pixels(obj,coord,npix,s,e,pix_candidates)
%                                        7(inputs)
%                      normalize_bin_input_(obj,coord,mode,npix,s,e,pix_candidates)
% >>[npix,s,e,pix_ok,unque_runid,pix_id] = bin_pixels(obj,coord,npix,s,e,pix_candidates,unique_runid)
%                                        8(inputs)
%                      normalize_bin_input_(obj,coord,mode,npix,s,e,pix_candidates,unique_runid)

%   mode:  7    -------------------                       7(inputs)
% >>[npix,s,e,pix_ok,unque_runid,pix_indx] = bin_pixels(obj,coord,npix,s,e,pix_candidates,unque_runid)
%                                        8(inputs)
%                      normalize_bin_input_(obj,coord,mode,npix,s,e,pix_candidates,unque_runid)
if ~isnumeric(pix_coord)
    error('HORACE:AxesBlockBase:invalid_argument',...
        'first argument of the routine have to be 4xNpix or 3xNpix numeric array of pixel coordinates')
end

if ~(size(pix_coord,1) == 4 || (mode_to_bin == bin_mode.npix_only && size(pix_coord,1) == 3))
    error('HORACE:AxesBlockBase:invalid_argument',...
        'first argument of the routine have to be 4xNpix or 3xNpix array of pixel coordinates')
end
s = [];
e = [];
unique_runid = [];
narg_in = numel(varargin);
use_mex = config_store.instance().get_value('hor_config','use_mex');
not_use_mex = ~use_mex;

if mode_to_bin == bin_mode.npix_only
    pix_cand = [];
    if use_mex
        npix = [];
    else
        if numel(varargin) == 0 || isempty(varargin{1})
            npix = obj.init_accumulators(1,force_3Dbinning);
            varargin{1} = npix;
        end
    end
else
    if mode_to_bin>bin_mode.npix_only && numel(varargin)<4
        error('HORACE:AxesBlockBase:invalid_argument',...
            'Calculating signal and error requests providing full pixel information, and this information is missing')
    end
    pix_cand  = varargin{4};
    if ~(isa(pix_cand,'PixelDataBase') || (iscell(pix_cand) && numel(pix_cand{1}) == size(pix_coord,2)))
        error('HORACE:AxesBlockBase:invalid_argument',...
            '7-th argument of the function must be instance of PixelData class or cell array thereof. It is: %s',...
            class(pix_coord));
    end
end
if mode_to_bin == bin_mode.sigerr_cell
    n_accumulators = numel(varargin{end});
    if n_accumulators ~=3
        n_accumulators = n_accumulators +1;
    end
else
    n_accumulators = 3;
end

% Analyze the number of input arguments
switch narg_in
    case 0
        if not_use_mex
            [npix,s,e] = obj.init_accumulators(1,force_3Dbinning);
        end
    case 1
        npix = varargin{1};
        if not_use_mex
            check_size(obj,not_use_mex,npix);
        end
    case {2, 3}
        error('HORACE:AxesBlockBase:invalid_argument',...
            'Can not request signal or signal and variance accumulation arrays without providing pixels source')
    case 4
        [npix,s,e] = check_and_alloc_accum(obj,not_use_mex,varargin{1:3},n_accumulators,force_3Dbinning);
    case 5
        [npix,s,e] = check_and_alloc_accum(obj,not_use_mex,varargin{1:3},n_accumulators,force_3Dbinning);
        unique_runid = varargin{5};
    otherwise
        [npix,s,e] = check_and_alloc_accum(obj,not_use_mex,varargin{1:3},n_accumulators,force_3Dbinning);
        unique_runid = varargin{5};
        %argi = varargin{6:end};
end

% initiate accumulators to 0, as no input value is provied
if mode_to_bin>bin_mode.npix_only && isempty(npix) && not_use_mex
    [npix,s,e] = obj.init_accumulators(3,force_3Dbinning);
end

end

function [npix,s,e]=check_and_alloc_accum(obj,not_use_mex,npix,s,e,n_case,force_3Dbinning)
empty_s = isempty(s);
empty_n = isempty(npix);

alloc_all =  empty_n && empty_s && not_use_mex;
alloc_se  = ~empty_n && empty_s && not_use_mex;
if alloc_all
    [npix,s,e] = obj.init_accumulators(n_case,force_3Dbinning);
elseif alloc_se
    s = obj.init_accumulators(1,force_3Dbinning);
    e = obj.init_accumulators(1,force_3Dbinning);
    check_size(obj,not_use_mex,npix,s,e);
else
    check_size(obj,not_use_mex,npix,s,e);

end

end

function check_size(obj,not_use_mex,varargin)
if ~not_use_mex % use mex -- all empty would work ok
    is_empty = cellfun(@isempty,varargin);
    if all(is_empty)
        return;
    end
end
sze = obj.dims_as_ssize();
for i=1:numel(varargin)
    if any(size(varargin{i}) ~=sze)
        error('HORACE:AxesBlockBase:invalid_argument',...
            'sizes of npix,s, e accumulators (%s) have to be equal to the sizes of the axes binning (%s)',...
            evalc('disp(size(varargin{i}))'),evalc('disp(size(sze))'));
    end
end

end
