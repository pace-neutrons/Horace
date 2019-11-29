function val = get_loader_field(this,field_name)
% function retrunds field name coordinaged with storage and data loader
%
if isempty(this.loader)
    val=[];
else
    val=this.loader__.(field_name);
end
