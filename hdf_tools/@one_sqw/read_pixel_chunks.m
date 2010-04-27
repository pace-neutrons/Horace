function   [pix,one_sqw]=read_pixel_chunks(one_sqw,chunks,varargin)
% reads parts of the sqw datas, namely
% signal error and npix - if read data is true;
% pixels information    - if the field one_sqw.process_pixels is true
%
% the information requsted  is selected by the array of chunks, i.e. 1D or
% dnd array of indexes for pixels to select;
% 
% side effects:
% if pixel dataset layout is not defined by the object, npix data are read
% from the file and the layout is calculated;
% 
% usage: 
% [sqw_data,one_sqw]=read_pixel_chunks(one_sqw,chunks,varargin);
% where:
%
% cunks  -- m*n array where m is the dimension of the dnd object and n --
%               number elements to read
%               or 1D representation of this array (see sub2ind function on
%               how to obtain such representation)
% varargin{1} -- optional, npix -- pixels distribution over the cells --
%              used to calculate the pixel dataset layout if it is not
%              already calcylated;
%
%
% $Revision$ ($Date$)
%


 %   [rank,dims]= H5S.get_simple_extent_dims(one_sqw.signal_Space);

    if one_sqw.process_pixels

        if nargin==3
            one_sqw=select_pixels_hyperslab(one_sqw,fliplr(one_sqw.signal_dims),chunks,varargin{1});
        elseif nargin == 2
            if isempty(one_sqw.pixel_dataspace_layout)
                [sqw_data,one_sqw]=read_signal_dataset(one_sqw);
                one_sqw=build_pixel_dataspace_layout(one_sqw,sqw_data.npix);
            end
            one_sqw=select_pixels_hyperslab(one_sqw,fliplr(one_sqw.signal_dims),chunks);
        else
            
        end
        
        
        pix_data_size=one_sqw.pixes_selection_size;
        mem_space = H5S.create_simple(1,fliplr(pix_data_size),[]);
        H5S.select_all(mem_space);
        %              H5Dread( dataset_id,  mem_type_id,        mem_space_id, file_space_id, xfer_plist_id, void * buf  )         
        pix = H5D.read(one_sqw.pixel_DSID,one_sqw.pixel_DT,mem_space,one_sqw.pixel_Space,'H5P_DEFAULT');
       
        H5S.close(mem_space)
    else
        pix=[];
    end
