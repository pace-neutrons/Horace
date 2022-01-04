function [npix,s,e,pix_cand,argi]=...
    normalize_bin_input_(obj,pix,mode,varargin)

if ~isnumeric(pix) || size(pix,1) ~= 4
    error('HORACE:axes_block:invalid_argument',...
        'first argument of the routine have to be 4xNpix array of pixel coordinates')
end

[~,sz_proj,bin_size] = obj.data_dims();
if mode == 1
    pix_cand = [];
else
    if nargin<7
        error('HORACE:axes_block:invalid_argument',...
            'PixelData have to be provided as 7-th argument if cell-average signal and erros requested');
    end
    pix = varargin{4};
    if ~isa(pix,'PixelData')
        error('HORACE:axes_block:invalid_argument',...
            '7-th argument of the function have to be PixelData class. It is: %s',...
            class(pix));
    end
    
    if mode == 3
        pix_cand = [];
    elseif mode == 4
        pix_cand = pix;
    else
        error('HORACE:axes_block:invalid_argument',...
            'The procedure accepts 1,3 or 4 output arguments')
    end
end
argi = {};
if nargin == 3
    npix = squeeze(zeros(sz_proj));
    s = [];
    e = [];
elseif nargin == 4
    npix = varargin{1};
    check_size(bin_size,npix);
    s = [];
    e = [];
elseif nargin==5 || nargin == 6
    error('HORACE:axes_block:invalid_argument',...
        'Can not provide only signal or singal and variance accumulation places without providing pixels source')
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
if mode>1 && isempty(npix)
    npix = squeeze(zeros(sz_proj));    
    s = squeeze(zeros(sz_proj));
    e = squeeze(zeros(sz_proj));
end

function check_size(sze,varargin)
for i=1:numel(varargin)
    if any(size(varargin{i}) ~=sze)
        error('HORACE:axes_block:invalid_argument',...        
            'sizes of npix,s, e accumulators (%s) have to be equal to the sizes of the axes binning (%s)',...
            evalc('disp(size(varargin{i}))'),evalc('disp(size(sze))'));
    end
end
