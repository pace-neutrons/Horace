function  valid = get_existing_(self)
% get logical array with true for existing (valid) images and false for
% handles of the images which were deleted

if isempty(self.fig_list_)
    valid = false;
    return;
end
if verLessThan('matlab','8.3')
    valid = ishandle([self.fig_list_{:}]);
else
    valid = isvalid([self.fig_list_{:}]);
end


