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
% $Revision:: 1720 ($Date:: 2019-04-08 16:49:36 +0100 (Mon, 8 Apr 2019) $)


% Trivial case of no section arguments
if nargin==1
    wout = win;
    return
end

% Dimension of input data structures
ndim=dimensions(win(1));
for i=2:numel(win)
    if dimensions(win(i))~=ndim
        error('All objects must have same dimensionality for sectioning to work')
    end
end
if ndim==0  % no sectioning possible
    error ('Cannot section a zero dimensional object')
end


nargs= length(varargin);
if nargs~=ndim
    error ('Check number of arguments')
end

% Initialise output argument
wout = win;

tol=4*eps('single');    % acceptable tolerance: bin centres deemed contained in new boundaries

for n=1:numel(win)
    [ndim,sz]=dimensions(win(n));   % need to get sz array specific for each element in array win
    % Get section parameters and axis arrays:
    % The input sectioning arguments refer to the *display* axes; these must be converted to the relevant plot axes in the algorithm
    irange = zeros(2,ndim);
    array_section = cell(1,ndim);
    p=win(n).data.p;   % extract bin boundaries
    for i=1:nargs
        if isempty(varargin{i}) || (isscalar(varargin{i}) && isequal(varargin{i},0))
            pax=win(n).data.dax(i);
            irange(1,pax) = 1;
            irange(2,pax) = sz(pax);
            array_section{pax}=irange(1,pax):irange(2,pax);
        elseif isa_size(varargin{i},[1,2],'double')
            if varargin{i}(1)>varargin{i}(2)
                error (['Lower limit larger than upper limit for axis ',num2str(i)])
            end
            pax=win(n).data.dax(i);
            pcent = 0.5*(p{pax}(2:end)+p{pax}(1:end-1));          % values of bin centres
            lis=find(pcent>=(varargin{i}(1)-tol) & pcent<=(varargin{i}(2)+tol));    % index of bins whose centres lie in the sectioning range
            if ~isempty(lis)
                irange(1,pax) = lis(1);
                irange(2,pax) = lis(end);
                wout(n).data.p{pax} = p{pax}(lis(1):lis(end)+1);
                array_section{pax}=irange(1,pax):irange(2,pax);
            else
                error (['No data along axis ',num2str(i),' in the range [',num2str(varargin{i}(1)),',',num2str(varargin{i}(2)),']'])
            end
        else
            error (['Limits parameter for axis ',num2str(i),' must be zero or a pair of numbers'])
        end
    end

    % Section signal, variance and npix arrays
    wout(n).data.s = win(n).data.s(array_section{:});
    wout(n).data.e = win(n).data.e(array_section{:});
    wout(n).data.npix = win(n).data.npix(array_section{:});

    % Section the pix array, if sqw type, and update urange
    if is_sqw_type(win(n))
        % Section pix array
        [nstart,nend] = aProjection.get_nrange(win(n).data.npix,irange);   % get contiguous ranges of pixels to be retained
        ind=ind_from_nrange(nstart,nend);
        wout(n).data.pix=win(n).data.pix(:,ind);
        % Update urange
        wout(n).data.urange=recompute_urange(wout(n));
    end

end
