function   cell = get_unit_cell_(obj)
% return unit cell wich defines the form of the lattice cell in
% non-orthogonal case
if obj.nonorthogonal_
    if isempty(obj.w)
        w = cross(obj.u,obj.v);
    else
        w = obj.w;
    end
    cell = [obj.u(:),obj.v(:),w(:)];
    mc = max(cell(:));
    cell = cell/mc;
    cell = [cell,[0;0;0];[0,0,0,1]];
else
    cell = eye(4);
end