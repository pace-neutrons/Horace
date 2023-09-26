function  [obj,missinig_fields] = copy_contents_(obj,other_obj,upgrade_range,varargin)
% Copy information, relevant to new file format from the old file format
% and update the information, which can be updated.


% Fix and freeze the position of the pixels data block
pix_data_block = obj.bat_.get_data_block('bl_pix_data_wrap');
pix_data_block.pix_position = other_obj.pix_position;
pix_data_block.locked = true; % this can not be false, 
%                but some issue with old classes and outdated files can
%                make if false. Let's do it explicitly -- here we lock 
%                pixel block
% this defines the block size
pix_data_block.npixels      = other_obj.npixels;
% allocate space in new data block
obj.bat_ = obj.bat_.set_data_block(pix_data_block);
sqw_obj = other_obj.get_sqw('-norange');
mh = sqw_obj.main_header;
if ~mh.creation_date_defined
    sqw_obj.creation_date = datetime('now');
end

% build data range as if it has not been stored with
% majority of old data files
%
if ~sqw_obj.pix.is_range_valid()
    %log_level = config_store.instance().get_value('hor_config','log_level');
    if upgrade_range
        hc = hor_config;
        log_level = hc.log_level;
        if log_level > 0
            fprintf(2,['\n*** Recalculating actual data range missing in file %s:\n', ...
                '*** This is one-off operation occurring during upgrade from file format version %d to file format version %d\n',...
                '*** Do not interrupt this operation after the page count completion, as the input data file may become corrupted\n'],...
                obj.full_filename,other_obj.faccess_version,obj.faccess_version);
        end
        [pix,unique_pix_id] = sqw_obj.pix.recalc_data_range();
        sqw_obj.pix = pix;
        sqw_obj = update_pixels_run_id(sqw_obj,unique_pix_id);
    end
end
% this method is only on the old file interface and checks if
% the projection is defined for cut (image system of
% coordinates is different from pixel system coordinates) or
% recovered for original sqw file (image coordinates system
% is Crystal Cartesian).
sqw_obj = other_obj.update_projection(sqw_obj);
% define number of contributing files, which is stored in sqw
% object header, but necessary for sqw_file_interface (not any
% more but historically to be able to recover headers)
obj.num_contrib_files_ = sqw_obj.main_header.nfiles;

if upgrade_range
    % clear disk location of all data blocks except the locked
    obj.bat_ = obj.bat_.clear();
end
% as pix data block position already allocated,
obj.bat_ = obj.bat_.init_obj_info(sqw_obj,'-insert');

obj.sqw_holder_ = sqw_obj;
missinig_fields = 'data_in_memory_write_result';
