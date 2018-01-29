function [keyval,ws_list,toll]=process_inputs_(this,keys_array,varargin)
% provess input arguments, separate control keys from workspaces
% and set up default values for keys, which are not present
%
[keyval,ws_list] = extract_keyvalues(varargin,keys_array);
if numel(ws_list) == 0
    return;
end

% function decides if the variable equal to tol
f_tol_present = @(var)(is_string(var)&&strcmp(var,'tol'));
% check if var 'tol' among the input arguments
tol_provided = cellfun(f_tol_present,keyval);
if any(tol_provided)
    itol = find(tol_provided);
    toll = keyval{itol+1};
    tol_provided(itol+1)=true;
    keyval = keyval(~tol_provided);
else
    toll = this.tol;
end

f_mind_present = @(var)(is_string(var)&&strcmp(var,'min_denominator'));
mind_provided = cellfun(f_mind_present,keyval);

if ~any(mind_provided)
    if numel(keyval)>0
        keyval = [keyval(:);this.comparison_par(:)];
    else
        keyval = this.comparison_par;
    end
end

