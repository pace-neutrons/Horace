function obj = put_dnd(obj,varargin)
% Save dnd data into new binary file or fully overwrite an existing file
%
%Usage:
%>>obj = obj.put_dnd()
%>>obj = obj.put_dnd('-update')
%>>obj = obj.put_dnd(sqw_or_dnd_object)
%

if ~isempty(varargin)
    is_sqw_dnd = cellfun(@(x)(isa(x,'SQWDnDBase')||is_sqw_struct(x)),varargin);
    if any(is_sqw_dnd)
         sqw_ind = find(is_sqw_dnd);
         if isa(varargin{sqw_ind},'sqw')
             varargin{sqw_ind} = varargin{sqw_ind}.data;
         end
        obj = obj.init(varargin{:});
    end
end
if isempty(obj.sqw_holder)
    error('HORACE:faccess_dnd_v4:runtime_error',...
        'Attempt to store dnd object in file %s but the dnd object have not been defined', ...
        obj.full_filename);
end
sqh = obj.sqw_holder;
if ~sqh.creation_date_defined
    sqh.creation_date = datetime('now');
    obj.sqw_holder_ = sqh;
    obj.bat_ = obj.bat_.init_obj_info(sqh);
end

obj=obj.put_app_header();
obj.bat_.put_bat(obj.file_id_);

obj = obj.put_dnd_metadata();
obj = obj.put_dnd_data();
