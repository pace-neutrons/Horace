function [det_par,n_detectros] = check_det_par(value)
% method checks if value can represent par file and detectors coordinates
%

if isempty(value)
    det_par = [];
    n_detectros=[];
    return;
end
if isstruct(value)
    flds = fields(value);
    if ~all(ismember({'group','x2','phi','azim','width','height'},flds))
        error('A_LOADER:set_det_par',' attempt to set invalid detectors structure')
    end
    n_detectros = numel(value.group);
else
    [n_col,n_detectros] = size(value);
    if n_col ~= 6
        error('A_LOADER:set_det_par',' attempt to set invalid detectors parameters')
    end
    
end
det_par = value;



