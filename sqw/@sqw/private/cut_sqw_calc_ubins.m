function [ok, mess, iax, iint, pax, p, urange, pbin_out] = cut_sqw_calc_ubins (urange_in, proj, pbin, pin, en)
% Create bin boundaries for integration and plot axes from requested limits and step sizes
% Uses knowledge of the range of the data and energy bins of the data to set values for those
% not provided.
%
%   >> [ok, mess, iax, iint, pax, p, urange, pbin_out] = cut_sqw_calc_ubins (urange_in, proj, pbin, pin, en)
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
%   pin         Cell array, length 4, of default bin boundaries for each axis. Boundaries assumed equally spaced
%              assumed to be column vectors. 
%               If length(pin{i})==2, will be interpreted as integration range.
%
%   en          Energy bin information used if energy step is zero (see above)
%
%
% Output:
% -------
%   ok          True if all OK, false otherwise
%   mess        Error message; empty if all was OK; non-empty otherwise,
%              in which case all other output are empty
%   iax         Index of integration axes into the projection axes  [row vector]
%                   e.g. if data is 2D, data.iax=[1,3] means summation has been performed along u1 and u3 axes
%   iint        Integration range along each of the integration axes. [iint(2,length(iax))]
%                   e.g. in 2D case above, is the matrix vector [u1_lo, u3_lo; u1_hi, u3_hi]
%   pax         Index of plot axes into the projection axes  [row vector]
%                   e.g. if data is 3D, data.pax=[1,3,4] means u1, u3, u4 axes are x,y,z in any plotting
%   p           Call array containing bin boundaries along the plot axes [column vectors]
%                   i.e. data.p{1}, data.p{2} ... (for as many plot axes as given by length of data.pax)
%   urange      Array of limits of data that can possibly contribute to the output data structure in the
%               coordinate frame of the output structure [2x4].
%   pbin_out    Cell array of limits and binning descriptors for integration and plot axes, that will
%               reproduce the contents of p


% T.G.Perring   15/07/2007


ok = true;
mess = '';

% Check number and format of integration range / plotting description
% ------------------------------------------------------------------------
n=length(pbin);
if n<3 || n>4
    iax=[]; iint=[]; pax=[]; p=[]; urange=[];
    ok = false;
    mess = 'Must provide binning descriptor for all three momentum axes and (optionally) the energy axis';
    return
end

if ~(isempty(pbin{1})||(isa_size(pbin{1},'row','double') && length(pbin{1})>=1 && length(pbin{1})<=3)) || ...
   ~(isempty(pbin{2})||(isa_size(pbin{2},'row','double') && length(pbin{2})>=1 && length(pbin{2})<=3)) || ...
   ~(isempty(pbin{3})||(isa_size(pbin{3},'row','double') && length(pbin{3})>=1 && length(pbin{3})<=3))
    iax=[]; iint=[]; pax=[]; p=[]; urange=[];
    ok = false;
    mess = 'Check format of integration range / plotting description for momentum axes';
    return
end

if n==4
    if ~(isempty(pbin{4})||(isa_size(pbin{4},'row','double') && length(pbin{4})>=1 && length(pbin{4})<=3))
        iax=[]; iint=[]; pax=[]; p=[]; urange=[];
        ok = false;
        mess = 'Check format of integration range / plotting description for energy axis';
        return
    end
end


