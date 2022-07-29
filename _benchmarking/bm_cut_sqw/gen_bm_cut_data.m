function data = gen_bm_cut_data(nData)
% Generate sqw object or select exisiting sqw file for benchmarking cut_sqw
% If input parameter is a string represnting an existing sqw file then this
% will be selected, otherswise if the input is an integer, dummy_sqw will be
% used to generate an sqw object of the requested size/number of pixels
    if isa(nData,'double')
        data=gen_fake_sqw_data(nData);
    else
        error("HORACE:gen_bm_data:invalid_argument",...
                    "nData must be an integer from 5 to 9.")
    end
end

