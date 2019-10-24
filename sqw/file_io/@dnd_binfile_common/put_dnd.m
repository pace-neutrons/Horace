function    obj = put_dnd(obj,varargin)
% Save dnd data into new binary file or fully overwrite an existing file
%
%Usage:
%>>obj = obj.put_dnd()
%>>obj = obj.put_dnd('-update')
%>>obj = obj.put_dnd(sqw_or_dnd_object)
%
% The object has to be initialized for writing sqw or dnd objects first
% using init method, set_to_update/reopen_to_write or appropriate form 
% of class constructor. 
%
%
% $Revision:: 1753 ($Date:: 2019-10-24 20:46:14 +0100 (Thu, 24 Oct 2019) $)
%

[ok,mess,update,argi]=parse_char_options(varargin,{'-update'});
if ~ok
    error('SQW_FILE_IO:invalid_artgument',...
        ['put_sqw: Error: ',mess]);
end
if ~isempty(argi)
    input = argi{1};
    type = class(input);
    if ~(ismember(type,{'d0d','d1d','d2d','d3d','d4d','sqw'}) || is_sqw_struct(input))
        error('SQW_FILE_IO:invalid_artgument',...
            'put_sqw: this function can accept only sqw or dnd-type object, and got %s',type)
    end
    storage = obj.sqw_holder_;
    if isa(input,'sqw')
        obj.sqw_holder_ = input.data;
    else
        obj.sqw_holder_ = input;
    end
    if numel(argi) > 1
        argi = argi{2:end};
    else
        argi = {};
    end
else
    storage  = [];
end

%
if update
    if ~obj.upgrade_mode % set up info for upgrade mode and the mode itself
        obj.upgrade_mode = true;
    end
    %return update option to argument list
    argi{end+1} = '-update';
end

obj=obj.put_app_header();

% write dnd image metadata
obj=obj.put_dnd_metadata(argi{:});
% write dnd image data
obj=obj.put_dnd_data(argi{:});
%
if ~isempty(storage)
    obj.sqw_holder_ = storage;
end
