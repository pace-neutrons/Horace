function [iax, iint, pax, p, urange, mess] = cut_sqw_calc_ubins (urange_in, rot, trans, pbin, pin, en)
% Create bin boundaries for integration and plot axes from requested limits and step sizes
% Uses knowledge of the range of the data and energy bins of the data to set values for those
% not provided.
%
% Syntax:
%   >> [iax, iint, pax, p, urange, mess] = cut_sqw_calc_ubins (urange_in, rot, trans, pbin, pin)
%
% Input:
% ------
%   urange_in   [2x4] array of range of data along the input projection axes (elements must all be finite)
%   rot         Matrix [3x3]     --|  that relate a vector expressed in the
%   trans       Translation [3x1]--|  frame of the bin boundaries to those of urange:
%                                         r'(i) = A(i,j)(r(j) - trans(j))
%   pbin        Cell array of requested limits and bins for integration and plot axes:
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
%                                  If pstep=0 then use bin size of energy bins in array en (below) and synchronise
%                                  the output bin boundaries with the reference boundaries. The overall range is
%                                  chosen to ensure that the energy range plo to phi is contained within
%                                  the bin boundaries.
%   pin         Cell array, length 4, of default bin boundaries for each axis. Boundaries assumed equally spaced
%              assumed to be column vectors. 
%               If length(pin{i})==2, will be interpreted as integration range.
%
%   en          Energy bin information used if energy step is zero (see above)
%
% Output:
% -------
%   iax         Index of integration axes into the projection axes  [row vector]
%                   e.g. if data is 2D, data.iax=[1,3] means summation has been performed along u1 and u3 axes
%   iint        Integration range along each of the integration axes. [iint(2,length(iax))]
%                   e.g. in 2D case above, is the matrix vector [u1_lo, u3_lo; u1_hi, u3_hi]
%   pax         Index of plot axes into the projection axes  [row vector]
%                   e.g. if data is 3D, data.pax=[1,3,4] means u1, u3, u4 axes are x,y,z in any plotting
%   p           Call array containing bin boundaries along the plot axes [column vectors]
%                   i.e. data.p{1}, data.p{2} ... (for as many plot axes as given by length of data.pax)
%   urange      Array of limits of output integration and plot axes [2x4]. It is filled straight from p and iint,
%              so that it can be used without worrying about rounding errors making it slightly different.
%   mess        Error message; empty if all was OK; non-empty otherwise (in which case all other output are empty)
%               Use this as the sole criterion of succesful operation because empty arrays for other outputs
%               can be valid e.g. iax=[] and iint=[] if all axes are plot axes.
%
% Notes:
%   - if the range of the data is zero along a plot axis, then the two bin boundaries
%    will both have the same value, even if a non-zero bin size was input.
%


% T.G.Perring   15/07/2007


% Check number and format of integration range / plotting description
% ------------------------------------------------------------------------
n=length(pbin);
if n<3 || n>4
    iax=[]; iint=[]; pax=[]; p=[]; urange=[];
    mess = 'Must provide binning descriptor for all three momentum axes and (optionally) the energy axis';
    return
end

if ~(isempty(pbin{1})||(isa_size(pbin{1},'row','double') && length(pbin{1})>=1 && length(pbin{1})<=3)) || ...
   ~(isempty(pbin{2})||(isa_size(pbin{2},'row','double') && length(pbin{2})>=1 && length(pbin{2})<=3)) || ...
   ~(isempty(pbin{3})||(isa_size(pbin{3},'row','double') && length(pbin{3})>=1 && length(pbin{3})<=3))
    iax=[]; iint=[]; pax=[]; p=[]; urange=[];
    mess = 'Check format of integration range / plotting description for momentum axes';
    return
end

if n==4
    if ~(isempty(pbin{4})||(isa_size(pbin{4},'row','double') && length(pbin{4})>=1 && length(pbin{4})<=3))
        iax=[]; iint=[]; pax=[]; p=[]; urange=[];
        mess = 'Check format of integration range / plotting description for energy axis';
        return
    end