% Check values are acceptable, and make ranges 1x3 (for plot) or 1x2 for integration axes
% ---------------------------------------------------------------------------------------
% At this point, we are just filling in the values for the missing elements according to
% the convention 
% (1) absent binning description: use default bin information in pin
% (2) missing plot ranges are +inf, -inf (upper, lower) and missing bin width for energy is 0.
% Will combine with the limits of the data in the block of code that follows the this block
npax = 0;
niax = 0;
pax = zeros(1,4);
iax = zeros(1,4);
pbin_from_pin = false(1,4); % will contain true if bin boundaries / integration ranges are to be taken from defaults
vstep = NaN(4,1); % will contain requested step sizes if plot axis (NaN otherwise)
vlims = zeros(4,2); % will contain requested limits of bin centres / integration range
for idim=1:4
    if n==3     % case when energy axis not given
        pbin{4}=[-inf,0,inf];
    end
    if isempty(pbin{idim})
        pbin_from_pin(idim)=true;
        % Could be integration axis or plot axis depending if number of bins=2 or >2
        if length(pin{idim})==2
            niax = niax + 1;
            iax(niax) = idim;
            vlims(idim,:) = pin{idim};
        elseif length(pin{idim})>2
            npax = npax + 1;
            pax(npax) = idim;
            vstep(idim) = pin{idim}(2)-pin{idim}(1);    % not used as of 13/5/09, but put here for completeness
            vlims(idim,:) = [pin{idim}(1),pin{idim}(end)];
        end
    elseif length(pbin{idim})==2
        % the case of an integration axis
        niax = niax + 1;
        iax(niax) = idim;
        vlims(idim,:) = pbin{idim};
    else
        % must be a plot axis
        npax = npax + 1;
        pax(npax) = idim;
        if length(pbin{idim})==1
            vstep(idim) = pbin{idim}(1);
            vlims(idim,:) = [-inf,inf];
        elseif length(pbin{idim})==3
            vstep(idim) = pbin{idim}(2);
            vlims(idim,:) = [pbin{idim}(1),pbin{idim}(3)];
        end
        % Check validity of step sizes
        if idim==4 && vstep(idim)<0 % recall that step of zero is valid for energy axis
            iax=[]; iint=[]; pax=[]; p=[]; urange=[];
            ok = false;
            mess = 'Cannot have negative energy step size';
            return
        elseif idim~=4 && vstep(idim)<=0
            iax=[]; iint=[]; pax=[]; p=[]; urange=[];
            ok = false;
            mess = ['Cannot have zero step size for plotting - check axis ',num2str(idim)];
            return
        end
    end
    % check validity of data ranges
    if vlims(idim,2)<vlims(idim,1)
        iax=[]; iint=[]; pax=[]; p=[]; urange=[];
        ok = false;
        mess = ['Check upper limit greater or equal to the lower limit - check axis ',num2str(idim)];
        return
    end
end
% Compact down iax and pax
pax = pax(1:npax);
iax = iax(1:niax);


% Compute plot bin boundaries and integration ranges
% ------------------------------------------------------------------------
% Get range in output projection axes from the 8 points defined in momentum space by urange_in:
% This gives the maximum extent of the data pixels that can possibly contribute to the output data. 
% third coodinate is not used.
urange_out = proj.find_max_data_range(urange_in);

% Compute plot bin boundaries and range that fully encloses the requested output plot axes
iint=zeros(2,niax);
p   =cell(1,npax);
urange=zeros(2,4);
pbin_out = cell(1,4);

for i=1:npax
    ipax = pax(i);
    if pbin_from_pin(ipax)
        % Use default input bins
        p{i}=pin{ipax};
        pbin_out{ipax} = make_const_bin_boundaries_descr(p{i});
    else
        pbin_tmp=[vlims(ipax,1),vstep(ipax),vlims(ipax,2)];
        if ipax<4 || (ipax==4 && vstep(ipax)>0)
            % Q axes, and also treat energy axis like other axes if provided with energy bin greater than zero
            p{i}=make_const_bin_boundaries(pbin_tmp,urange_out(:,ipax));
        else
            % Only reaches here if energy axis and requested energy bin width is explicity or implicitly zero
            % Handle this case differently to above, because we ensure bin boundaries synchronised to boundaries in array en
            p{i}=make_const_bin_boundaries(pbin_tmp,urange_out(:,ipax),en,true);
        end
        % No bins
        if isempty(p{i})
            iax=[]; iint=[]; pax=[]; p=[]; urange=[];
            ok = false;
            mess = 'Plot range outside extent of data for at least one plot axis';
            return
        end
        % For a plot axis we have declared that we need at least two bins
        if numel(p{i})<=2
            iax=[]; iint=[]; pax=[]; p=[]; urange=[];
            ok = false;
            str=str_compress(num2str(pbin_tmp));
            mess=['Only one bin in range [',str,'] - cannot make this a plot axis'];
            return
        end
        pbin_out{ipax} = pbin_tmp;
    end
    urange(:,ipax)=[p{i}(1);p{i}(end)];
end

% Compute integration ranges. We keep the requested ranges, but also fill array with ranges that enclose the actual data.
for i=1:niax
    iiax = iax(i);
    iint(1,i)=vlims(iiax,1);
    iint(2,i)=vlims(iiax,2);
    urange(1,iiax)=max(vlims(iiax,1),urange_out(1,iiax));
    urange(2,iiax)=min(vlims(iiax,2),urange_out(2,iiax));
    if urange(1,iiax)>urange(2,iiax)
% *** T.G.Perring 28 Sep 2018:********************
        urange(2,iiax) = urange(1,iiax);    % do not want to stop the cutting - just want to ensure no unnecessary read from input object or cut
%         iax=[]; iint=[]; pax=[]; p=[]; urange=[];
%         ok = false;
%         mess = sprintf('Integration range outside extent of data for projection axis %d (integration axis %d)',iiax,i);
%         return
% ************************************************
    end
    pbin_out{iiax} = vlims(iiax,:)';
end
