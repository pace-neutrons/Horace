function public_struct = struct(this,varargin)
% convert class into structure, containing public-accessible information
% 
% by default structure is build using defined parameters and parameters
% which contains meaningful defaults, but if option '-all' is provided, all
% public fields fill be returned 
%
% 
% $Revision:: 831 ($Date:: 2019-06-03 09:47:08 +0100 (Mon, 3 Jun 2019) $) 
%

opt = {'-all'};
[ok,mess,build_all] = parse_char_options(varargin,opt);
if ~ok
    error('ORIENTED_LATTICE:invalid_argument',mess);
end

pub_fields = fieldnames(this);
if ~build_all
    undef_fields = this.get_undef_fields();
    undef = ismember(pub_fields,undef_fields);
    pub_fields = pub_fields(~undef);
end
public_struct  = struct();
for i=1:numel(pub_fields)
    public_struct.(pub_fields{i}) = this.(pub_fields{i});
end

