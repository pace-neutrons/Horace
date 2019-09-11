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
        np = numel(props);
        names = cell(np,1);
        independent = false(np,1);
        for i=1:np
            prop = props(i);
            names{i} = prop.Name;
            independent(i) = ~(prop.Dependent||prop.Transient||prop.Constant);
        end
        names = names(independent);
    else    % old-type matlab object (pre-R2008a)
        names = fieldnames(struct(obj));
    end
elseif isstruct(obj)
    names = fieldnames(struct(obj));
else
    error('Invalid input argument type. Input must be an object or a structure')
end



%==========================================================================
% Newer version:
% ==============

% function names = fieldnamesIndep(obj)
% % Get the names of the independent properties of an object i.e. those that
% % are not dependent, transient or constant (this is what the Matlab
% % function 'save' does, according to the documentation of release 2019a)
% %
% % Use metaclass data to disocver the property names
%
% if isobject(obj)
%     mc = metaclass(obj);
%     if ~isempty(mc)
%         props = mc.PropertyList;   % to get pointer
%         [names,independent] = arrayfun(@(x)(nameIndep(x)),props,'UniformOutput',false);
%         names = names(cell2mat(independent));
%     else    % old-type matlab object (pre-R2008a)
%         names = fieldnames(struct(obj));
%     end
% elseif isstruct(obj)
%     names = fieldnames(struct(obj));
% else
%     error('Invalid input argument type. Input must be an object or a structure')
% end
%
% %--------------------------------------------------------------------------
% function [name,independent] = nameIndep (prop)
% name = prop.Name;
% independent = ~(prop.Dependent||prop.Transient||prop.Constant);


%==========================================================================
% Original version:
% =================
%
% function names = fieldnamesIndep(obj)
% % Get the names of the independent properties of an object i.e. those that
% % are not dependent, transient or constant (this is what the Matlab% % function 'save' does, according to the documentation of release 2019a)
% %
% % Use metaclass data to disocver the property names
%
% if isobject(obj)
%     mc = metaclass(obj);
%     if ~isempty(mc)
%         props = mc.PropertyList;   % to get pointer
%         names = arrayfun(@(x)(x.Name),props,'UniformOutput',false);
%         independent = ~arrayfun(@(x)(x.Dependent||x.Transient||x.Constant),props);
%         names = names(independent);
%     else    % old-type matlab object (pre-R2008a)
%         names = fieldnames(struct(obj));
%     end
% elseif isstruct(obj)
%     names = fieldnames(struct(obj));
% else
%     error('Invalid input argument type. Input must be an object or a structure')
% end
