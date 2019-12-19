function [ pbin_out, ndims] = calc_pbins(proj, urange_in, pbin, pin, en)
% Check binning descriptors are valid, and resolve multiple integration axes
% using limits and bin widths from the input data.
%
%   >> [ok, mess, pbin_out, ndims] = cut_sqw_calc_pbins (urange, proj, pbin, pin, en)
%
% Input:
% ------
%   urange_in   [2x4] array of range of data along the input projection axes (elements must all be finite)
%
%   proj        The class which defines the projection
%
%   pbin        Cell array of requested limits and binning descriptors for integration and plot axes:
%       pbin{1}     Binning along first Q axis
%       pbin{2}     Binning along second Q axis
%       pbin{3}     Binning along third Q axis
%               - [] or ''          Use default bins (bin size and limits)
%               - [pstep]           Plot axis: sets step size; plot limits taken from extent of the data
%               - [plo, phi]        Integration axis: range of integration
%               - [plo, pstep, phi] Plot axis: minimum and maximum bin centres and step size
%               - [plo, pstep, phi, width] Integration axis: one output cut for each integration
%                                  range centred on plo, plo+step, plo+2*step... and with width
%                                  given by 'width'
%                                   If width=0, it is taken to be equal to pstep.
%
%       pbin{4}     Binning along the energy axis:
%               - omit              Equivalent to [0] and [-Inf,0,Inf]
%               - [] or ''          Use default bins (bin size and limits)
%               - [pstep]           Plot axis: sets step size; plot limits taken from extent of the data
%                                  If pstep=0 then use bin size of energy bins in array en (below) and synchronise
%                                  the output bin boundaries with the reference boundaries. The overall range is
%                                  chosen to ensure that the energy range in urange_in is contained within
%                                  the bin boundaries.
%               - [plo, phi]        Integration axis: range of integration
%           	- [plo, pstep, phi]	Plot axis: minimum and maximum bin centres and step size;
%                                  If pstep=0 then use bin size of energy bins in array en (below) and align
%                                  the output bin boundaries with the reference boundaries. The overall range is
%                                  chosen to ensure that the energy range plo to phi is contained within
%                                  the bin boundaries.
%               - [plo, pstep, phi, width] Integration axis: one output cut for each integration
%                                  range centred on plo, plo+step, plo+2*step... and with width
%                                  given by 'width'
%                                   If width=0, it is taken to be equal to pstep.
%
%   pin         Cell array, length 4, of default bin boundaries for each axis. Boundaries assumed equally spaced
%              assumed to be column vectors.
%               If length(pin{i})==2, will be interpreted as integration range.
%
%   en          Energy bin information used if energy step is zero (see above)
%
% Output:
% -------
%   ok          True if all OK; false otherwise
%
%   mess        Error message; empty if all was OK; non-empty otherwise,
%              in which case all other output are empty)
%
%   pbin_out    Cell array of limits and binning descriptors for integration and plot axes. Where
%               an axis is to be split into multiple integration ranges the corresponding
%               descriptor is an array size [n,2] where n is the number integration ranges for
%               that axis.
%
%   ndims       Dimensionality of the output cut


% T.G.Perring   25/08/2018


% Default output
% --------------
pbin_out = pbin;
ndims = numel(pin);


% Check number and format of integration range / plotting description
% ------------------------------------------------------------------------
n=length(pbin);
if n<3 || n>4
    error('aPROJECTION:invalid_arguments',...
        'Must provide binning descriptor for all three momentum axes and (optionally) the energy axis');
end

if ~(isempty(pbin{1})||(isa_size(pbin{1},'row','double') && length(pbin{1})>=1 && length(pbin{1})<=4)) || ...
        ~(isempty(pbin{2})||(isa_size(pbin{2},'row','double') && length(pbin{2})>=1 && length(pbin{2})<=4)) || ...
        ~(isempty(pbin{3})||(isa_size(pbin{3},'row','double') && length(pbin{3})>=1 && length(pbin{3})<=4))
    error('aPROJECTION:invalid_arguments',...
        'Check format of integration range / plotting description for momentum axes');
end

if n==4
    if ~(isempty(pbin{4})||(isa_size(pbin{4},'row','double') && length(pbin{4})>=1 && length(pbin{4})<=4))
        error('aPROJECTION:invalid_arguments',...
            'Check format of integration range / plotting description for energy axis');
    end
end

% Check validity of binning descriptors
% -------------------------------------
% Strip 4th array element if present
pbin_tmp = pbin;
n_pbin = zeros(1,4);
for i=1:n
    n_pbin(i) = numel(pbin{i});
    if n_pbin(i)>3
        if pbin{i}(4)<0 || ~isfinite(pbin{i}(4))
            error('aPROJECTION:invalid_arguments',...
                'Integration width must be greater of equal to zero - check axis N %d ',(i));
        end
        pbin_tmp{i} = pbin_tmp{i}(1:3);
    end
end

% Get integration and plot axes
[~, ~, pax, p] = proj.calc_ubins (urange_in,pbin_tmp, pin, en);
ndims = numel(p);
multi = (n_pbin==4);
if any(multi)
    % Case of at least one axis where the plot axes are to be interpreted as
    % multiple integration axes
    for i=1:numel(pax)
        idim = pax(i);
        if multi(idim)
            pcent = 0.5*(p{i}(2:end)+p{i}(1:end-1));
            if n_pbin(idim)==4 && pbin{idim}(4)>0    % this picks up case of n==3 i.e. no energy binning given
                width = pbin{idim}(4);
            else
                width = (p{i}(end)-p{i}(1))/(numel(p{i})-1);
            end
            pbin_out{idim} = pcent + repmat(width*[-0.5,0.5],size(pcent,1),1);
        end
    end
end
