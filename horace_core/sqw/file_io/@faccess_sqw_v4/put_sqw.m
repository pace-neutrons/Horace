function    obj = put_sqw(obj,varargin)
% Save sqw data into new binary file or fully overwrite an existing file
%
%
%
%
[ok,mess,~,argi]=parse_char_options(varargin,{'-update'});
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
    sqw_obj.main_header.creation_date= cd;
    sqw_obj.data.creation_date = cd;
    sqw_obj.full_filename = obj.full_filename;
    obj.sqw_holder = sqw_obj;
end
if ~isa(obj.sqw_holder.pix,'pix_combine_info')
    obj = obj.put_all_blocks();
    return
end

obj = obj.put_all_blocks('ignore_blocks','bl_pix_pix_data_wrap');
%
if ~isempty(jobDispatcher)
    argi = [{jobDispatcher},argi];
end
obj=obj.put_pix(argi{:});
