function  obj=set_sigma_transf(obj)
% Define transformation, used by combine_equivalent_zones algorithm
% Nullifies shift transformation if any
%
% If sigma-transformation is not defined (incorrect or impossible),
% method prints warning and does nothing. Transformation becomes undefined.
%
% $Revision:: 1758 ($Date:: 2019-12-16 18:18:50 +0000 (Mon, 16 Dec 2019) $)
%

obj=obj.clear_transformations();
try
    obj.transf_matrix = calc_zone_symmetries(obj.zone_center,obj.target_center);
catch ME
    if (strcmp(ME.identifier,'ZONE_SYMMETRIES:invalid_argument'))
        warning('ZONE_SYMMETRIES:invalid_argument',...
            '%s Can not set-up sigma-symmetry for transformation with id: %d',...
            ME.message,obj.zone_id);
        return
    else
        rethrow(ME);
    end
end
obj.shift = [0,0,0];

