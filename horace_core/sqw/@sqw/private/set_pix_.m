function obj= set_pix_(obj,val)
%SET_PIX_ main setter for sqw object pix property

if isa(val, 'PixelDataBase') || isa(val,'MultipixBase')
    obj.pix_ = val;
elseif isempty(val)
    %  necessary for clearing up the memmapfile, (if any)
    obj.pix_ = PixelDataMemory();
else
    obj.pix_ = PixelDataBase.create(val);
end
