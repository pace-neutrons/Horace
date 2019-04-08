function [sel,ok,mess] = mask_points (win, varargin)
% Determine the points to keep on the basis of ranges and mask array.
%
%   >> sel = mask_points (win, 'keep', xkeep, 'remove', xremove, 'mask', mask)
%
% or any selection (in any order) of the keyword-argument pairs e.g.
%
%   >> sel = mask_points (win, 'mask', mask, 'remove', xremove)
%
% Input:
% ------
%   win     Input sqw object
%
%   xkeep   Ranges of display axes to retain for fitting. A range is specified by an array
%           of numbers which define a hypercube.
%           For example in case of two dimensions:
%               [xlo, xhi, ylo, yhi]  
%           or in the case of n-dimensions:
%               [x1_lo, x1_hi, x2_lo, x2_hi,..., xn_lo, xn_hi]
%
%              e.g. 1D: [50,70]
%                   2D: [1,2,130,160]
%
%           More than one range can be defined in rows,
%               [Range_1; Range_2; Range_3;...; Range_m]
%             where each of the ranges are given in the format above.
%
%   xremove Ranges of display axes to remove from fitting.
%
%   mask    Mask array of same number of elements as data array: 1 to keep, 0 to remove
%               Note: mask will be applied to the stored data array
%              according as the projection axes, not the display axes.
%              Thus permuting the display axes does not alter the
%              effect of masking the data. The mask array works
%              consistently with the input required by the mask method.
%
% Output:
% -------
%   sel     Mask array of same shape as data. true for bins to keep, false to discard.
%
% 
%  Advanced use: in addition the following two arguments, if present, suppress failure or the
%  display of informational messges. Instead, the messages are returned to be used as desired.
%
%   ok      =true if worked, =false if error
%
%   mess    messages: if ok=true then informational or warning, if ok=false then the error message


% Original author: T.G.Perring
%
% $Revision:: 1750 ($Date:: 2019-04-08 17:55:21 +0100 (Mon, 8 Apr 2019) $)


% Set defaults:
arglist = struct('keep',[],'remove',[],'mask',[]);

% Parse parameters:
[args,options] = parse_arguments(varargin,arglist);

if numel(args)~=0
    error('Check number of arguments')
end

if nargout>1
    return_with_errors=true;
    sel=[];
    ok=false;
    mess='';
else
    return_with_errors=false;
end

% Check input parameters
ndim=length(win.data.pax);
if ~isempty(options.keep)
    xkeep=options.keep;
    if ~isnumeric(xkeep) || size(xkeep,2)/2~=ndim || length(size(xkeep))~=2
        mess=(['''keep'' must provide a numeric array of size r x 2n, where n=number of dimensions (n=',num2str(ndim),')']);
        if return_with_errors, return, else error(mess), end
    end
else
    xkeep=[];
end

if ~isempty(options.remove)
    xremove=options.remove;
    if ~isnumeric(xremove) || size(xremove,2)/2~=ndim || length(size(xremove))~=2
        mess=(['''remove'' must provide a numeric array of size r x 2n, where n=number of dimensions (n=',num2str(ndim),')']);
        if return_with_errors, return, else error(mess), end
    end
else
    xremove=[];
end

if ~isempty(options.mask)
    mask=options.mask;
    if ~(isnumeric(mask) || islogical(mask)) || numel(mask)~=numel(win.data.s)
        mess='''mask'' must provide a numeric or logical array with same number of elements as the data';
        if return_with_errors, return, else error(mess), end
    end
else
    mask=[];
end


% Sort the ranges
if ~isempty(xkeep)
    nk=size(xkeep,1);
    tmp=reshape(xkeep,[nk,2,ndim]);
    xkeep_lo=min(tmp,[],2);
    xkeep_hi=max(tmp,[],2);
    xkeep_lo=reorder(xkeep_lo,win.data.dax);    % reorder into order of plot axes
    xkeep_hi=reorder(xkeep_hi,win.data.dax);    % reorder into order of plot axes
    keep_volume=true(nk);      % true if the range is in the data volume, false otherwise
    iklo=ones(nk,4);
    ikhi=ones(nk,4);
else
    nk=0;
end

if ~isempty(xremove)
    nr=size(xremove,1);
    tmp=reshape(xremove,[nr,2,ndim]);
    xremove_lo=min(tmp,[],2);
    xremove_hi=max(tmp,[],2);
    xremove_lo=reorder(xremove_lo,win.data.dax);    % reorder into order of plot axes
    xremove_hi=reorder(xremove_hi,win.data.dax);    % reorder into order of plot axes
    remove_volume=true(nr);   % true if the range is in the data volume, false otherwise
    irlo=ones(nr,4);
    irhi=ones(nr,4);
else
    nr=0;
end

% Find indicies of sub-sections of the data array of points to keep and remove
for idim=1:ndim
    pcent=0.5*(win.data.p{idim}(1:end-1)+win.data.p{idim}(2:end));
    for ik=1:nk
        % find indicies of points to keep for each range along the given axis
        ind=find(pcent>=xkeep_lo(ik,1,idim) & pcent<=xkeep_hi(ik,1,idim));
        if ~isempty(ind)
            iklo(ik,idim)=ind(1);
            ikhi(ik,idim)=ind(end);
        else
            keep_volume(ik)=false;
        end
    end
    for ir=1:nr
        % find indicies of points to remove for each range along the given axis
        ind=find(pcent>=xremove_lo(ir,1,idim) & pcent<=xremove_hi(ir,1,idim));
        if ~isempty(ind)
            irlo(ir,idim)=ind(1);
            irhi(ir,idim)=ind(end);
        else
            remove_volume(ir)=false;
        end
    end
end

% Now remove the points
if ~isempty(xkeep)
    keep = false(size(win.data.s));
    for ik=1:nk
        if keep_volume(ik)
            keep(iklo(ik,1):ikhi(ik,1),iklo(ik,2):ikhi(ik,2),iklo(ik,3):ikhi(ik,3),iklo(ik,4):ikhi(ik,4)) = true;
        end
    end
    if ~any(keep)
        mess='There are no points within the range(s) specified to be retained';
        sel = false(size(win.data.s));
        ok = true;
        if ~return_with_errors, disp(mess), end
        return
    end
else
    keep = true(size(win.data.s));
end

if ~isempty(xremove)
    remove = false(size(win.data.s));
    for ir=1:nr
        if remove_volume(ir)
            remove(irlo(ir,1):irhi(ir,1),irlo(ir,2):irhi(ir,2),irlo(ir,3):irhi(ir,3),irlo(ir,4):irhi(ir,4)) = true;
        end
    end
    if all(remove)
        mess='All points have been eliminated by the range(s) specified to be removed';
        sel = false(size(win.data.s));
        ok = true;
        if ~return_with_errors, disp(mess), end
        return
    end
else
    remove = false(size(win.data.s));
end

if ~isempty(mask)
    mask=logical(reshape(mask,size(win.data.s))); % initialise output selection array
    if ~any(mask)
        mess='The input mask array masks all data points';
        sel = false(size(win.data.s));
        ok = true;
        if ~return_with_errors, disp(mess), end
        return
    end
else
    mask=true(size(win.data.s));
end

sel = keep & ~remove & mask;
ok = true;
mess = '';

%===========================================================================
function xout=reorder(xin,dax)
% Reorder the (nk x 1 x ndim) arrays that define the limits so that
% the outer dimension refers to the plot axes, not display axes
xout=zeros(size(xin));
for i=1:numel(dax)
    xout(:,:,dax(i))=xin(:,:,i);
end
