function obj = init_(obj,narg,varargin)
%INIT_ Main part of ortho_proj constructor
%
% initialization routine taking any parameters that non-default
% constructor would take and initiating internal state of the
% ortho_proj class.
%
if narg == 1 && (isstruct(varargin{1})||isa(varargin{1},'aProjectionBase'))
    if isstruct(varargin{1}) && isfield(varargin{1},'serial_name')
        obj = serializable.loadobj(varargin{1});
    else
        obj = obj.from_old_struct(varargin{1});
    end
else
    % constructor does not accept legacy alignment matrix
    opt =  [ortho_proj.fields_to_save_(1:end-1);aProjectionBase.init_params(:)];
    % check if the type is defined explicitly
    n_type = find(ismember(opt,'type'));
    is_keys = cellfun(@istext,varargin);
    if ismember('type',varargin(is_keys)) || ... % defined as key-value pair
            (numel(varargin)>n_type && ischar(varargin{n_type}) && numel(varargin{n_type}) == 3) % defined as positional parameter
        obj.type_is_defined_explicitly_ = true;
    end
    [obj,remains] = ...
        set_positional_and_key_val_arguments(obj,...
        opt,false,varargin{:});
    if ~isempty(remains)
        error('HORACE:ortho_proj:invalid_argument',...
            'The parameters %s provided as input to ortho_proj initialization have not been recognized',...
            disp2str(remains));
    end
end
