function obj = put_dnd_metadata(obj,dnd_obj)
%PUT_DND_METADATA stores dnd metadata containing in a dnd object using fully
% initialized instance of file-accessor.
%
% if dnd object is not provided as input, it will be retrieved from
% value stored in sqw_holder
if exist('dnd_obj','var')
    if ~(isa(dnd_obj,'DnDBase') || isa(dnd_obj,'dnd_metadata'))
        error('HORACE:faccess_sqw_v4:invalid_argument',...
            'This method accepts instance of DnD object as input. In fact you provieded object of class %s',...
            class(dnd_obj));
    end
    obj = obj.put_sqw_block('bl_data_metadata',dnd_obj,'-noinit');
else
    obj = obj.put_sqw_block('bl_data_metadata');
end