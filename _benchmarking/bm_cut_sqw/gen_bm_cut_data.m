function data = gen_bm_cut_data(nData)
% Generate sqw object or select exisiting sqw file for benchmarking cut_sqw
% If input parameter is a string represnting an existing sqw file then this
% will be selected, otherswise if the input is an integer, fake_sqw will be
% used to generate an sqw object of the requested size/number of pixels
common_data = fullfile(fileparts(fileparts(mfilename('fullpath')...
        )),'common_data');
    if isa(nData,'string')
        switch nData
            case "ironSmall"
                data = fullfile(common_data,'ironSmall.sqw');
            case "ironMedium"
                data = fullfile(common_data,'ironMedium.sqw');
            case "ironLarge"
                data = fullfile(common_data,'ironLarge.sqw');
            otherwise
                warning("HORACE:gen_bm_data:invalid_argument",...
                    "There is no exisiting sqw file for this data size")
        end
    elseif isa(nData, 'double')
        data=gen_fake_sqw_data(nData);
    else
        error("HORACE:gen_bm_data:invalid_argument",...
                    "nData must be either a string or an integer.")
    end
end

