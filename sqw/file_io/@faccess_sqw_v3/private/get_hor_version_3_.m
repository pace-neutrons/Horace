function [ok,obj] = get_hor_version_3_(obj,bytes)
% Try to interpret sequence of bytes as data containing Horace version 2 
%
%
ok = false;
n = typecast(bytes(1:4),'int32');
if n~=6
    return
end
name = char(bytes(4+1:4+n))';
if ~isvarname(name)
    return
end
if ~strcmp(name,'horace')
    return
end
version = typecast(bytes(4+n+1:4+n+8),'double');
if version == 3 
   ok = true;
else
   ok = false;
   return;
end
typestart = 4+n+8;
%
obj.type_start_pos_ = typestart;
obj.sqw_type_=logical(typecast(bytes(typestart+1:typestart+4),'int32'));
obj.num_dim_=typecast(bytes(typestart+5:typestart+8),'int32');





