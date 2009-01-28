function wout = section (win,varargin)
% Takes a section out of an sqw object
%
% Syntax:
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
%   >> wout = section (win, [1.9,2.1], 0, [-0.55,-0.45])
%                                                           

% Original author: T.G.Perring
%
% $Revision: 101 $ ($Date: 2007-01-25 09:10:34 +0000 (Thu, 25 Jan 2007) $)


% Trivial case of no section arguments
if nargin==1
    wout = win;
    return
end

% Dimension of input data structure
[ndim,sz]=dimensions(win);
if ndim==0  % no sectioning possible
    error ('Cannot section a zero dimensional object')
end


nargs= length(varargin);
if nargs~=ndim
    error ('Check number of arguments')
end

% Initialise output argument
wout = win;

% Get section parameters and axis arrays:
% The input sectioning arguments refer to the *display* axes; these must be converted to the relevant plot axes in the algorithm
irange = zeros(2,ndim);
array_section = cell(1,ndim);
p=win.data.p;   % extract bin boundaries
for i=1:nargs
    if isempty(varargin{i}) || (isscalar(varargin{i}) && isequal(varargin{i},0))
        pax=win.data.dax(i);
        irange(1,pax) = 1;
        irange(2,pax) = sz(pax);
        array_section{pax}=irange(1,pax):irange(2,pax);
    elseif isa_size(varargin{i},[1,2],'double')
        if varargin{i}(1)>varargin{i}(2)
            error (['Lower limit larger than upper limit for axis ',num2str(i)])
        end
        pax=win.data.dax(i);
        pcent = 0.5*(p{pax}(2:end)+p{pax}(1:end-1));          % values of bin centres
        lis=find(pcent>=varargin{i}(1) & pcent<=varargin{i}(2));    % index of bins whose centres lie in the sectioning range
        if ~isempty(lis)
            irange(1,pax) = lis(1);
            irange(2,pax) = lis(end);
            wout.data.p{pax} = p{pax}(lis(1):lis(end)+1);
            array_section{pax}=irange(1,pax):irange(2,pax);
        else
            error (['No data along axis ',num2str(i),' in the range [',num2str(varargin{i}(1)),',',num2str(varargin{i}(2)),']'])
        end
    else
        error (['Limits parameter for axis ',num2str(i),' must be zero or a pair of numbers'])
    end
end

% Section signal, variance and npix arrays
wout.data.s = win.data.s(array_section{:});
wout.data.e = win.data.e(array_section{:});
wout.data.npix = win.data.npix(array_section{:});

% Section the pix array, if sqw type, and update urange
if is_sqw_type(win)
    % Section pix array
    npixtot_out=sum(wout.data.npix(:));
    wout.data.pix=zeros(9,npixtot_out); % initialise output array
    [nstart,nend] = get_nrange(win.data.npix,irange);   % get contiguous ranges of pixels to be retained
    nel=nend-nstart+1;  % number of elements in each range
    n0=1;
    for i=1:numel(nstart)
        wout.data.pix(:,n0:n0+nel(i)-1)=win.data.pix(:,nstart(i):nend(i));
        n0=n0+nel(i);
    end
    % Update urange
    wout.data.urange=[min(wout.data.pix(1:4,:),[],2)';max(wout.data.pix(1:4,:),[],2)'];
end
