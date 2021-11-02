function public_struct = struct(obj,varargin)
% convert class into structure, containing public-accessible information
% 
% by default structure is build using defined parameters and parameters
% which contains meaningful defaults, but if option '-all' is provided, all
% public fields fill be returned 
%
% 

opt = {'-all'};
[ok,mess,build_all] = parse_char_options(varargin,opt);
if ~ok
    error('ORIENTED_LATTICE:invalid_argument',mess);
end

pub_fields = fieldnames(obj);
if ~build_all
    undef_fields = obj.get_undef_fields();
    undef = ismember(pub_fields,undef_fields);
    pub_fields = pub_fields(~undef);
end
public_struct  = struct();
for i=1:numel(pub_fields)
    public_struct.(pub_fields{i}) = obj.(pub_fields{i});
end
%public_struct.undef_fields_ = obj.undef_fields_;


