function  one_sqw=write_data_chunks(one_sqw,sqw_data,chunks)
% writes part of the sqw data (signal error and npix plus pixels
% information if present and requsted)  selected by the array of chunks
% cunks  -- m*n array where m is the dimension of the dnd object and n --
%               number of elements to write
%               or 1D representation of such array (see sub2ind function on
%               how to obtain such representation)
% side effects:
% no as we expect the dataset dimensions and number of elements remains
% unchanged;
%
% $Revision$ ($Date$)
%

    signal         = zeros(3,numel(sqw_data.s));
    signal(1,:)    = reshape(sqw_data.s,numel(sqw_data.s),1);
    signal(2,:)    = reshape(sqw_data.e,numel(sqw_data.e),1);
    signal(3,:)    = reshape(sqw_data.npix,numel(sqw_data.npix),1);              
   
    
   % indexes of data in an hdf-file start from 0; 
    chunks_dim = size(chunks);
    chunks_rank= size(chunks_dim);
    if chunks_rank(1)==1 % chunks are in the form of 1D indexing
        signal_chunks=chunks-1;        
    else       
        error('HORACE:hdf_tools','this parameter has not been tested')
        signal_chunks=sub2ind(size(sqw_data.s),chunks)-1;        
    end
    % *** > this may me completely unnesessary
    try
       H5S.close(one_sqw.signal_Space);
    catch
    end
    one_sqw.signal_dims=size(sqw_data.s);
    
    rank = 1;
    dims = numel(sqw_data.s);
    one_sqw.signal_Space=H5S.create_simple (rank,dims,[]);

    H5S.select_elements(one_sqw.signal_Space, 'H5S_SELECT_SET',fliplr(signal_chunks));
    H5D.write (one_sqw.signal_DSID,one_sqw.signal_DT,'H5S_ALL',one_sqw.signal_Space,'H5P_DEFAULT',signal);
    



