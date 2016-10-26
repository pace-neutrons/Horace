function obj=init_from_sqw_(obj,varargin)
% Initialize the strucute of sqw file from sqw object, stored in memory
% for subsequent write operations
%
if nargin < 2
    error('SQW_BINFILE_COMMON:runtime_error',...
        'init_from_sqw_ method should be ivoked with at least the existing sqw object provided');
end
if nargin == 3
    new_filename = varargin{2};
end

sqw_2save = varargin{1};

% 
[obj,app_header] = get_header_size(obj,sqw_2save);



function [obj,app_header]=get_header_size(obj,sqw_2save)

format = obj.app_header_form_;
app_header = format;
app_header.version  = obj.file_ver_;
obj.typestart_pos_  = obj.sqw_serializer_.calculate_positions(template_struc,app_header)-1;
format.sqw_type = int32(0);
format.num_dim  = int32(0);
if isempty(sqw_2save.data.pix)
    app_header.sqw_type = false;
else
    app_header.sqw_type = true;    
end
%
app_header.num_dim = numel(size(sqw_2save.s));
%
obj.main_header_pos_ = obj.sqw_serializer_.calculate_positions(template_struc,app_header)-1;
%

