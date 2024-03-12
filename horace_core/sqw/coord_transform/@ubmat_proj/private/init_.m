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
        obj = obj.from_bare_struct(varargin{1});
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


opt =  obj.saveableFields();
% check if the type is defined explicitly

[obj,remains] = ...
    set_positional_and_key_val_arguments(obj,...
    opt,false,varargin{:});
if ~isempty(remains)
    error('HORACE:umat_proj:invalid_argument',...
        'The parameters %s provided as input to line_proj initialization have not been recognized',...
        disp2str(remains));
end
