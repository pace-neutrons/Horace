function  valid = get_existing_(self)
% get array of all existing (valid) images excluding the
% handles of the images which were deleted

if verLessThan('matlab','8.3')
    valid = ishandle([self.fig_list_{:}]);
else
    valid = isvalid([self.fig_list_{:}]);
end


