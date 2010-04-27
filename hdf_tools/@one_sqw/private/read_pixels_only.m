function [pixels,one_sqw]=read_pixels_only(one_sqw)

if one_sqw.process_pixels   
%    [rank, pix_dims,max_dims] = H5S.get_simple_extent_dims (one_sqw.pixel_Space);    

    one_sqw.pixel_Space      = H5D.get_space(one_sqw.pixel_DSID);
    [rank, pix_dims]         = H5S.get_simple_extent_dims (one_sqw.pixel_Space);    
    
    if pix_dims~=one_sqw.pixel_dims(2)
        one_sqw.pixel_dims(2) = pix_dims;
    end
    pixels =H5D.read(one_sqw.pixel_DSID, one_sqw.pixel_DT,'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');   
    
 %   pp = sqw_data.pix(:,1)
else 
    pixels=[one_sqw.pixel_dims(1),0];
end