end


% Check values are acceptable, and make ranges 1x3 (for plot) or 1x2 for integration axes
% ---------------------------------------------------------------------------------------
% At this point, we are just filling in the values for the missing elements according to
% the convention that missing ranges are +inf, -inf (upper, lower) and missing bin width
% for energy is 0.
% Will combine with the limits of the data in the block of code that follows the this block
npax = 0;
niax = 0;
pax = zeros(1,4);
iax = zeros(1,4);
p_from_pin = false(1,4);    % will contain true if bin boundaries are to be taken from defaults
vstep = zeros(4,1); % will contain requested step sizes
vlims = zeros(4,2); % will contain requested limits of bin centres / integration range
for idim=1:4
    if n==3     % case when energy axis not given
        pbin{4}=[-inf,0,inf];
    end
    if isempty(pbin{idim})
        % Could be integration axis or plot axis depending if number of bins=2 or >2
        if length(pin{idim})==2
            niax = niax + 1;
            iax(niax) = idim;
            vlims(idim,:) = pin{idim};
        elseif length(pin{idim})>2
            npax = npax + 1;
            pax(npax) = idim;
            p_from_pin(npax)=true;
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
            mess = 'Cannot have negative energy step size';
            return
        elseif idim~=4 && vstep(idim)==0
            iax=[]; iint=[]; pax=[]; p=[]; urange=[];
            mess = ['Cannot have zero step size for plotting - check axis ',num2str(idim)];
            return
        end
    end
    % check validity of data ranges
    if vlims(idim,2)<vlims(idim,1)
        iax=[]; iint=[]; pax=[]; p=[]; urange=[];
        mess = ['Check upper limit greater or equal to the lower limit - check axis ',num2str(idim)];
        return
    end
end
pax = pax(1:npax);
iax = iax(1:niax);


