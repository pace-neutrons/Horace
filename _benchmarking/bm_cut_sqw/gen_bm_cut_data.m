function dataSource = gen_bm_cut_data(dataFile,dataSize)
%GEN_BM_CUT_SQW This funciton generates the data needed to run
%benchmarks of cut_sqw()
% This function returns an sqw object generated using the gen_fake_sqw_data()
% function, or else the filepath to an existing sqw object 
% Inputs:
%
%   dataFile    filepath to a saved sqw object or empty string
%   dataSize    size of sqw objects to generate:
%               [char: 'small','medium' or 'large' (10^6,10^7 and 10^8
%               pixels) or an int from 5-9]
%
% Output:
%   dataSource  filepath to existing/generated sqw file

% Check if there is alredy an exisiting sqw object to use, otherwise
% genreate it
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

