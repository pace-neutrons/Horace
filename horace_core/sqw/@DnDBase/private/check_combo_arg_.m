function obj = check_combo_arg_(obj,varargin)
% Check contents of interdependent fields
%
% Copy appropriate axes settings from projection to axes
% Inputs:
% obj    -- initalized instance of dnd base class
% Optional:
% 'no_proj_copy' -- if this parameter is present (any additional parameter
%                    is present), copying parameters from projection to
%                    axes does not happen
%
% ------------------------

if obj.NUM_DIMS ~= obj.axes_.dimensions
    if ~isa(obj,'data_sqw_dnd') % can be any dimensions
        if obj.NUM_DIMS == 0  % special case of presumably empty d0d object modified
            % to become other object:
            obj = DnDBase.dnd(obj.axes_,obj.proj_,obj.s_,obj.e_,obj.npix_);
            return;
        else
            error('HORACE:DnDBase:invalid_argument',...
                'number of axes dimensions is different from the number of dnd-object dimension')
        end
    end
end

sz = size(obj.s_);
if any(sz ~= size(obj.e_))
    error('HORACE:DnDBase:invalid_argument', ...
        'size of signal array: [%s] different from size of error array: [%s]', ...
        num2str(sz),num2str(size(obj.e_)));
end

if any(sz ~= size(obj.npix_))
    error('HORACE:DnDBase:invalid_argument', ...
        'size of npix array: [%s] different from sizes of signal and error array: [%s]', ...
        num2str(sz),num2str(size(obj.npix_)))
end
if numel(sz) ~= numel(obj.axes.dims_as_ssize)
    error('HORACE:DnDBase:invalid_argument', ...
        ['Number of elements in data arrays (size=[%s]) different from the ' ...
        'number of elements of the grid, defined by axes: (size =[%s])'], ...
        num2str(sz),num2str(obj.axes.dims_as_ssize) )
end
if any(sz ~=obj.axes.dims_as_ssize)
    error('HORACE:DnDBase:invalid_argument', ...
        'size of data arrays: [%s] different from the size of the grid, defined by axes: [%s]', ...
        num2str(sz),num2str(obj.axes.dims_as_ssize) )
end
if ~isa(obj.axes,obj.proj.axes_name)
    error('HORACE:DnDBase:invalid_argument', ...
        'Can not construct DND object with incompartible combination of the projection (class %s) and axes_block (class %s)', ...
        class(obj.proj),class(obj.axes));
end
if nargin == 1
    obj.axes_ = obj.proj.copy_proj_defined_properties_to_axes(obj.axes);
end
