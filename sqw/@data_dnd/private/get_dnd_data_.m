function   dnd_struct = get_dnd_data_(obj,varargin)
% function returns dnd data structure from dnd_sqw_data object
%
% Transitional function
%
    
dnd_struct = struct('filename','',...
    'filepath','' ,'title','','alatt',[],'angdeg','',...
    'uoffset',[],'u_to_rlu',[],'ulen',[],'ulabel',[],...
    'iax',[],'iint',[],'pax',[],'p',[],'dax',[],...
    's',[],'e',[],'npix',[],'urange',[]);
dnd_fields = {'filename','filepath','title','alatt','angdeg','s','e','npix'};
proj_fields = {'uoffset','iax','p','iint','ulen','ulabel','pax','dax'};
    

%?
if nargin>1
    dnd_struct.urange = [];
end


for i=1:numel(dnd_fields)
    fld = dnd_fields{i};
    dnd_struct.(fld) = obj.(fld);
end
% transient interface has been attached to data_sqw_dnd
for i=1:numel(proj_fields)
    fld = proj_fields{i};
    dnd_struct.(fld) = obj.(fld);
end
if isa(obj.proj,'projection')
    dnd_struct.u_to_rlu = obj.proj.u_to_rlu;
end
