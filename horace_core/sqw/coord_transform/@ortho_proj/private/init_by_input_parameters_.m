function obj = init_by_input_parameters_(obj,varargin)
%INIT_BY_INPUT_PARAMETERS_ is the helper allowing to support various mainly
%outdated forms of input of the ortho_proj constructor.
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


opt =  [ortho_proj.fields_to_save_(1:end-1);aProjectionBase.init_params(:)];
% check if the type is defined explicitly
n_type = find(ismember(opt,'type'));
text_in = cellfun(@(x)char(string(x)),varargin,'UniformOutput',false); 

if ismember('type',text_in) || ... % defined as key-value pair
        (numel(varargin)>n_type && ischar(varargin{n_type}) && numel(varargin{n_type}) == 3) % defined as positional parameter
    obj.type_is_defined_explicitly_ = true;
end
is_uoffset = ismember(text_in,'uoffset');
is_img_offset = ismember(text_in,'img_offset');
if any(is_uoffset) && any(is_img_offset)
    error('HORACE:ortho_proj:invalid_argument',...    
        'only one key describing image offset (img_offset or uoffset) may be provided as input')
end
is_uoffset = is_uoffset | is_img_offset;
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
    error('HORACE:ortho_proj:invalid_argument',...
        'The parameters %s provided as input to ortho_proj initialization have not been recognized',...
        disp2str(remains));
end
if uoffset_provided
    obj.img_offset = varargin{uoffset_nval};
end
