function   app_header = build_app_header(obj,obj_to_save)
% build header, which contains information on sqw object and
% informs clients on contents of a binary file


format = obj.app_header_form_;
app_header = format;
app_header.version  = obj.file_ver_;
%
if isa(obj_to_save,'sqw')
    app_header.sqw_type = true;
    ndim = numel(size(obj_to_save.data.s));
else
   type    = class(obj_to_save);
   classes = {'d0d','d1d','d2d','d3d','d4d'};
   ind = ismember(classes,type);
   if ~any(ind)
       error('DND_BINFILE_COMMON:invalid_argument',...
           ' build_app_header -- unsupported class to save %s',type)
   end
   ndim = find(ind)-1;
end
app_header.ndim = ndim;

