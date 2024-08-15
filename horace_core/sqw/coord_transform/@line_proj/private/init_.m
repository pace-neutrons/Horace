function obj = init_(obj,narg,varargin)
%INIT_ Main part of line_proj constructor
%
% initialization routine taking any parameters that non-default
% constructor would take and initiating internal state of the
% line_proj class.
%
if narg == 1 && (isstruct(varargin{1})||isa(varargin{1},'aProjectionBase'))
    if isstruct(varargin{1}) && isfield(varargin{1},'serial_name')
        obj = serializable.loadobj(varargin{1});
    else
        obj = obj.from_old_struct(varargin{1});
    end
else
    obj = init_by_input_parameters_(obj,varargin{:});
end

function obj = init_by_input_parameters_(obj,varargin)
%INIT_BY_INPUT_PARAMETERS_ is the helper allowing to support various mainly
%outdated forms of input of the line_proj constructor.
%
% Inputs:
% list of input parameters of projection, produced as set of positional
% parameters followed by number of key-value pairs.
%
% The positional parameters order is:
%
% u,v,w,nonorthogonal,type,alatt,angdeg,offset,label,title,lab1,lab2,lab3,lab4
%
% First non-positional parameter considered to be a key.
% Constructor does not accept legacy alignment matrix
%


opt =  [line_proj.fields_to_save_(:);aProjectionBase.init_params(:)];
% check if the type is defined explicitly
n_type = find(ismember(opt,'type'));
% convert all inputs into text to be able to use ismember function
text_in = cellfun(@(x)char(string(x)),varargin,'UniformOutput',false); 

if ismember('type',text_in) || ... % defined as key-value pair
        (numel(varargin)>n_type && ischar(varargin{n_type}) && numel(varargin{n_type}) == 3) % defined as positional parameter
    obj.type_is_defined_explicitly_ = true;
end
is_uoffset = ismember(text_in,'uoffset');
if any(is_uoffset)
    uoffset_provided = true;
    uoffset_nval = find(is_uoffset)+1;
    is_uoffset(uoffset_nval) = true;
    argi = varargin(~is_uoffset);    
else
    uoffset_provided = false;
    argi = varargin;
end
[obj,remains] = ...
    set_positional_and_key_val_arguments(obj,...
    opt,false,argi{:});
if ~isempty(remains)
    error('HORACE:line_proj:invalid_argument',...
        'The parameters %s provided as input to line_proj initialization have not been recognized',...
        disp2str(remains));
end
if uoffset_provided
    uoffset = varargin{uoffset_nval};
    try
        offset = obj.transform_img_to_hkl(uoffset(:));
    catch ME
        if strcmp(ME.identifier,'HORACE:line_proj:runtime_error')
            warning('HORACE:invalid_argument', ...
                ['attempt to use old interface "uoffset" ' ...
                'which should define offset in image coordinate system but the projection lattice is undefined\n' ...
                'Using uoffset = %s assuming it is offset in hkle coordinate system'], ...
                disp2str(uoffset(:)'));
            offset = uoffset(:)';
        else
            retrhow(ME);
        end
    end
    obj.offset = offset;
end
