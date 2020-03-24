function obj=set_loader_field(obj,field_name,val)
% these
if isempty(obj.loader)
    if isempty(val)
        return;
    else
        %TODO: should be specific loader for that
        obj.loader__=loader_nxspe();        
    end
end
obj.loader__.(field_name)=val;

