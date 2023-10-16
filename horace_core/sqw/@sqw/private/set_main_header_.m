function obj = set_main_header_(obj,val)
%SET_MAIN_HEADER_  setter with checks for main header
% Input:
% val -- main header or structure accepted by constructor of main
%        header
%
if isempty(val)
    obj.main_header_  = main_header_cl();
elseif isa(val,'main_header_cl')
    obj.main_header_ = val;
elseif isstruct(val)
    obj.main_header_ = main_header_cl(val);
else
    error('HORACE:sqw:invalid_argument',...
        'main_header property accepts only inputs with main_header_cl instance class or structure, convertible into this class. You provided %s', ...
        class(val));
end
if ~isempty(obj.experiment_info_) && obj.experiment_info_.n_runs>0 && ...
        obj.experiment_info_.n_runs ~= obj.main_header_.nfiles
    warning('HORACE:inconsitent_sqw', ...
        'number of rund defined in experiment_info (%d) is not equal to number of contributing files, defined in main sqw header (%d)', ...
        obj.experiment_info_.n_runs,obj.main_header_.nfiles);
end
