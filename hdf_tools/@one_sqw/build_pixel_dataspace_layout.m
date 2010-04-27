function one_sqw=build_pixel_dataspace_layout(one_sqw,npix)
% function returns 1D array of the starting addresses of pixels in pixel array
% 
% npix -- the array of numbers of pixels in cells of the signal array. 
%
% $Revision$ ($Date$)
%

%dims = size(npix);
ngpix= numel(npix);
one_sqw.pixel_dataspace_layout(1)=0;
one_sqw.pixel_dataspace_layout(2:ngpix+1) = cumsum(reshape(npix*one_sqw.reserve,1,ngpix));

% this should be the nuber of pixels in the whole dataset;
new_size  = one_sqw.pixel_dataspace_layout(ngpix+1);
if one_sqw.pixel_dims(2)~=new_size;
        one_sqw.pixel_dims(2)=new_size;
        try
            H5D.set_extent(one_sqw.pixel_DSID,fliplr(new_size));
        catch
            error('HORACE:hdf_tools','build_pixel_dataspace_layout-> can not extend pixel dataset on hdd')
        end
        
        one_sqw.pixel_Space = H5D.get_space(one_sqw.pixel_DSID);   
end


%pixel_dataspace_layout(ngpix+1)   = [];
%pixel_dataspace_layout = reshape(pixel_dataspace_layout,dims);
