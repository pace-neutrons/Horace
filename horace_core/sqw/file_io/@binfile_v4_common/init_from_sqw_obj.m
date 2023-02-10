function  obj=init_from_sqw_obj(obj,varargin)
%init_from_sqw_obj -- initialize file writer from existing object in memory
%
in_obj = varargin{1};
if ~(isa(in_obj,'SQWDnDBase') || is_sqw_struct(in_obj))
    error('HORACE:binfile_v4_common:invalid_argument',...
        'Input object must be sqw or dnd type object. It is: %s', ...
        class(in_obj));
end
% define binary block header information. It is redefined in header again,
% but to have f-accessor fully defined, it defined here too.
obj.num_dim_ = in_obj.dimensions();
%
obj.bat_ = obj.bat_.init_obj_info(in_obj,'-nocache');
%
cn = class(obj);
if contains(cn,"dnd") && isa(in_obj,"sqw")
    obj.sqw_holder_ = in_obj.data;
else
    obj.sqw_holder_ = in_obj;
end
