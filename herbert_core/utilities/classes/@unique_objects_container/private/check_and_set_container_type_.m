function  [obj,argi] = check_and_set_container_type_(obj,varargin)
% strange opportunity to define the type of the internal
% container. Who would need this. Your select the type
% according to the optimal performance (cell probably vould be
% optimal)

type_provided = cellfun(@(x)(ischar(x)&&strcmp(x,'type')),varargin);
if any(type_provided )
    key_ind = find(type_provided);
    val_ind = key_ind+1;
    type = varargin{val_ind};
    type_provided(val_ind)= true;
    if ~ischar(type)
        error('HERBERT:unique_objects_container:invalid_argument',...
            'type may be only string, defining the conteiner type. It is %s',...
            disp2str(type));

    end
    if strcmp(type,'{}')
        obj.stored_objects_ = {};
    else
        obj.stored_objects_ = [];
    end
    argi = varargin(~type_provided);
else
    argi = varargin;
end

