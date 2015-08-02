function   dnd_struct = get_dnd_data_(obj)
% function returns dnd data structure from dnd_sqw_data object
%
% Transitional function
%
dnd_struct = struct('filename','',...
    'filepath','' ,'title','','alatt',[],'angdeg','',...
    'uoffset',[],'u_to_rlu',[],'ulen',[],'ulabel',[],...
    'iax',[],'iint',[],'pax',[],'p',[],'dax',[],...
    's',[],'e',[],'npix',[]);

fields = fieldnames(dnd_struct);
for i=1:numel(fields)
    dnd_struct.(fields{i}) = obj.(fields{i});
end

