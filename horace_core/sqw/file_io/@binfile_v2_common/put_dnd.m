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

[ok,mess,update,argi]=parse_char_options(varargin,{'-update'});
if ~ok
    error('HORACE:binfile_v2_common:invalid_artgument',...
        ['put_sqw: Error: ',mess]);
end
if ~isempty(argi)
    input = argi{1};
    if ~(isa(input, 'SQWDnDBase') || is_sqw_struct(input))
        error('HORACE:binfile_v2_common:invalid_artgument',...
            'put_sqw: this function can accept only sqw or dnd-type object, and got %s', class(input))
    end
    if isa(input,'sqw')
        to_store  = input.data;
    else
        to_store  = input;
    end
    if numel(argi) > 1
        argi = argi{2:end};
    else
        argi = {};
    end
else
    to_store  = [];
end

%
if update
    if ~obj.upgrade_mode % set up info for upgrade mode and the mode itself
        obj.upgrade_mode = true;
    end
    %return update option to argument list
    argi{end+1} = '-update';
end

obj=obj.put_app_header(to_store);

% write dnd image metadata
obj=obj.put_dnd_metadata(argi{:});
% write dnd image data
obj=obj.put_dnd_data(argi{:});
%
if ~isempty(to_store) && isempty(obj.sqw_holder_)
    obj.sqw_holder_ = to_store;
end

