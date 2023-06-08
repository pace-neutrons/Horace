function [main_header, header, detpar, data, npixtot, pix_position] = ...
    cut_sqw_read_data (data_source, hor_log_level)
% Return all cut information, excluding pixels if data_source is a file
%
%   >> [main_header, header, detpar, data, npixtot, pix_position] = ...
%                       cut_sqw_read_data (data_source, hor_log_level)
%
% Input:
% ------
%   data_source     Name of file containing sqw data, or sqw object
%   hor_log_level   Informational output level
%
% Output:
% -------
%   main_header     Main header block
%   header          Header block
%   detpar          Detector parameter block
%   data            Data block, excluding pixel information if data_source
%                  is a file
%   npixtot         Total number of pixels in the sqw file or object
%   pix_position    Position of pix array in the file ([] if data_source
%                  is an object)


if hor_log_level>=1
    disp('--------------------------------------------------------------------------------')
end

if istext(data_source)
    % Data_source is a file
    if hor_log_level>=0
        disp(['Taking cut from data in file ',data_source,'...']);
    end
    if hor_log_level>=1
        bigtic;
    end

    ld = sqw_formats_factory.instance().get_loader(data_source);
    data_type = ld.data_type;

    if ~strcmpi(data_type,'a')
        ld.delete();
        error('HORACE:cut_sqw_sym:invalid_argument', ...
              'Data file is not sqw file with pixel information - cannot take cut');
    end

    main_header = ld.get_main_header();
    header = ld.get_exp_info('-all');
    detpar = ld.get_detpar();
    data = ld.get_data('-nopix');
    npixtot = ld.npixels;
    pix_position = ld.pix_position;
    ld.delete();

    if hor_log_level>=1
        bigtoc('Time to read header information:',hor_log_level)
        disp(' ')
    end

else
    % Data source is an sqw object in memory
    % For convenience, unpack the fields that themselves are major data structures
    % (no memory penalty as MATLAB just passes pointers)
    if hor_log_level>=0
        disp('Taking cut from sqw object...');
    end

    main_header = data_source.main_header;
    header = data_source.experiment_info;
    detpar = data_source.detpar;
    data   = data_source.data;
    npixtot= data_source.pix.num_pixels;
    pix_position = [];

    if hor_log_level>=1
        disp(' ')
    end

end
