function [sel,ok,mess] = mask_points (win, varargin)
% TODO: Does not look like this function should be here
%
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
%   sel     Mask array of same shape as data_. true for bins to keep, false to discard.
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


% Set defaults:
arglist = struct('keep',[],'remove',[],'mask',[]);

% Parse parameters:
[args,options] = parse_arguments(varargin,arglist);

if ~isempty(args)
    error('HERBERT:mask_points:invalid_argument', 'Check number of arguments')
end

return_with_errors = nargout > 1;

if return_with_errors
    sel=[];
    ok=false;
    mess='';
end

% Check input parameters
if isa(win, 'sqw')
    data = win.data;
else
    data = win;
end

ndim = dimensions(data);

if ~isempty(options.keep)
    xkeep=options.keep;

    try
        validateattributes(xkeep, {'numeric'}, {'size', [NaN, ndim*2]}, 'mask_points', 'keep')
    catch ME
        if return_with_errors
            mess = ME.message;
            return
        else
            rethrow(ME)
        end
    end

else
    xkeep=[];
end

if ~isempty(options.remove)
    xremove=options.remove;

    try
        validateattributes(xremove, {'numeric'}, {'size', [NaN, ndim*2]}, 'mask_points', 'remove')
    catch ME
        if return_with_errors
            mess = ME.message;
            return
        else
            rethrow(ME)
        end
    end
else
    xremove=[];
end

if ~isempty(options.mask)
    mask=options.mask;

    try
        validateattributes(mask, {'numeric', 'logical'}, {'numel', numel(data.s)}, ...
                           'mask_points', 'mask')
    catch ME
        if return_with_errors
            mess = ME.message;
            return
        else
            rethrow(ME)
        end
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
    xkeep_lo=reorder(xkeep_lo,data.dax);    % reorder into order of plot axes
    xkeep_hi=reorder(xkeep_hi,data.dax);    % reorder into order of plot axes
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
    xremove_lo=reorder(xremove_lo,data.dax);    % reorder into order of plot axes
    xremove_hi=reorder(xremove_hi,data.dax);    % reorder into order of plot axes
    remove_volume=true(nr);   % true if the range is in the data volume, false otherwise
    irlo=ones(nr,4);
    irhi=ones(nr,4);
else
    nr=0;
end

% Find indices of sub-sections of the data array of points to keep and remove
if nk > 0 || nr > 0
    for idim=1:ndim
        % Find bin centres (pcent=centre of p)
        pcent=0.5*(data.p{idim}(1:end-1)+data.p{idim}(2:end));
        for ik=1:nk
            % find indices of points to keep for each range along the given axis
            ind=find(pcent>=xkeep_lo(ik,1,idim) & pcent<=xkeep_hi(ik,1,idim));
            if ~isempty(ind)
                iklo(ik,idim)=ind(1);
                ikhi(ik,idim)=ind(end);
            else
                keep_volume(ik)=false;
            end
        end
        for ir=1:nr
            % find indices of points to remove for each range along the given axis
            ind=find(pcent>=xremove_lo(ir,1,idim) & pcent<=xremove_hi(ir,1,idim));
            if ~isempty(ind)
                irlo(ir,idim)=ind(1);
                irhi(ir,idim)=ind(end);
            else
                remove_volume(ir)=false;
            end
        end
    end
end

% Now remove the points
if ~isempty(xkeep)
    keep = false(size(data.s));
    for ik=1:nk
        if keep_volume(ik)
            keep(iklo(ik,1):ikhi(ik,1),iklo(ik,2):ikhi(ik,2),iklo(ik,3):ikhi(ik,3),iklo(ik,4):ikhi(ik,4)) = true;
        end
    end
    if ~any(keep)
        mess='There are no points within the range(s) specified to be retained';
        sel = false(size(data.s));
        ok = true;
        if ~return_with_errors, disp(mess), end
        return
    end
else
    keep = true(size(data.s));
end

if ~isempty(xremove)
    remove = false(size(data.s));
    for ir=1:nr
        if remove_volume(ir)
            remove(irlo(ir,1):irhi(ir,1),irlo(ir,2):irhi(ir,2),irlo(ir,3):irhi(ir,3),irlo(ir,4):irhi(ir,4)) = true;
        end
    end
    if all(remove)
        mess='All points have been eliminated by the range(s) specified to be removed';
        sel = false(size(data.s));
        ok = true;
        if ~return_with_errors, disp(mess), end
        return
    end
else
    remove = false(size(data.s));
end

if ~isempty(mask)
    mask=logical(reshape(mask,size(data.s))); % initialise output selection array
    if ~any(mask)
        mess='The input mask array masks all data points';
        sel = false(size(data.s));
        ok = true;
        if ~return_with_errors, disp(mess), end
        return
    end
else
    mask=true(size(data.s));
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
