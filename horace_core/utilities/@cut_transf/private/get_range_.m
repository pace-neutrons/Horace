function range = get_range_(obj,dir)
% Return cut range in specified direction
% dir -- direction of cut (1,2 or 3)
%
% $Revision:: 1758 ($Date:: 2019-12-16 18:18:50 +0000 (Mon, 16 Dec 2019) $)
%
if dir<4
    shift = obj.zone_center(dir);
else
    shift = 0;
end
if isnan(obj.dqe_(dir))
    range = obj.qe_range_(dir,:)+shift;
else
    range = [obj.qe_range_(dir,1)+shift,...
        obj.dqe_(dir),obj.qe_range_(dir,2)+shift];
end


