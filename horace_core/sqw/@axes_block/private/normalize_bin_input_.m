function [npix,s,e,pix_cand,unique_runid,argi]=...
    normalize_bin_input_(obj,pix,mde,varargin)
% verify inputs of the bin_pixels function and convert various
% forms of the inputs of this function into a common form, where the missing
% inputs are presented as empty outputs.
%
% Inputs:
% pix -- [3,npix] or [4,npix] numeric array of the pixel coordinates
% mde -- operation mode specifying what the following routine should process.
%        The mode is defined by number of output arguments. Depending on
%        the requested outputs, different inputs have to be provided
% Optional:
% npix or nothing if mde == 1
% npix,s,e accumulators if mde in [4,5,6]
%
%
% Outputs:
% npix  -- array to keep number of pixels belonging to each cell
% s,e   -- arrays to keep each cell's signal and error values or empty
%          values (depending on mde)
% argi  -- anything else, provided as input and not related to the
%          processed inputs, left for further routines to process
%

if ~isnumeric(pix)
    error('HORACE:axes_block:invalid_argument',...
        'first argument of the routine have to be 4xNpix or 3xNpix numeric array of pixel coordinates')
end

if ~(size(pix,1) == 4 || (mde == 1 && size(pix,1) == 3))
    error('HORACE:axes_block:invalid_argument',...
        'first argument of the routine have to be 4xNpix or 3xNpix array of pixel coordinates')
end

bin_size = obj.dims_as_ssize();
if mde == 1
    pix_cand = [];
else
    if nargin<7
        error('HORACE:axes_block:invalid_argument',...
            'PixelData have to be provided as 7-th argument if cell-average signal and erros are requested');
    end
    pix = varargin{4};
    if ~isa(pix,'PixelData')
        error('HORACE:axes_block:invalid_argument',...
            '7-th argument of the function have to be PixelData class. It is: %s',...
            class(pix));
    end
    % Usage:
    % >>npix = bin_pixels(obj,coord);
    %      3
    % >>[npix,s,e] = bin_pixels(obj,coord,npix,s,e);
    %      4
    % >>[npix,s,e,pix_ok] = bin_pixels(obj,coord,npix,s,e,pix_candidates)    
    %      5
    % >>[npix,s,e,pix_ok,unque_runid] = bin_pixels(obj,coord,npix,s,e,pix_candidates)
    %      6
    % >>[npix,s,e,pix_ok,unque_runid,pix_indx] = bin_pixels(obj,coord,npix,s,e,pix_candidates)
    if ismember(mde,[3,4,5,6])
        pix_cand = pix;
    else
        error('HORACE:axes_block:invalid_argument',...
            'The procedure accepts 1,3,4,5 or 6 output arguments')
    end
end
argi = {};
if size(pix,1) ==3  % Q(3D) binning only. Third axis is always missing
    bin_size = obj.nbins_all_dims;
    bin_size = bin_size(1:3);
end
if nargin == 3
    npix = squeeze(zeros(bin_size));
    s = [];
    e = [];
elseif nargin == 4
    npix = varargin{1};
    check_size(bin_size,npix);
    s = [];
    e = [];
elseif nargin==5 || nargin == 6
    error('HORACE:axes_block:invalid_argument',...
        'Can not provide only signal or signal and variance accumulation arrays without providing pixels source')
elseif nargin ==7
    npix = varargin{1};
    s = varargin{2};
    e = varargin{3};
    if ~isempty(npix)
        check_size(bin_size,npix,s,e);
    end
elseif nargin >6
    npix = varargin{1};
    s    = varargin{2};
    e    = varargin{3};
    check_size(bin_size,npix,s,e);
    argi = varargin{5:end};
end
if mde>1 && isempty(npix)
    npix = squeeze(zeros(bin_size));
    s = squeeze(zeros(bin_size));
    e = squeeze(zeros(bin_size));
end

function check_size(sze,varargin)
for i=1:numel(varargin)
    if any(size(varargin{i}) ~=sze)
        error('HORACE:axes_block:invalid_argument',...
            'sizes of npix,s, e accumulators (%s) have to be equal to the sizes of the axes binning (%s)',...
            evalc('disp(size(varargin{i}))'),evalc('disp(size(sze))'));
    end
end
