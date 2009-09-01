function [s, e, npix, urange_step_pix, npix_retain, ok, ix] = accumulate_cut (s, e, npix, urange_step_pix, keep_pix,...
                                                      v, urange_step, rot_ustep, trans_bott_left, ebin, trans_elo, pax)
% Accumulate signal into output arrays
%
% Syntax:
%   >> [s,e,npix,npix_retain] = accumulate_cut (s, e, npix, v, urange_step, rot_ustep, trans_bott_left, ebin, trans_elo, pax, keep_pix)
%
% Input: (* denotes output argumnet with same name exists - exploits in-place working of Matlab R2007a)
% * s               Array of accumulated signal from all contributing pixels (dimensions match the plot axes)
% * e               Array of accumulated variance
% * npix            Array of number of contributing pixels
% * urange_step_pix Actual range of contributing pixels
%   keep_pix        Set to true if wish to retain the information about individual pixels; set to false if not
%   v(9,:)          u1,u2,u3,u4,irun,idet,ien,s,e for each pixel, where ui are coords in projection axes of the pixel data in the file
%   urange_step     [2x4] array of the ranges of the data as defined by (i) output proj. axes ranges for
%                  integration axes (or plot axes with one bin), and (ii) step range (0 to no. bins)
%                  for plotaxes (with more than one bin)
%   rot_ustep       Matrix [3x3]     --|  that relate a vector expressed in the
%   trans_bott_left Translation [3x1]--|  frame of the pixel data to no. steps from lower data limit
%                                             r_step(i) = A(i,j)(r(j) - trans(j))
%   ebin            Energy bin width (plays role of rot_ustep for energy axis)
%   trans_elo       Bottom of energy scale (plays role of trans_bott_left for energy axis)
%   pax             Indices of plot axes (with two or more bins) [row vector]
%
% Output:
%   s               Array of accumulated signal from all contributing pixels (dimensions match the plot axes)
%   e               Array of accumulated variance
%   npix            Array of number of contributing pixels
%   urange_step_pix Actual range of contributing pixels
%   npix_retain     Number of pixels that contribute to the cut
%   ok              If keep_pix==true: v(:,ok) are the pixels that are retained; otherwise =[]
%   ix              If keep_pix==true: column vector of single bin index of each retained pixel; otherwise =[]
%
%
% Note:
% - Aim to take advantage of in-place working within accumulate_cut

% T.G.Perring   19 July 2007

% Transform the coordinates u1-u4 into the new projection axes, if necessary
if ebin==1 && trans_elo==0   % Catch special (and common) case of energy being an integration axis to save calculations
    indx=[(v(1:3,:)'-repmat(trans_bott_left',[size(v,2),1]))*rot_ustep',v(4,:)'];  % nx4 matrix
else
    indx=[(v(1:3,:)'-repmat(trans_bott_left',[size(v,2),1]))*rot_ustep',(v(4,:)'-trans_elo)*(1/ebin)];  % nx4 matrix
end

% Find the points that lie inside or on the boundary of the range of the cut
ok = indx(:,1)>=urange_step(1,1) & indx(:,1)<=urange_step(2,1) & indx(:,2)>=urange_step(1,2) & indx(:,2)<=urange_step(2,2) & ...
     indx(:,3)>=urange_step(1,3) & indx(:,3)<=urange_step(2,3) & indx(:,4)>=urange_step(1,4) & indx(:,4)<=urange_step(2,4);

% Check for the case when either data.s or data.e contain NaNs or Infs, but data.npix is not zero.
% and handle according to options settings.
ignore=horace_cut_nan_inf;
if ignore.nan || ignore.inf
    if ignore.nan && ignore.inf
        omit=~isfinite(v(8,:))|~isfinite(v(9,:));
    elseif ignore.nan
        omit=isnan(v(8,:))|isnan(v(9,:));
    elseif ignore.inf
        omit=isinf(v(8,:))|isinf(v(9,:));
    end
    ok = ok & ~omit';
end

% Continue
indx=indx(ok,:);    % get good indices (including integration axes and plot axes with only one bin)
if isempty(indx)    % if no pixels in range, return
    npix_retain=0;
    if keep_pix
        ix=ones(0,1);   % for consistency with case when indx is not empty
    else
        ok=[];  % set to empty array
        ix=[];
    end
    return
end
urange_step_pix = [min(urange_step_pix(1,:),min(indx,[],1));max(urange_step_pix(2,:),max(indx,[],1))];  % true range of data

indx = indx(:,pax); % Now keep only the plot axes with at least two bins
if ~isempty(pax)        % there is at least one plot axis with two or more bins
    indx=ceil(indx);    % indx contains the bin index for the plot axes (one row per pixel)
    indx(indx==0)=1;    % make sure index is between 1 and n
    s    = s    + accumarray(indx, v(8,ok), size(s));
    e    = e    + accumarray(indx, v(9,ok), size(s));
    npix = npix + accumarray(indx, ones(1,size(indx,1)), size(s));
    npix_retain = length(indx);
    % If keeping the information about individual pixels, get that information and single index into the column representation
    if keep_pix
        ixcell=cell(1,length(pax)); % cell array that will contain the indices for each plot axis (as required by matlab function sub2ind)
        for i=1:length(pax)
            ixcell{i}=indx(:,i);
        end
        ix=sub2ind(size(s),ixcell{:});  % column vector of single index of the retained pixels
    else
        ok=[];  % set to empty array
        ix=[];
    end
else
    s    = s    + sum(v(8,ok));
    e    = e    + sum(v(9,ok));
    npix = npix + size(indx,1);
    npix_retain = sum(ok(:));
    if keep_pix
        ix=ones(npix_retain,1);         % all retained pixels go into the one and only bin, by definition
    else
        ok=[];  % set to empty array
        ix=[];
    end
end
