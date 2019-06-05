function names = fieldnamesIndep(obj)
% Get the names of the independent properties of an object
% Use metaclass data to disocver the property names

if isobject(obj)
    mc = metaclass(obj);
    if ~isempty(mc)
        props = mc.PropertyList;   % to get pointer
        nprops = numel(props);
        names = cell(nprops,1);
        dependent = false(nprops,1);
        for i=1:nprops
            names{i} = props(i).Name;
            dependent(i) = props(i).Dependent;
        end
        names = names(~dependent);
    else    % old-stype matlab object (pre-R2008a)
        names = fieldnames(struct(obj));
    end
elseif isstruct(obj)
    names = fieldnames(struct(obj));
else
    error('Invalid input argument type. Input must be an object or a structure')
end
