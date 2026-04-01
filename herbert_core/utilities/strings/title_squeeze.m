function tout=title_squeeze(tin)
% Remove empty cells in a cellstr vector and convert strings if present
% into character arrays.
%
% Usful tool for plot titles

if iscellstr(tin)
    ind=true(size(tin));
    for i=1:numel(tin)
        if isempty(tin{i})
            ind(i)=false;
        end
    end
    tout=tin(ind);
elseif isstring(tin)
    tout = {char(tin)};
elseif ischar(tin)
    tout = {tin};    
elseif iscell(tin)
    tin = cellfun(@(x)char(x),tin,'UniformOutput',false);
    tout = title_squeeze(tin);
else
    tout = {''};
end
