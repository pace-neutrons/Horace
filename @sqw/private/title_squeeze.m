function tout=title_squeeze(tin)
% Remove empty cells in a cellstr vector.
% Usful tool for plot titles

if iscellstr(tin)
    ind=true(size(tin));
    for i=1:numel(tin)
        if isempty(tin{i})
            ind(i)=false;
        end
    end
    tout=tin(ind);
end
