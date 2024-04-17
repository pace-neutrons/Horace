function [var_list,var_idx] = types_list_(type,all_types_name,nw)
% Distribute list of m input parameters over nw objects
% 
% Inputs:
% type             -- single parameter, used for for first object
% all_types_name   -- list of all parameters to use
% nw               -- number of objects to provide with parameters
% 
% Returns:
% var_list         -- list of input parameters, used for object
% var_idx          -- array of parameter indices with length nw, providing
%                     parameter index (from var_list) for each input object
if nw == 1
    var_list = type;
    var_idx  = 1;
else
    if numel(type)>1
        var_list = type;
        var_idx  = mod(0:nw-1,numel(type))+1;
    else
        var_list     = get_global_var('genieplot',all_types_name);
        n_parameters = numel(var_list);
        var_idx      = 1:n_parameters;
        this_type_n  = find(ismember(var_list,type));
        var_idx      = circshift(var_idx,-this_type_n+1);
        if n_parameters > nw
            var_idx   = var_idx(1:nw);
        elseif n_parameters < nw
            n_copies = floor(nw/n_parameters);
            if n_copies*n_parameters<nw
                n_copies = n_copies +1;
            end
            var_idx = repmat(var_idx,1,n_copies);
            var_idx = var_idx(1:nw);
        end
    end
end
