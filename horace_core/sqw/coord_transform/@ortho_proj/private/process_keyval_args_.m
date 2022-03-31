function [obj,remains] = process_keyval_args_(obj,varargin)
% Process optional key-val arguments of the ortho_proj constructor and
% set them up if they are present
% The possible
%
%   nonorthogonal Indicate if non-orthogonal axes are permitted
%               If false (default): construct orthogonal axes u1,u2,u3 from u,v
%               by defining: u1 || u; u2 in plane of u and v but perpendicular
%               to u with positive component along v; u3 || u x v
%
%               If true: use u,v (and w, if given) as non-orthogonal projection
%               axes: u1 || u, u2 || v, u3 || w if given, or u3 || u x v if not.
%
%   type        [1x3] Character string defining normalisation. Each character
%               indicates how u1, u2, u3 are normalised, as follows:
%               - if 'a': projection axis unit length is one inverse Angstrom
%               - if 'r': then if ui=(h,k,l) in r.l.u., is normalised so
%                         max(abs(h,k,l))=1
%               - if 'p': if orthogonal projection axes:
%                               |u1|=|u|, (u x u2)=(u x v), (u x u3)=(u x w)
%                           i.e. the projections of u,v,w along u1,u2,u3 match
%                           the lengths of u1,u2,u3
%
%                         if non-orthogonal axes:
%                               u1=u;  u2=v;  u3=w
%               Default:
%                 	'ppr'  if w not given
%                 	'ppp'  if w is given
%
%
% Output:
% -------
%   proj    ortho_proj object with defaults for absent fields
%           proj.u              [1x3] Vector of first axis (r.l.u.)
%           proj.v              [1x3] Vector of second axis (r.l.u.)
%           proj.w              [1x3] Vector of third axis (r.l.u.)
%                               (set to [] if not given in proj_in)
%           proj.nonorthogonal  logical true or false
%           proj.type           [1x3] Char. string defining normalisation
%                               each character being 'a','r' or 'p' e.g. 'rrp'
%
remains = {};
par = inputParser();
par.KeepUnmatched = true;
opt_par = {'nonorthogonal','type','u','v','w'};
setters =   {...
    @(x,ob)check_and_set_nonorthogonal_(ob,x),@(x,ob)check_and_set_type_(ob,x),...
    @(x,ob)check_and_set_uv_(ob,'u',x),@(x,ob)check_and_set_uv_(ob,'v',x),...
    @(x,ob)check_and_set_w_(ob,x)};
for i=1:numel(opt_par)
    addParameter(par,opt_par{i},[]); % validation will be performed on setters
end

try
    parse(par,varargin{:});
catch ME
    if strcmp(ME.identifier,'MATLAB:InputParser:ParamMissingValue')
        throw(MException('HORACE:aProjection:invalid_argument',...
            sprintf('This constructor accepts only key,value pairs of ortho_porj properties:\n %s',...
            ME.message)));
    else
        rethrow(ME);
    end
end
res = par.Results;
if numel(par.UsingDefaults) ~= numel(opt_par)
    for i=1:numel(opt_par)
        fn = opt_par{i};
        if ~isempty(res.(fn))
            obj = setters{i}(res.(fn),obj);
            %obj=feval(['check_and_set_,fn,'_'],obj,);
        end
    end
end
rem_struct = par.Unmatched;
rem_flds = fieldnames(rem_struct);
if isempty(rem_flds)
    return;
end
contents = struct2cell(rem_struct);
remains = cell(2*numel(rem_flds));
for i=1:numel(rem_flds)
    remains{2*i-1} = rem_flds{i};
    remains{2*i  } = contents{i};
end