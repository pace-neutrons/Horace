function one_sqw=open_pix_dataset(one_sqw)
% internal method for one_sqw class
% function opens signal error and pixel datasets which should be present in
% an existing and opened hdf5 file
%
%
% $Revision$ ($Date$)
%
% file has to be opened
file_ID  = one_sqw.sqw_file_ID;
%
try 
    % open the dataset which has to be present in the file;
    one_sqw.pixel_DSID=H5D.open(file_ID,one_sqw.pixel_DSName);
    one_sqw.pixels_present=true;

    one_sqw.pixel_Space        = H5D.get_space(one_sqw.pixel_DSID);
    one_sqw.pixel_DSProperties = H5D.get_create_plist(one_sqw.pixel_DSID);   
    [rank, dims,max_dims]      = H5S.get_simple_extent_dims (one_sqw.pixel_Space);
    one_sqw.pixel_dims(2)      = fliplr(dims); % should be 1D array and hdf returns 1D values 
                                 % let's flip it just in case. 
   
    % query pixels datatype;
    one_sqw.pixel_DT=H5D.get_type(one_sqw.pixel_DSID);
    presision = H5T.get_precision(one_sqw.pixel_DT);
    switch(presision)
        case 64
            one_sqw.pixel_accuracy='double';
        case 32
            one_sqw.pixel_accuracy='float';                        
        otherwise
            error('HORACE:hdf_tools','open_sqw_dataset=> unknown kind (not double or float) of pixels data');

    end   
    
catch
    one_sqw.pixels_present=false;    
    one_sqw.process_pixels=false;
end


