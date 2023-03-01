function obj = check_and_set_img_range_(obj,val)
% Check if the image range attempted to set is correct and set correct
% value of the image range
%
if ~isnumeric(val)
    error('HORACE:AxesBlockBase:invalid_argument',...
        'Image range has to be numeric. Attempting to set type: %s',...
        class(val));
end
if isempty(val) || all(all(val == PixelDataBase.EMPTY_RANGE_))
    obj.img_range_ = [-inf,pi/2,pi,-inf,inf,-pi/2,-pi,inf];
    if ~obj.angles_in_rad_(1)
        obj.img_range_(:,2) = rad2deg(obj.img_range_(:,2));
    end
    if ~obj.angles_in_rad_(2)
        obj.img_range_(:,3) = rad2deg(obj.img_range_(:,3));
    end

    return;
end
if any(size(val)~=[2,4])
    error('HORACE:AxesBlockBase:invalid_argument',...
        'correct image range have to be 2x4 array of min/max range values. Getting: %s',...
        evalc('disp(val)'));
end
if any(val(1,:)>val(2,:))
    mess = sprintf([...
        ' Image range Min value(s) : [%g, %g, %g, %g]\n',...
        ' exceeds its Max value(s) : [%g, %g, %g, %g]'],...
        val(1,:),val(2,:));
    % despite statement that it can take sprintf - like argument directly,
    % it does not accept these arguments correctly
    error('HORACE:AxesBlockBase:invalid_argument',mess);
end

obj.img_range_ = val;

