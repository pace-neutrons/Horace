function wout = replicate (win,wref)
% replicate method - gataway to dnd object replication only.

% Original author: T.G.Perring
%
% $Revision$ ($Date$)

%Do some tests on win and wref, and then loop if win is an array:
if numel(wref)>1
    error('Reference object is an array of objects - it must be a single object for replicate to work');
end

%Initialise the output
for i=1:numel(win)
    wout(i)=wref;
end

for i=1:numel(win)
    if isa(wref,'sqw') % Must handle case that wref is sqw object, but win(i) is not.
        if isa(win(i),'d0d')||isa(win(i),'d1d')||isa(win(i),'d2d')||isa(win(i),'d3d')||isa(win(i),'d4d')
            %wout(i) = wref;
            wout(i).data = replicate_dnd(struct(win(i)),wref.data);
        elseif isa(win(i),'sqw')
            if ~is_sqw_type(win(i))
                %wout(i) = wref;
                wout(i).data = replicate_dnd(win(i).data,wref.data);
            else
                error('Replication of sqw data to higher dimensions not yet implemented. Convert to corresponding dnd object and replicate that.')
            end
        else
            error('Check input arguments to replicate - first argument must be dnd object')
        end
    else    % must be that win(i) is sqw object and wref is not
        if ~is_sqw_type(win(i))
            if isa(wref,'d0d')||isa(wref,'d1d')||isa(wref,'d2d')||isa(wref,'d3d')||isa(wref,'d4d')
                %wout(i) = sqw(wref);
                wout(i).data = replicate_dnd(win(i).data,struct(wref));
            else
                error('Check input arguments to replicate - first argument must be dnd object')
            end
        else
            error('Replication of sqw data to higher dimensions not yet implemented. Convert to corresponding dnd object and replicate that.')
        end
    end
end