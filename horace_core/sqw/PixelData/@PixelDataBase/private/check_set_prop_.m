function val = check_set_prop_(obj,fld,val)
% check input parameters of set_propery function
%
if isscalar(val)
    if ~isnumeric(val)
        error('HORACCE:PixelDataBase:invalid_argument', ...
            'single value for field %s have to be numeric scalar. It is %s', ...
            fld,disp2str(val))
    end
else
    if isvector(val) && ~isrow(val)
        val = val';
    end
    if ~isnumeric(val) || size(val,1) ~=numel(obj.FIELD_INDEX_MAP_(fld))
        error('HORACCE:PixelDataBase:invalid_argument', ...
            'number of columns while setting fields: %s have to be equal to %d. It is %d', ...
            fld,numel(obj.FIELD_INDEX_MAP_(fld)),size(val,1));
    end
    if size(val,2) ~= obj.page_size
        error('HORACCE:PixelDataBase:invalid_argument', ...
            'If you are setting values for %s, its size have to be equal to page size (%d). In fact it is %d ', ...
            fld,obj.page_size,size(val,2))
    end
end
