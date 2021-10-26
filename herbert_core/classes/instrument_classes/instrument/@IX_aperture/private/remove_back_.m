function x = remove_back_(x)
% private function used by from_old_struct method of
% apperture to convert one kind of old fields into new
% fields
if x(end)=='_'
    x = x(1:end-1);
end

