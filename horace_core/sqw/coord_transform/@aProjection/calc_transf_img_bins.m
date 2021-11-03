function [iax, iint, pax, p, img_db_range_out] = calc_transf_img_bins(proj,img_db_range_in,pbin, pin, en)
% Build the binning and axis for the coordinate system related to cut 
%
% Create bin boundaries for integration and plot axes from requested limits and step sizes
% for the cut, defined by the new projection.
%
% Uses knowledge of the range of the initial image and energy bins of the image to set values for those
% not provided.
%
%   >> [iax, iint, pax, p, img_db_range, pbin_out] =  proj.calc_transformed_img_bins(img_db_range_in, pbin, pin, en)
%
%      Throws aPROJECTION:invalid_arguments if input parameters are
%      inconsistent or incorrect
%
% Input:
% ------
%   img_db_range_in  [2x4] array of range of pixels along the initial projection axes (elements must all be finite)
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
%                                  chosen to ensure that the energy range in img_db_range_in is contained within
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
%              in which case all other output are empty
%   iax         Index of integration axes into the projection axes  [row vector]
%                   e.g. if data is 2D, data.iax=[1,3] means summation has been performed along u1 and u3 axes
%   iint        Integration range along each of the integration axes. [iint(2,length(iax))]
%                   e.g. in 2D case above, is the matrix vector [u1_lo, u3_lo; u1_hi, u3_hi]
%   pax         Index of plot axes into the projection axes  [row vector]
%                   e.g. if data is 3D, data.pax=[1,3,4] means u1, u3, u4 axes are x,y,z in any plotting
%   p           Call array containing bin boundaries along the plot axes [column vectors]
%                   i.e. data.p{1}, data.p{2} ... (for as many plot axes as given by length of data.pax)
%   img_db_range_out  Array of limits of data that can possibly contribute to the output data structure in the
%               coordinate frame of the output structure [2x4].


% T.G.Perring   15/07/2007


% Check number and format of integration range / plotting description
% ------------------------------------------------------------------------
n=length(pbin);
if n<3 || n>4
    error('aPROJECTION:invalid_arguments',...
        'Have not provided binning descriptor for all three momentum axes and (optionally) the energy axis');
end

if ~(isempty(pbin{1})||(isa_size(pbin{1},'row','double') && length(pbin{1})>=1 && length(pbin{1})<=3)) || ...
        ~(isempty(pbin{2})||(isa_size(pbin{2},'row','double') && length(pbin{2})>=1 && length(pbin{2})<=3)) || ...
        ~(isempty(pbin{3})||(isa_size(pbin{3},'row','double') && length(pbin{3})>=1 && length(pbin{3})<=3))
    
    error('aPROJECTION:invalid_arguments',...
        'Check format of integration range / plotting description for momentum axes');
end

if n==4
    if ~(isempty(pbin{4})||(isa_size(pbin{4},'row','double') && length(pbin{4})>=1 && length(pbin{4})<=3))
        error('aPROJECTION:invalid_arguments',...
            'Check format of integration range / plotting description for energy axis');
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
cut_lmts_req = zeros(4,2); % will contain requested limits of bin centres / integration range
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
            cut_lmts_req(idim,:) = pin{idim};
        elseif length(pin{idim})>2
            npax = npax + 1;
            pax(npax) = idim;
            vstep(idim) = pin{idim}(2)-pin{idim}(1);    % not used as of 13/5/09, but put here for completeness
            cut_lmts_req(idim,:) = [pin{idim}(1),pin{idim}(end)];
        end
    elseif length(pbin{idim})==2
        % the case of an integration axis
        niax = niax + 1;
        iax(niax) = idim;
        cut_lmts_req(idim,:) = pbin{idim};
    else
        % must be a plot axis
        npax = npax + 1;
        pax(npax) = idim;
        if length(pbin{idim})==1
            vstep(idim) = pbin{idim}(1);
            cut_lmts_req(idim,:) = [-inf,inf];
        elseif length(pbin{idim})==3
            vstep(idim) = pbin{idim}(2);
            cut_lmts_req(idim,:) = [pbin{idim}(1),pbin{idim}(3)];
        end
        % Check validity of step sizes
        if idim==4 && vstep(idim)<0 % recall that step of zero is valid for energy axis
            error('aPROJECTION:invalid_arguments',...
                'Cannot have negative energy step size');
        elseif idim~=4 && vstep(idim)<=0
            error('aPROJECTION:invalid_arguments',...
                'Cannot have zero step size for plotting - check axis  N: %d',num2str(idim));
            
        end
    end
    % check validity of data ranges
    if cut_lmts_req(idim,2)<cut_lmts_req(idim,1)
        error('aPROJECTION:invalid_arguments',...
            'Check upper limit greater or equal to the lower limit - check axis N: %d',idim);
    end
