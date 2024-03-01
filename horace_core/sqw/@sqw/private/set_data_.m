function obj = set_data_(obj,d)
%SET_DATA_ Main setter for data property

if isa(d,'DnDBase')
    obj.data_ = d;
elseif isempty(d)
    obj.data_ = d0d();
else
    error('HORACE:sqw:invalid_argument',...
        'Only instance of dnd class or empty value may be used as data value. Trying to set up: %s',...
        class(d))
end
