function wout = replicate (win,wref)
% replicate method - gataway to dnd object replication only.

% Original author: T.G.Perring
%
% $Revision$ ($Date$)

% Do some tests on win and wref, and then loop if win is an array:
if numel(wref)>1
    error('Reference object is an array of objects - it must be a single object for replicate to work');
end

% All elements of win have the same class, so do the loop over elements at the innermost line, not the outermost
if isa(wref,'sqw') % Must handle case that wref is sqw object, but win is not.
    if isa(win,'d0d')||isa(win,'d1d')||isa(win,'d2d')||isa(win,'d3d')||isa(win,'d4d')
        wout = repmat(wref,size(win)); % do not use for loop to initialise output - very inefficient!
        for i=1:numel(win), wout(i).data = replicate_dnd(struct(win(i)),wref.data); end
    elseif isa(win,'sqw')
        if ~is_sqw_type(win)
            wout = repmat(wref,size(win));
            for i=1:numel(win), wout(i).data = replicate_dnd(win(i).data,wref.data); end
        else
            error('Replication of sqw data to higher dimensions not yet implemented. Convert to corresponding dnd object and replicate that.')
        end
    else
        error('Check input arguments to replicate - first argument must be dnd object')
    end
else    % must be that win is sqw object and wref is not
    if ~is_sqw_type(win)
        if isa(wref,'d0d')||isa(wref,'d1d')||isa(wref,'d2d')||isa(wref,'d3d')||isa(wref,'d4d')
            wout = repmat(sqw(wref),size(win));
            for i=1:numel(win), wout(i).data = replicate_dnd(win(i).data,struct(wref)); end
        else
            error('Check input arguments to replicate - first argument must be dnd object')
        end
    else
        error('Replication of sqw data to higher dimensions not yet implemented. Convert to corresponding dnd object and replicate that.')
    end
end
