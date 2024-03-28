function obj = check_and_set_img_range_(obj,val)
% Check if the image range attempted to set is correct and set correct
% value of the image range
%
if ~isnumeric(val)
    error('HORACE:sphere_axes:invalid_argument',...
        'Image range has to be numeric. Attempting to set type: %s',...
        class(val));
end
if any(size(val)~=[2,4])
    error('HORACE:sphere_axes:invalid_argument',...
        'correct image range have to be 2x4 array of min/max range values. Getting: %s',...
        disp2str(val));
end

undef = val == PixelDataBase.EMPTY_RANGE_;
if isempty(val) || any(undef(:))
    angular_undef = [inf,pi/2,pi;inf,0,-pi/2,-pi,-inf];
    if isempty(val)
        val  = angular_undef;
    else
        val(undef) = angular_undef(undef);
    end
    obj.img_range_ = val;
    if ~obj.angles_in_rad_(1)
        obj.img_range_(:,2) = rad2deg(obj.img_range_(:,2));
    end
    if ~obj.angles_in_rad_(2)
        obj.img_range_(:,3) = rad2deg(obj.img_range_(:,3));
    end
    obj.img_range_set_        = true;
    return;
end
if any(val(1,:)>val(2,:))
    mess = sprintf([...
        ' Image range Min value(s) : [%g, %g, %g, %g]\n',...
        ' exceeds its Max value(s) : [%g, %g, %g, %g]'],...
        val(1,:),val(2,:));
    % despite statement that it can take sprintf - like argument directly,
    % it does not accept these arguments correctly
    error('HORACE:sphere_axes:invalid_argument',mess);
end
if val(1,1)<0
    error('HORACE:sphere_axes:invalid_argument','minimal Q-value can not be negative');
end

obj.img_range_      = val;
obj.img_range_set_  = true;
