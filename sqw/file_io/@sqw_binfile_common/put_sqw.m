function    obj = put_sqw(obj,varargin)
% Save sqw data into new binary file or fully overwrite an existing file
%
%
% $Revision:: 1751 ($Date:: 2019-06-03 09:47:49 +0100 (Mon, 3 Jun 2019) $)
%
%
%
[ok,mess,update,argi]=parse_char_options(varargin,{'-update'});
if ~ok
    error('SQW_FILE_IO:invalid_artgument',...
        ['DND_BINFILE_COMMON::put_sqw Error: ',mess]);
end
%
jobDispatcher = [];
%
if ~isempty(argi)
    is_sqw = cellfun(@(x)isa(x,'sqw'),argi,'UniformOutput',true); 
    if any(is_sqw)
        if sum(is_sqw) > 1
            error('SQW_FILE_IO:invalid_artgument','only one sqw object can be provided as input for put_sqw');
        end
        obj.sqw_holder_ = argi{is_sqw};        
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
%
if update
    if ~obj.upgrade_mode % set up info for upgrade mode and the mode itself
        obj.upgrade_mode = true;
    end
    %return update option to argument list
    argi{end+1} = '-update';
end


% store header, which describes file as sqw file
obj=obj.put_app_header();
%
obj=obj.put_main_header(argi{:});
%
obj=obj.put_headers(argi{:});
%
obj=obj.put_det_info(argi{:});
%
% write dnd image metadata
obj=obj.put_dnd_metadata(argi{:});
% write dnd image data
obj=obj.put_dnd_data(argi{:});
%
if ~isempty(jobDispatcher)
    argi = [{jobDispatcher},argi];
end
obj=obj.put_pix(argi{:});

%
if ~update
    fseek(obj.file_id_,0,'eof');
    obj.real_eof_pos_ = ftell(obj.file_id_);
end
