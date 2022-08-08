function dataSource = gen_bm_cut_data(dataFile,dataSize)
% Generate sqw object or select exisiting sqw file for benchmarking cut_sqw
% If input parameter is a string represnting an existing sqw file then this
% will be selected, otherswise if the input is an integer, dummy_sqw will be
% used to generate an sqw object of the requested size/number of pixels
    
if is_file(dataFile)
      dataSource=dataFile;
else
    switch dataSize
        case 'small'
            dataSource = gen_fake_sqw_data(6);
        case 'medium'
            dataSource = gen_fake_sqw_data(7);
        case 'large'
            dataSource = gen_fake_sqw_data(8);
        otherwise
            try
                dataSource = gen_fake_sqw_data(dataSize);
            catch
                error("HORACE:gen_bm_data:invalid_argument"...
                    ,"dataSize is the size of the sqw object : must be small, " + ...
                    "medium, large (char type) or numeric (from 1 to 9)")
            end
    end
end
end

