function dataSource = gen_bm_cut_data(dataInfo)
%GEN_BM_CUT_SQW This function generates the data needed to run
%benchmarks of cut_sqw()
% This function returns an sqw object generated using the gen_fake_sqw_data()
% function, or else the filepath to an existing sqw object 
% Inputs:
%
%   dataInfo    info on sqw objects to generate:
%                - size of the sqw bject[char: 'small','medium' or 
%                  'large' (10^7,10^8 and 10^9 pixels)
%                - int from 6-10]
%                - filepath to a saved sqw object or empty string
%
% Output:
%   dataSource  filepath to existing/generated sqw file

    % Check if there is alredy an exisiting sqw object to use, otherwise
    % generate it

    dataSource = gen_fake_sqw_data(dataInfo);

end

