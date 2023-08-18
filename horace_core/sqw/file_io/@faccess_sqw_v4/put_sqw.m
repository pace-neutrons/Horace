function    obj = put_sqw(obj,varargin)
% Save sqw data into new binary file or fully overwrite an existing file
%
% Usage:
% obj = obj.put_sqw()         Put sqw object which have been already
%                             initialized with this file-accessor and is
%                             assigned to obj.sqw_holder;
% obj = obj.put_sqw(sqw_obj)  Put sqw object provided as input of the
%                             method. The file to put object should be
%                             already set.
% obj = obj.put_sqw(sqw_obj,filename)
%                             Put sqw object provided as input of the
%                             method to the file provided as second parameter.
%
% Options:
% '-update'        -- write to existing sqw file. Currently deprecated and does nothimg.
%
%                    TODO: Check if existing file contains sqw object,
%                    as currently such file is silently overwritten.
% '-verbatim'      -- do not change filenames and file-path-es, stored in
%                     current sqw object headers to the name and path
%                     of the current file to write data into
% '-nopix'         -- do not store pixel array within the sqw object.
%                     Write sqw object with empty pixels record
% '-hold_pix_place'
%                  -- do not store pixels array within the sqw object but 
%                     write all pixel metadata and prepare pixel data block
%                     for writing
%
%

[ok,mess,~,verbatim,nopix,reserve,hold_pix,argi]=parse_char_options(varargin, ...
    {'-update','-verbatim','-nopix','-reserve','-hold_pix_place'});
if ~ok
    error('HORACE:faccess_sqw_v4:invalid_argument', ...
        mess);
end

jobDispatcher = [];

if ~isempty(argi)
    is_sqw = cellfun(@(x) isa(x,'sqw'), argi);
    if any(is_sqw)
        if sum(is_sqw) > 1
            error('HORACE:sqw_binfile_common:invalid_argument',...
                'only one sqw object can be provided as input for put_sqw');
        end
        %         if update
        %             obj = obj.init_from_sqw_obj(argi{is_sqw},'-insertion');
        %         else
        obj.sqw_holder = argi{is_sqw};
        %        end
        argi = argi(~is_sqw);
    end

    is_jd = cellfun(@(x) isa(x,'JobDispatcher'), argi);
    if any(is_jd)
        if sum(is_jd) > 1
            error('HORACE:sqw_binfile_common:invalid_argument',...
                'only one JobDispatcher object can be provided as input for put_sqw');
        end
        jobDispatcher = argi{is_jd};
    end
    argi = argi(~is_jd);
end

if ~obj.sqw_holder.main_header.creation_date_defined ||...
        isempty(obj.sqw_holder.main_header.filename)
    cd = datetime('now');
    sqw_obj = obj.sqw_holder;
    sqw_obj.creation_date= cd;
    if ~verbatim
        sqw_obj.full_filename = obj.full_filename;
    end
    obj.sqw_holder = sqw_obj;
end

if ~(isa(obj.sqw_holder.pix,'pix_combine_info') || ...
        obj.sqw_holder.pix.is_filebacked || ...
        nopix)
    obj = obj.put_all_blocks();
    return;
end

if ~verbatim
    sqw_obj = obj.sqw_holder;
    sqw_obj.pix.full_filename =obj.full_filename;
    obj.sqw_holder = sqw_obj;
end

if nopix && ~(reserve||hold_pix) % Modify writeable object to contain no pixels
    sqw_obj  = obj.sqw_holder;
    old_pix = sqw_obj.pix;
    sqw_obj.pix = PixelDataMemory();
    if ~verbatim
        sqw_obj.full_filename = obj.full_filename;
    end
    obj.sqw_holder = sqw_obj;
    obj = obj.put_all_blocks();
    sqw_obj.pix    = old_pix;
    obj.sqw_holder = sqw_obj;
    return;
end

if reserve
    argi = [argi(:),'-reserve'];
end
if hold_pix
    argi = [argi(:),'-hold_pix_place'];    
end

if nopix
    argi = [argi(:),'-nopix'];
end

obj = obj.put_all_blocks('ignore_blocks',{'bl_pix_metadata','bl_pix_data_wrap'});

if ~isempty(jobDispatcher)
    argi = [{jobDispatcher},argi];
end

obj=obj.put_pix(argi{:});
