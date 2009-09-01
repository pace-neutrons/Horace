function wout = replicate (win,wref)
% replicate method - gataway to dnd object replication only.

% Original author: T.G.Perring
%
% $Revision: 259 $ ($Date: 2009-08-18 13:03:04 +0100 (Tue, 18 Aug 2009) $)


if isa(wref,'sqw') % Must handle case that wref is sqw object, but win is not.
    if isa(win,'d0d')||isa(win,'d1d')||isa(win,'d2d')||isa(win,'d3d')||isa(win,'d4d')
        wout = wref;
        wout.data = replicate_dnd(struct(win),wref.data);
    elseif isa(win,'sqw')
        if ~is_sqw_type(win)
            wout = wref;
            wout.data = replicate_dnd(win.data,wref.data);
        else
            error('Replication of sqw data to higher dimensions not yet implemented. Convert to corresponding dnd object and replicate that.')
        end
    else
        error('Check input arguments to replicate - first argument must be dnd object')
    end
else    % must be that win is sqw object and wref is not
    if ~is_sqw_type(win)
        if isa(wref,'d0d')||isa(wref,'d1d')||isa(wref,'d2d')||isa(wref,'d3d')||isa(wref,'d4d')
            wout = sqw(wref);
            wout.data = replicate_dnd(win.data,struct(wref));
        else
            error('Check input arguments to replicate - first argument must be dnd object')
        end
    else
        error('Replication of sqw data to higher dimensions not yet implemented. Convert to corresponding dnd object and replicate that.')
    end
end
