function  self = check_and_set_pic_size_(self,val)
% Verifies and sets the linear size of a pictures, used for controlling the
% sequence of images
%
if ~isnumeric(val)
    error('PIC_SPREAD:invalid_argument',' picture size has to be numeric')
end

if numel(val) >2
    error('PIC_SPREAD:invalid_argument',...
        ' picture size can not have more than two elements, but has: %d',...
        numel(val))
end
if numel(val) == 1
    self.pic_size_ = [double(val),double(val)];
else
    self.pic_size_ = double([val(1),val(2)]);
end
