function wout = section (win,varargin)
% Takes a section out of an sqw object
%
%   >> wout = section (win, [ax_1_lo, ax_1_hi], [ax_2_lo, ax_2_hi], ...)
%
% Input:
% ------
%   win                 Input sqw object
%
%   [ax_1_lo, ax_1_hi]  Lower and upper limits for the first axis. Bins are retained whose
%                      centres lie in this range.
%                       To retain the limits of the input structure, type '', [], or the scalar '0'
%
%   [ax_2_lo, ax_2_hi]  Lower and upper limits for the second axis
%
%           :                       :
%
%       for as many axes as there are plot axes
%
% Output:
% -------
%   wout                Output dataset.
%
%
% Example: to alter the limits of the first and third axes of a 3D sqw object:
%   >> wout = section (win, [1.9,2.1], [], [-0.55,-0.45])


% Original author: T.G.Perring
%


% Trivial case of no section arguments
if nargin==1
    wout = copy(win);
    return
end

% Dimension of input data structures
ndim=dimensions(win(1));
if ndim==0  % no sectioning possible
    error('HORACE:sqw:invalid_argument', 'Cannot section a zero dimensional object')
end

if numel(win) > 1 && any(cellfun(@(x)(dimensions(x)~=ndim), win(2:end)))
    error('HORACE:sqw:invalid_argument', 'All objects must have same dimensionality for sectioning to work')
end

nargs = length(varargin);
if nargs~=ndim
    error('HORACE:sqw:invalid_argument', 'Check number of arguments')
end

% Initialise output argument
wout = copy(win);

tol=4*eps('single');    % acceptable tolerance: bin centres deemed contained in new boundaries

for n=1:numel(win)
    [ndim,sz]=dimensions(win(n));   % need to get sz array specific for each element in array win
    % Get section parameters and axis arrays:
    % The input sectioning arguments refer to the *display* axes; these must be converted to the relevant plot axes in the algorithm
    irange = zeros(2,ndim);
    array_section = cell(1,ndim);
    p=win(n).data.p;   % extract bin boundaries
    p_ind = find(win(n).data.nbins_all_dims>1); %what actual indexes of the projection axis along all DnD object indexes
    % axis are among all indexes
    for i=1:nargs
        if isempty(varargin{i}) || (isscalar(varargin{i}) && isequal(varargin{i},0))
            pax=win(n).data.dax(i);
            irange(1,pax) = 1;
            irange(2,pax) = sz(pax);
            array_section{pax}=irange(1,pax):irange(2,pax);
        elseif isa_size(varargin{i},[1,2],'double')
            if varargin{i}(1)>varargin{i}(2)
                error ('HORACE:section:invalid_argument', ...
                'Lower limit larger than upper limit for axis %d',i)
            end
            pax=win(n).data.dax(i);
            pcent = 0.5*(p{pax}(2:end)+p{pax}(1:end-1));          % values of bin centres
            lis=find(pcent>=(varargin{i}(1)-tol) & pcent<=(varargin{i}(2)+tol));    % index of bins whose centres lie in the sectioning range
            if ~isempty(lis)
                irange(1,pax) = lis(1);
                irange(2,pax) = lis(end);
                wout(n).data.img_range(:,p_ind(pax))    = ...
                    [pcent(irange(1,pax));pcent(irange(1,pax))];
                wout(n).data.nbins_all_dims(p_ind(pax)) = irange(2,pax)-irange(1,pax)+1;
                %wout(n).data.p{pax} = p{pax}(lis(1):lis(end)+1);
                array_section{pax}=irange(1,pax):irange(2,pax);
            else
                error ('HORACE:section:invalid_argument', ...
                    'No data along axis %d in the range [%g, %g]', ...
                    i,varargin{i}(1),varargin{i}(2))
            end
        else
            error ('HORACE:section:invalid_argument', ...
                'Limits parameter for axis: %d must be zero or a pair of numbers', ...
                i)
        end
    end

    % Section signal, variance and npix arrays
    wout(n).data.s = win(n).data.s(array_section{:});
    wout(n).data.e = win(n).data.e(array_section{:});
    wout(n).data.npix = win(n).data.npix(array_section{:});

    % Section the pix array, if sqw type, and update img_range
    if has_pixels(win(n))
        % Section pix array
        proj = win(n).data.get_projection();
        [bl_start,bl_size] = proj.get_nrange(win(n).data.npix,win(n).data, ...
            win(n).data,proj);   % get contiguous ranges of pixels to be retained
        ind=ind_from_nrange(bl_start,bl_start+bl_size-1);
        wout(n).pix = win(n).pix.get_pixels(ind);
        %TODO: Do we actually need this? is this a suitable algorithm?
        % need careful checking if the pixels are indeed arranged according
        % to new bins.
        wout(n).data.img_range=recompute_img_range(wout(n));
    end

end

function ind = ind_from_nrange (nstart, nend)
% Create index array from a list of ranges
%
%   >> ind = ind_from_nrange (nstart, nend)
%
% Input:
% ------
%   nstart  Array of starting values of ranges of indicies
%   nend    Array of finishing values of ranges of indicies
%           It is assumed that nend(i)>=nbeg(i), and that
%          nbeg(i+1)>nend(i). That is, the ranges
%          contain at least one element, and they do not
%          overlap. No checks are performed to ensure these
%          conditions are satisfied.
%           nstart and nend can be empty.
%
% Output:
% -------
%   ind     Output array: column vector
%               ind=[nstart(1):nend(1),nstart(2):nend(2),...]'
%           If nstart and nend are empty, then ind is empty.


% Original author: T.G.Perring
%

if numel(nstart)==numel(nend)
    % Catch trivial case of no ranges
    if numel(nstart)==0
        ind=zeros(0,1);
        return
    end
    % Make input arrays columns if necessary
    if ~iscolvector(nstart), nstart=nstart(:); end
    if ~iscolvector(nend), nend=nend(:); end
    % Create index array using cumsum - shoudl be fast in general
    nel=nend-nstart+1;
    nelcum=cumsum(nel);
    ix=[1;nelcum(1:end-1)+1];
    dind=[nstart(1);nstart(2:end)-nend(1:end-1)];
    ind=ones(nelcum(end),1);
    ind(ix)=dind;
    ind=cumsum(ind);
else
    error('HORACE:sqw:invalid_argument', 'Number of elements in input arrays incompatible')
end
