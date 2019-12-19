function [mc_contributions,ok,mess] = mc_contributions_parse (contr,varargin)
% Return structure with list of which components will contribute to the resolution
%
% The names of valid contributions must be given in the cell array of strings contr.
%
% Return default: (also use this to get a structure with all the possible
% component names)
%   >> [mc_contributions,ok,mess] = mc_contributions_parse
%
%   >> [mc_contributions,ok,mess] = mc_contributions_parse (contr,'all')    % all contributions
%   >> [mc_contributions,ok,mess] = mc_contributions_parse (contr,'none')   % no contributions
%
% All components included except...
%   >> [mc_contributions,ok,mess] = mc_contributions_parse (contr,'nomoderator')
%   >> [mc_contributions,ok,mess] = mc_contributions_parse (contr,'nomoderator','nochopper')
%
% Only include...
%   >> [mc_contributions,ok,mess] = mc_contributions_parse (contr,'chopper','sample')
%
% Set to, or modify, an existing Monte Carlo contriburions structure:
%   >> [mc_contributions,ok,mess] = mc_contributions_parse (contr,mc_contributions_in)
%   >> [mc_contributions,ok,mess] = mc_contributions_parse (contr,mc_contributions_in,'moderator','nochopper')


% Default returns (including the case of no allowed constributions
if numel(contr)>0
    mc_contributions_all=cell2struct(num2cell(true(numel(contr),1)),contr);
    mc_contributions_none=cell2struct(num2cell(false(numel(contr),1)),contr);
else
    mc_contributions_all = [];
    mc_contributions_none = [];
end

% Catch case of no input arguments, 'all' or 'none'
if numel(varargin)==0
    mc_contributions=mc_contributions_all; ok=true; mess=''; return
elseif numel(varargin)==1 && isempty(varargin{1})
    mc_contributions=mc_contributions_all; ok=true; mess=''; return
elseif numel(varargin)==1 && is_string(varargin{1}) && strcmpi(varargin{1},'all')
    mc_contributions=mc_contributions_all; ok=true; mess=''; return
elseif numel(varargin)==1 && is_string(varargin{1}) && strcmpi(varargin{1},'none')
    mc_contributions=mc_contributions_none; ok=true; mess=''; return
end

% Only if contributions are permitted can it be possible for the input to be valid
if numel(contr)>0    
    % Parse parameters:
    [args,options,present] = parse_arguments(varargin,mc_contributions_none,contr);   % use mc_none to give dummy defaults;
    
    % Accept the case of a scalar structure with logical values and fieldnames matching the allowed ones
    % Otherwise, no arguments are allowed - only the logical options
    if numel(args)==1 && isstruct(args{1}) && isequal(contr(:),fieldnames(args{1}))
        if isscalar(args{1})
            [ok,mc_in]=check_ok(args{1});
            if ok
                mc_contributions=change_contributions(mc_in,options,present);
                mess='';
            else
                mc_contributions=[]; mess='Values of contributions to Monte Carlo calculation must be logical true or false';
                if nargout<=1, error(mess), end
            end
        else
            mc_contributions=[]; ok=false; mess='Structure with list of contributions to Monte Carlo calculation must be a scalar structure';
            if nargout<=1, error(mess), end
        end
        
    elseif numel(args)==0
        if all_present(options,present,true)
            mc_contributions=change_contributions(mc_contributions_none,options,present);
            ok=true; mess='';
        elseif all_present(options,present,false)
            mc_contributions=change_contributions(mc_contributions_all,options,present);
            ok=true; mess='';
        else
            mc_contributions=[]; ok=false; mess='Give the components that are present only (e.g. ''moderator'') or absent only (e.g. ''nomoderator'')';
            if nargout<=1, error(mess), end
        end
        
    else
        mc_contributions=[]; ok=false;
        mess='Check Monte Carlo contributions argument is a structure with correct field names';
        if nargout<=1, error(mess), end
    end
    
else
    % If no contributions are permitted, then there must be an error
    mc_contributions=[]; ok=false;
    mess='No Monte Carlo contribution options are permitted';
    if nargout<=1, error(mess), end
end

%--------------------------------------------------------------------------------------------------
function [ok,mc]=check_ok(mc_in)
% Check fields are all scalar logical or 0/1; make logical
ok=true;
mc=mc_in;
nam=fieldnames(mc);
for i=1:numel(nam)
    if islognumscalar(mc.(nam{i}))
        if ~islogical(mc.(nam{i}))
            mc.(nam{i})=logical(mc.(nam{i}));
        end
    else
        ok=false;
        return
    end
end

%--------------------------------------------------------------------------------------------------
function mc=change_contributions(mc_in,options,present)
% Change the logical status of contributions according to value if keyword was present
mc=mc_in;
nam=fieldnames(mc);
for i=1:numel(nam)
    if present.(nam{i})
        mc.(nam{i})=options.(nam{i});
    end
end

%--------------------------------------------------------------------------------------------------
function status=all_present(options,present,value)
% Determine if all present keywords had a particular value
status=true;
nam=fieldnames(options);
for i=1:numel(nam)
    if present.(nam{i}) && options.(nam{i})~=value
        status=false;
        break
    end
end
