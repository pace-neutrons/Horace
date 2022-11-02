function [npix,s,e,pix_cand,unique_runid,argi]=...
    normalize_bin_input_(grid_size,pix_coord,mod,varargin)
% verify inputs of the bin_pixels function and convert various
% forms of the inputs of this function into a common form, where the missing
% inputs are presented as empty outputs or zero-values arrays of the
% appropriate size
%
% Inputs:
% ------------
% grid_size -- the size of the grid, the pixels will be rebinned on
%
% pix_coord -- [3,npix] or [4,npix] or [43] numeric array of the pixel
%               coordinates. If
% mod       -- operation mode specifying what the following routine should
%              process. The mode is defined by number of output arguments.
%              Depending on the requested outputs, different inputs have
%              to be provided.
% Optional:
% npix or nothing if mod == 1
% npix,s,e accumulators if mod is [4,5,6]
% pix_cand  -- if mod == [4,5,6], must be present as a PixelData class
%              instance, containing information about pixels
% unique_runid -- if mod == [5,6], input array of unique_runid-s
%                 calculated on the previous step.
%
% Outputs:
% --------
% npix  -- array to keep number of pixels belonging to each cell
% s,e   -- arrays to keep each cell's signal and error values or empty
%          values (depending on mod)
% pix_cand -- input pix_cand if mod>1 or empty string if it is 1
%
% argi  -- celarray of character strings, provided as input and not related
%          to the processed arrays, left for further routines to process.
%
% The the examples input/output parameters and input normalization
% as the function of bin_pixes procedure parameters and mod parameter as
% the function of the input arguments are presented below:
%
% Usage:
%   mod:  1  -------------- 2(inputs)
% >>npix = bin_pixels(obj,coord);
%                                        3(inputs)
%          normalize_bin_input_(obj,coord,mod)
%   mod:  3    -------------------   5(inputs)
% >>[npix,s,e] = bin_pixels(obj,coord,npix,s,e);
%                                        6(inputs)
%          normalize_bin_input_(obj,coord,mod,npix,s,e)
%   mod:  3    -------------------   5(inputs)
% >>[npix] = bin_pixels(obj,coord,npix);
%                                        4(inputs)
%          normalize_bin_input_(obj,coord,mod,npix)

%   mod:  4    -------------------    6(inputs)
% >>[npix,s,e,pix_ok] = bin_pixels(obj,coord,npix,s,e,pix_candidates)
%                                        7(inputs)
%                      normalize_bin_input_(obj,coord,mod,npix,s,e,pix_candidates)
%   mod:  5     -------------------                   6(inputs)
% >>[npix,s,e,pix_ok,unque_runid] = bin_pixels(obj,coord,npix,s,e,pix_candidates)
%                                        7(inputs)
%                      normalize_bin_input_(obj,coord,mod,npix,s,e,pix_candidates)

%   mod:  6     -------------------                       6(inputs)
% >>[npix,s,e,pix_ok,unque_runid,pix_indx] = bin_pixels(obj,coord,npix,s,e,pix_candidates)
%                                        7(inputs)
%                      normalize_bin_input_(obj,coord,mod,npix,s,e,pix_candidates)
%   mod:  6     -------------------                       7(inputs)
% >>[npix,s,e,pix_ok,unque_runid,pix_indx] = bin_pixels(obj,coord,npix,s,e,pix_candidates,unque_runid)
%                                        8(inputs)
%                      normalize_bin_input_(obj,coord,mod,npix,s,e,pix_candidates,unque_runid)

if ~isnumeric(pix_coord)
    error('HORACE:axes_block:invalid_argument',...
        'first argument of the routine have to be 4xNpix or 3xNpix numeric array of pixel coordinates')
end

if ~(size(pix_coord,1) == 4 || (mod == 1 && size(pix_coord,1) == 3))
    error('HORACE:axes_block:invalid_argument',...
        'first argument of the routine have to be 4xNpix or 3xNpix array of pixel coordinates')
end
unique_runid = [];
s = [];
e = [];
% extract possible character keys
is_key = cellfun(@(x)(ischar(x)||isstring(x)),varargin);
argi = varargin(is_key);
inputs = varargin(~is_key);
narg = numel(inputs)+3;

if mod == 1
    pix_cand = [];
else
    if narg <7
        error('HORACE:axes_block:invalid_argument',...
            'PixelData have to be provided as 7-th argument if cell-average signal and erros are requested');
    end
    if ~ismember(mod,[1,3,4,5,6])
        error('HORACE:axes_block:invalid_argument',...
            'The procedure accepts 1,3,4,5 or 6 output arguments')
    end
    if mod>1 && numel(varargin)<4
        error('HORACE:axes_block:invalid_argument',...
            'Calculating signal and error requests providing full pixel information, and this information is missing')
    end
    pix_cand  = varargin{4};
    if ~(isa(pix_cand,'PixelData') || (iscell(pix_cand) && numel(pix_cand{1}) == size(pix_coord,2)))
        error('HORACE:axes_block:invalid_argument',...
            '7-th argument of the function must be instance of PixelData class or cell array thereof. It is: %s',...
            class(pix_coord));
    end
end


% Analyze the number of input arguments
if narg == 3
    npix = squeeze(zeros(grid_size));
elseif narg == 4
    npix = varargin{1};
    check_size(grid_size,npix);
elseif narg==5 || narg == 6
    error('HORACE:axes_block:invalid_argument',...
        'Can not request signal or signal and variance accumulation arrays without providing pixels source')
elseif narg ==7
    [npix,s,e] = check_and_alloc_accum(varargin{1},varargin{2},varargin{3},grid_size);
elseif narg ==8
    [npix,s,e] = check_and_alloc_accum(varargin{1},varargin{2},varargin{3},grid_size);
    unique_runid = varargin{5};
elseif narg >8
    [npix,s,e] = check_and_alloc_accum(varargin{1},varargin{2},varargin{3},grid_size);
    unique_runid = varargin{5};
    argi = varargin{6:end};
end
% initiate accumulators to 0, as no input value is provied
if mod>1 && isempty(npix)
    npix = squeeze(zeros(grid_size));
    s = squeeze(zeros(grid_size));
    e = squeeze(zeros(grid_size));
end
%--------------------------------------------------------------------------
function [npix,s,e]=check_and_alloc_accum(npix,s,e,bin_size)
if isempty(npix)
    npix = squeeze(zeros(bin_size));
    space_alloc = true;
else
    space_alloc = false;
end
if isempty(s) % err is also empty
    s = squeeze(zeros(bin_size));
    e = squeeze(zeros(bin_size));
    space_alloc = true;
end
if ~space_alloc
    check_size(bin_size,npix,s,e);
end
%--------------------------------------------------------------------------
function check_size(sze,varargin)
for i=1:numel(varargin)
    if any(size(varargin{i}) ~=sze)
        error('HORACE:axes_block:invalid_argument',...
            'sizes of npix,s, e accumulators (%s) have to be equal to the sizes of the axes binning (%s)',...
            evalc('disp(size(varargin{i}))'),evalc('disp(size(sze))'));
    end
end
