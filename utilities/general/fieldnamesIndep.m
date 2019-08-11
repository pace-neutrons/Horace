function names = fieldnamesIndep(obj)
% Get the names of the independent properties of an object i.e. those that
% are not dependent, transient or constant (this is what the Matlab
% function 'save' does, according to the documentation of release 2019a)
%
% Use metaclass data to disocver the property names

if isobject(obj)
    mc = metaclass(obj);
    if ~isempty(mc)
        props = mc.PropertyList;   % to get pointer
        names = arrayfun(@(x)(x.Name),props,'UniformOutput',false);
        independent = ~arrayfun(@(x)(x.Dependent||x.Transient||x.Constant),props);
        names = names(independent);
    else    % old-stype matlab object (pre-R2008a)
        names = fieldnames(struct(obj));
    end
elseif isstruct(obj)
    names = fieldnames(struct(obj));
else
    error('Invalid input argument type. Input must be an object or a structure')
end