end
% Compact down iax and pax
pax = pax(1:npax);
iax = iax(1:niax);


% Compute plot bin boundaries and integration ranges
% ------------------------------------------------------------------------
% Get range of initial data, expressed in the coordinate frame of requested
% projection from the 8 points defined in momentum space by img_db_range_in:
% This gives the maximum extent of the image pixels that can possibly contribute to the output data.
% third coordinate is not used.
old_img_db_range = proj.find_old_img_range(img_db_range_in);

% Compute plot bin boundaries and range that fully encloses the requested output plot axes
iint=zeros(2,niax);
p   =cell(1,npax);
img_db_range_out=zeros(2,4);
%pbin_out = cell(1,4);

for i=1:npax
    ipax = pax(i);
    if pbin_from_pin(ipax)
        % Use default input bins
        p{i}=pin{ipax};
        %pbin_out{ipax} = make_const_bin_boundaries_descr(p{i});
    else
        pbin_tmp=[cut_lmts_req(ipax,1),vstep(ipax),cut_lmts_req(ipax,2)];
        if ipax<4 || (ipax==4 && vstep(ipax)>0)
            % Q axes, and also treat energy axis like other axes if provided with energy bin greater than zero
            p{i}=make_const_bin_boundaries(pbin_tmp,old_img_db_range(:,ipax));
        else
            % Only reaches here if energy axis and requested energy bin width is explicity or implicitly zero
            % Handle this case differently to above, because we ensure bin boundaries synchronised to boundaries in array en
            p{i}=make_const_bin_boundaries(pbin_tmp,old_img_db_range(:,ipax),en,true);
        end
        % No bins
        if isempty(p{i})
            error('aPROJECTION:invalid_arguments',...
                'Plot range outside extent of data for at least one plot axis (axis N%d)',i);
        end
        % For a plot axis we have declared that we need at least two bins
        if numel(p{i})<=2
            str=str_compress(num2str(pbin_tmp));
            mess=['Only one bin in range [',str,'] - cannot make this a plot axis'];
            error('aPROJECTION:invalid_arguments',mess)
        end
        %pbin_out{ipax} = pbin_tmp;
    end
    img_db_range_out(:,ipax)=[p{i}(1);p{i}(end)];
end

% Compute integration ranges.
for i=1:niax
    iiax = iax(i);
    iint(1,i)=cut_lmts_req(iiax,1);
    iint(2,i)=cut_lmts_req(iiax,2);
    % force new binning ranges for integration axis regardless to actual
    % data range
    %img_db_range_out(1,iiax) =vlims(iiax,1);
    %img_db_range_out(2,iiax) =vlims(iiax,2);
    % Select the range - union between image range and the requested cut range
    [img_db_range_out(1,iiax),img_db_range_out(2,iiax),inf_removed] =...
        min_max_range(cut_lmts_req(iiax,1),old_img_db_range(1,iiax),...
        cut_lmts_req(iiax,2),old_img_db_range(2,iiax));
    if inf_removed
        iint(1,i)=img_db_range_out(1,iiax);
        iint(2,i)=img_db_range_out(2,iiax);
    end
    
    if img_db_range_out(1,iiax)>img_db_range_out(2,iiax)
        % *** T.G.Perring 28 Sep 2018:********************
        img_db_range_out(2,iiax) = img_db_range_out(1,iiax);    % do not want to stop the cutting - just want to ensure no unnecessary read from input object or cut
        %         iax=[]; iint=[]; pax=[]; p=[]; img_db_range=[];
        %         ok = false;
        %         mess = sprintf('Integration range outside extent of data for projection axis %d (integration axis %d)',iiax,i);
        %         return
        % ************************************************
    end
    %pbin_out{iiax} = vlims(iiax,:)';
end

function [a_min,a_max,inf_removed]=min_max_range(min_range1,min_range2,max_range1,max_range2)
% calculate minimal enclosing range -- intersect of two overlapping ranges
inf_removed = false;
if isinf(min_range1)
    min_range1 = min_range2;
    inf_removed = true;
end
if isinf(max_range1)
    max_range1 = max_range2;
    inf_removed = true;
end
center = 0.5*(min(min_range1,min_range2)+max(max_range1,max_range2));

a_min = max(min_range1-center,min_range2-center)+center;
a_max = min(max_range1-center,max_range2-center)+center;
