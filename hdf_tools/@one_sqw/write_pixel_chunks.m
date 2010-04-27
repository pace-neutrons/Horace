function one_sqw=write_pixel_chunks(one_sqw,pix,chunks,varargin)
% private methor of one_sqw class
% write pixels data (pix) as chunks of an extended dataset, described by
% one_sqw.pixels_dataset_layout
%
% usage:
% this=write_pixel_chunks(this,pix,chunks,npix)
% or 
% % this=write_pixel_chunks(this,pix,chunks)
% where:
% pix    -- data to write
% npix   -- 
% 
%
%  side effects (from select_pixels_hyperslab)
%         calculates pixel dataspece layout if it is not calculated before and
%         data to calculate it are present; if it is empty and data are not
%         present, error is thrown. 


if nargin==3
    one_sqw=select_pixels_hyperslab(one_sqw,one_sqw.signal_dims,chunks);    
else
    one_sqw=select_pixels_hyperslab(one_sqw,one_sqw.signal_dims,chunks,varargin{1});
end        
            
%H5S.select_elements(one_sqw.pixel_Space, 'H5S_SELECT_SET',fliplr(pixel_chunks));
mem_space = H5S.create_simple(1,fliplr(size(pix,2)),[]);
H5S.select_all(mem_space);

H5D.write (one_sqw.pixel_DSID,one_sqw.pixel_DT,mem_space,one_sqw.pixel_Space,'H5P_DEFAULT',pix);        
H5S.close(mem_space);
