function  valid = get_existing_(self)
% get array of all existing (valid) images excluding the
% handles of the images which were deleted


valid = isvalid([self.pic_list_{:}]);


