function    obj = put_sqw(obj,varargin)
% Save sqw data into new binary file or fully overwrite an existing file
%
% Usage:
% obj = obj.put_sqw()         % Put sqw object which have been already
%                             % intialized with this file-accessor and is
%                             % assigned to sqw_holder;
% obj = obj.put_sqw(sqw_obj)  % Put sqw object provided as input of the
%                             % method. The file to put object should be
%                             already set
% Options:
% '-update'        -- write to existing sqw file. Currently redundant.
%                     Writing to existing file occurs if file is provides
%                     as input.
%                    TODO: Check if existing file contains sqw object,
%                    writing fails without this argument
% '-verbatim'      -- do not change filenames and file-path-es, stored in
%                     cuttent sqw object headers to the name and path
%                     of the current file to write data into
% '-nopix'         -- do not store pixel array within the sqw object.
%                     Write sqw object with empty pixels record
%
%
[ok,mess,~,verbatim,nopix,argi]=parse_char_options(varargin, ...
    {'-update','-verbatim','-nopix'});
if ~ok
    error('HORACE:faccess_sqw_v4:invalid_artgument', ...
        mess);
end
%
jobDispatcher = [];
%
if ~isempty(argi)
    is_sqw = cellfun(@(x)isa(x,'sqw'),argi,'UniformOutput',true);
    if any(is_sqw)
        if sum(is_sqw) > 1
            error('HORACE:sqw_binfile_common:invalid_artgument',...
                'only one sqw object can be provided as input for put_sqw');
        end
        obj.sqw_holder = argi{is_sqw};
        argi = argi(~is_sqw);
    end
    if ~isempty(argi)
        is_jd = cellfun(@(x)isa(x,'JobDispatcher'),argi,'UniformOutput',true);
        if any(is_jd)
            jobDispatcher = argi{is_jd};
        end
        argi = argi(~is_jd);
    end
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
if ~(isa(obj.sqw_holder.pix,'pix_combine_info')|| obj.sqw_holder.pix.is_filebacked||nopix)
    obj = obj.put_all_blocks();
    return
elseif ~verbatim
    sqw_obj = obj.sqw_holder;    
    sqw_obj.pix.full_filename =obj.full_filename;
    obj.sqw_holder = sqw_obj;    
end

if nopix % Modify writable object to contain no pixels
    sqw_obj  = obj.sqw_holder;
    old_pix = sqw_obj.pix;
    sqw_obj.pix = PixelDataMemory();
    if ~verbatim
        sqw_obj.full_filename = obj.full_filename;
    end
    obj.sqw_holder = sqw_obj;
    obj = obj.put_all_blocks();
    sqw_obj.pix = old_pix;
    obj.sqw_holder = sqw_obj;
    return;
end
obj = obj.put_all_blocks('ignore_blocks',{'bl_pix_metadata','bl_pix_data_wrap'});
%
if ~isempty(jobDispatcher)
    argi = [{jobDispatcher},argi];
end
obj=obj.put_pix(argi{:});
