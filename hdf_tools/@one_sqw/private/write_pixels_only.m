function this=write_pixels_only(this,pixels)
% one_sqw private method
%
% write pixels information to propertly prepared and opened hdf file
%
% $Revision$ ($Date$)
%
% *** > 
if this.process_pixels
    switch(this.pixel_accuracy)
        case 'double'
         pix       = pixels;                       
        otherwise
         pix       = single(pixels);                       
    end   
    if size(pixels,2)~=this.pixel_dims(2)
        extdims = size(pixels,2);
        this.pixel_dims(2)=extdims;
        % *** > why is that?????
        try
          H5D.set_extent(this.pixel_DSID,fliplr(extdims));
        catch
            error('HORACE:hdf_tools','write_pixels_only-> can not extend dataset ')
        end
        
        this.pixel_Space = H5D.get_space(this.pixel_DSID);
    end
%    this = build_pixel_datatype(this);
    
    H5D.write (this.pixel_DSID, this.pixel_DT, 'H5S_ALL', this.pixel_Space, 'H5P_DEFAULT', pix);   
    this.pixels_present=true;
    
   % *** > test
 %   H5F.flush(this.pixel_DSID,'H5F_SCOPE_LOCAL');
end

