function [ok, mess, main_header, header, detpar, data, npixtot, pix_position] = ...
    cut_sqw_read_data (data_source, hor_log_level)
% Return all cut information, excluding pixels if data_source is a file
%
%   >> [ok, mess, main_header, header, detpar, data, npixtot, pix_position] = ...
%                       cut_sqw_read_data (data_source, hor_log_level)
%
% Input:
% ------
%   data_source     Name of file containing sqw data, or sqw object
%   hor_log_level   Informational output level
%
% Output:
% -------
%   ok              True if all OK, false otherwise
%   mess            Error message if not OK, empty string '' otherwise
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

ok = true;
mess = '';

if ischar(data_source)
    % Data_source is a file
    if hor_log_level>=0, disp(['Taking cut from data in file ',data_source,'...']), end
    if hor_log_level>=1
        bigtic;
    end
    
    ld = sqw_formats_factory.instance().get_loader(data_source);
    data_type = ld.data_type;
    if ~strcmpi(data_type,'a')
        ok = false;
        mess = 'Data file is not sqw file with pixel information - cannot take cut';
        main_header = struct();
        header = struct();
        detpar = struct();
        data = struct();
        npixtot = [];
        pix_position = [];
        return
    end
    main_header = ld.get_main_header();
    header = ld.get_header('-all');
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
    % (no memory penalty as matlab just passes pointers)
    if hor_log_level>=0, disp('Taking cut from sqw object...'), end
    main_header = data_source.main_header;
    header = data_source.header;
    detpar = data_source.detpar;
    data   = data_source.data;
    npixtot= size(data.pix,2);
    pix_position = [];

    if hor_log_level>=1
        disp(' ')
    end 
    
end
