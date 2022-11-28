function [is,unique_ind] = contains_(obj,template,nout)
% check if the container has the objects of the class "template"
% if the template is char, or the the object equal to template, if the
% template is the object of the kind, stored in the container
%
% Inputs:
% template-- the sample, to verify presence in the container
% Outputs:
% is      -- true if the template is present in the container and
%            false -- otherwise.
% unique_ind
%         -- if requested, the positions of the sample in the
%            unique objects container

if (ischar(template) && ~strcmp(obj.baseclass_,'char')) || ...   % compare against type
        (isstring(template) && ~strcmp(obj.baseclass_,'string')) % check type
    belongs = cellfun(@(x)isa(x,template),obj.unique_objects_);
    is = any(belongs);
    if nout > 1
        unique_ind = find(belongs);
    else
        unique_ind = [];
    end
else % compare agains value
    the_hash = obj.hashify(template);
    if nout == 1
        is = ismember(the_hash,obj.stored_hashes_);
        unique_ind = [];
    else
        belongs = ismember(obj.stored_hashes_,the_hash);
        is = any(belongs);
        unique_ind = find(belongs);
    end
end
