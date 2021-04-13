function [s, e, npix, img_range_step, npix_retain, ok, ix] = accumulate_cut_matlab_(s, e, npix, img_range_step, keep_pix,...
    v, proj, pax)

%function [s, e, npix, img_range_step, npix_retain, ok, ix] = accumulate_cut_matlab (s, e, npix, img_range_step, keep_pix,...
%    v, img_range_step, rot_ustep, trans_bott_left, ebin, trans_elo, pax)
% Accumulate signal into output arrays
%
% Syntax:
%   >> [s,e,npix,npix_retain] = accumulate_cut (s, e, npix, v, img_range_step, rot_ustep, trans_bott_left, ebin, trans_elo, pax, keep_pix)
%
% Input: (* denotes output argumnet with same name exists - exploits in-place working of Matlab R2007a)
% * s               Array of accumulated signal from all contributing pixels (dimensions match the plot axes)
% * e               Array of accumulated variance
% * npix            Array of number of contributing pixels
% * img_range_step Actual range of contributing pixels in the units of the
%                   pixel binning
%   keep_pix        Set to true if wish to retain the information about individual pixels; set to false if not
%   v               A PixelData object
%   img_range_step     [2x4] array of the ranges of the data as defined by (i) output proj. axes ranges for
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
%   img_range_step Actual range of contributing pixels
%   npix_retain     Number of pixels that contribute to the cut
%   ok              If keep_pix==true: v(:,ok) are the pixels that are retained; otherwise =[]
%   ix              If keep_pix==true: column vector of single bin index of each retained pixel; otherwise =[]
%
%
% Note:
% - Aim to take advantage of in-place working within accumulate_cut

% T.G.Perring   19 July 2007
%
%
% Temporary and ineffective solution to keep pixels double all through the
% Horace. TODO: redefine pixels as single and propagate it through all Horace
if isa(v.data,'single')
    v.data = double(v.data);
end

[indx,ok] = proj.get_contributing_pix_ind(v);
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
img_range_step = [min(img_range_step(1,:),min(indx,[],1));max(img_range_step(2,:),max(indx,[],1))];  % true range of data

indx = indx(:,pax); % Now keep only the plot axes with at least two bins
if ~isempty(pax)        % there is at least one plot axis with two or more bins
    indx=ceil(indx);    % indx contains the bin index for the plot axes (one row per pixel)
    indx(indx==0)=1;    % make sure index is between 1 and n
    s    = s    + accumarray(indx, v.signal(ok), size(s));
    e    = e    + accumarray(indx, v.variance(ok), size(s));
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
    s    = s    + sum(v.signal(ok));
    e    = e    + sum(v.variance(ok));
    npix = npix + size(indx,1);
    npix_retain = sum(ok(:));
    if keep_pix
        ix=ones(npix_retain,1);  % all retained pixels go into the one and only bin, by definition
    else
        ok=[];  % set to empty array
        ix=[];
    end
end