% Compute plot bin boundaries and integration ranges
% ------------------------------------------------------------------------
% Get range in output projection axes from the 8 points defined in momentum space by urange_in:
[x1,x2,x3]=ndgrid(urange_in(:,1)-trans(1),urange_in(:,2)-trans(2),urange_in(:,3)-trans(3));
vertex_in=[x1(:)';x2(:)';x3(:)'];
vertex_out = rot*vertex_in;
urange_out=[[min(vertex_out,[],2)';max(vertex_out,[],2)'],urange_in(:,4)];  % 2x4 array of limits in output proj. axes

p=cell(1,npax);
ok_range = true(4,1);

% Compute plot bin boundaries
for i=1:npax
    if p_from_pin(i)
        % Use default input bins
        p{i}=pin{pax(i)};
    else
        % Try to eliminate rounding errors where can - hence the not entirely obvious algorithm using nlo, nhi, and copious checks
        ipax = pax(i);
        if ipax<4 || (ipax==4 && vstep(ipax)>0)   % treat energy axis like other axes if provided with energy bin greater than zero
            if ~all(isfinite(vlims(ipax,:))==[1,1])     % one or both limits are not finite
                if all(isfinite(vlims(ipax,:))==[0,0])
                    nlo = floor((urange_out(1,ipax)-vstep(ipax)/2)/vstep(ipax));
                    nhi = ceil((urange_out(2,ipax)-vstep(ipax)/2)/vstep(ipax));
                    p{i} = (vstep(ipax)*(nlo:nhi))'+vstep(ipax)/2;
                    if p{i}(1)>urange_out(1,ipax)||p{i}(end)<urange_out(2,ipax)
                        if p{i}(1)>urange_out(1,ipax), nlo=nlo-1; end  % just in case of rounding errors
                        if p{i}(end)<urange_out(2,ipax), nhi=nhi+1; end  % just in case of rounding errors
                        p{i} = (vstep(ipax)*(nlo:nhi))'+vstep(ipax)/2;
                    end
                elseif all(isfinite(vlims(ipax,:))==[1,0])
                    p0  = vlims(ipax,1)-vstep(ipax)/2;
                    nlo = 0;
                    nhi = ceil((urange_out(2,ipax)-p0)/vstep(ipax));
                    p{i} = (p0 + vstep(ipax)*(nlo:nhi))';
                    if p{i}(end)<urange_out(2,ipax), p{i}=(p0 + vstep(ipax)*(nlo:nhi+1))'; end  % just in case of rounding errors
                elseif all(isfinite(vlims(ipax,:))==[0,1])
                    p0  = vlims(ipax,2)+vstep(ipax)/2;
                    nlo = floor((urange_out(1,ipax)-p0)/vstep(ipax));
                    nhi = 0;
                    p{i} = (p0 + vstep(ipax)*(nlo:nhi))';
                    if p{i}(1)>urange_out(1,ipax), p{i}=(p0 + vstep(ipax)*(nlo-1:nhi))'; end  % just in case of rounding errors
                end
            else
                p{i} = (vlims(ipax,1)-vstep(ipax)/2:vstep(ipax):vlims(ipax,2)+vstep(ipax)/2)';
                % In past had problems getting correct end element (rounding errors?) in the Matlab algorithm x1:x2:x3 so do following:
                if p{i}(end)<vlims(ipax,2)
                    p{i}=[p{i};p{i}(end)+vstep(ipax)];
                elseif p{i}(end-1)>=vlims(ipax,2)
                    p{i}=p{i}(1:end-1);
                end
                if numel(p{i})<=2
                    iax=[]; iint=[]; pax=[]; p=[]; urange=[];
                    str=str_compress(num2str([vlims(ipax,1),vstep(ipax),vlims(ipax,2)]));
                    mess=['Only one bin in range [',str,'] - cannot make this a plot axis'];
                    return
                end
            end
        else
            % Only reaches here if energy axis and requested energy bin width is explicity or implicitly zero
            % Handle this case differently to above, because we ensure bin boundaries synchronised to boundaries in array en
            den = (en(end)-en(1))/(length(en)-1); % default energy bin size
            nlo = floor((max(vlims(ipax,1),urange_out(1,ipax))-en(1))/den);
            nhi = ceil((min(vlims(ipax,2),urange_out(2,ipax))-en(end))/den);
            % If the requested bin limits or extent of the data are the same as the limits of the default bin
            % boundaries, then we are guaranteed to have nlo=nhi=0
            if nlo==nhi && nlo==0
                p{i} = en;
            else
                p{i} = (en(1)+den*(nlo:nhi+length(en)-1))';
            end
        end

        % Catch special cases
        if isempty(p{i})
            % occurs if one limit not finite; chose extent of data for that limit, and was inconsistent with the finite limit
            ok_range(ipax)=false;
        elseif length(p{i})==1
            % Occurs if the range of the data is zero - perfectly valid
            p{i}=[p{i},p{i}]';
        end

    end
end

% Compute integration ranges
iint=zeros(2,niax);
for i=1:niax
    iiax = iax(i);
    iint(1,i)=max(vlims(iiax,1),urange_out(1,iiax));
    iint(2,i)=min(vlims(iiax,2),urange_out(2,iiax));
    if iint(1,i)>iint(2,i)
        ok_range(iiax) = false;
    end
end

% Catch cases of range lying out outside input range
if ~isempty(find(~ok_range, 1))
    iax=[]; iint=[]; pax=[]; p=[]; urange=[];
    mess = ['Integration &/or plot range(s) outside extent of data - check axis number(s) ',num2str(find(~ok_range))];
    return
end

% Get range of data that encompasses the final integratin and plot ranges
% -------------------------------------------------------------------------
urange=zeros(2,4);
for i=1:npax
    ipax=pax(i);
    urange(:,ipax)=[p{i}(1);p{i}(end)];
end
if niax>0
    urange(:,iax)=iint;
end

mess=[];
