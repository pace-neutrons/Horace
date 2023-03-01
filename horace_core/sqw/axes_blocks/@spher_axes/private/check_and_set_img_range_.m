function obj = check_and_set_img_range_(obj,val)
% Check if the image range attempted to set is correct and set correct
% value of the image range
%
if ~isnumeric(val)
    error('HORACE:spher_axes:invalid_argument',...
        'Image range has to be numeric. Attempting to set type: %s',...
        class(val));
end
if any(size(val)~=[2,4])
    error('HORACE:spher_axes:invalid_argument',...
        'correct image range have to be 2x4 array of min/max range values. Getting: %s',...
        evalc('disp(val)'));
end

undef = val == PixelDataBase.EMPTY_RANGE_;
if isempty(val) || any(undef)
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

    return;
end
if any(val(1,:)>val(2,:))
    mess = sprintf([...
        ' Image range Min value(s) : [%g, %g, %g, %g]\n',...
        ' exceeds its Max value(s) : [%g, %g, %g, %g]'],...
        val(1,:),val(2,:));
    % despite statement that it can take sprintf - like argument directly,
    % it does not accept these arguments correctly
    error('HORACE:spher_axes:invalid_argument',mess);
end
if val(1,1)<0
    error('HORACE:spher_axes:invalid_argument','minimal Q-value can not be negative');
end
if val(1,1) < eps
    val(1,1) = eps;
end
% check if teta is in range [-pi/2; pi/2] and throw if the value is outside
% of this interval
val(:,2) = check_and_normalize_angular_range(val(:,2),obj.angles_in_rad_(1),[-pi/2,pi/2]);
% check if phi is in range [-pi; pi] and transform any other value into
% of this interval
val(:,3) = check_and_normalize_angular_range(val(:,3),obj.angles_in_rad_(2),[-pi,pi]);


obj.img_range_ = val;

function range = check_and_normalize_angular_range(range,range_in_rad,limits_in_rad)
if range_in_rad
    limits = limits_in_rad;
else
    limits = rad2deg(limits_in_rad);
end
if in_range(1)<limits(1) || in_range(2)>limits(2)
    error('HORACE:spher_axes:invalid_argument', ...
        'Angular range exceeds its alowed range %s', ...
        mat2str(limits));
end

