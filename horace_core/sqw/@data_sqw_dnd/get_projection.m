function proj = get_projection(obj)
% Extract the projection, used to build data_sqw_dnd object from the object
% itself. 
% 
% This function just returns the projection for new (year 2021) sqw objects 
% but used for compartibility with old sqw objects.
%
% TODO: needs refactoring with new projection
pix_range = obj.pix.pix_range;
img_range_guess = range_add_border(pix_range,obj.border_size);
if any(abs(img_range_guess-obj.img_range)>abs(obj.border_size))  % the input is the cut

else % the input is the raw sqw object
   proj=projection();
   proj.alatt=obj.alatt;
   proj.angdeg=obj.angdeg;
end


