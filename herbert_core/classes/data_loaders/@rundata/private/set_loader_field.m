function this=set_loader_field(this,field_name,val)
% these
if isempty(this.loader) 
    %TODO: should be specific loader for that
    this.loader__=loader_nxspe();
end
this.loader__.(field_name)=val;

