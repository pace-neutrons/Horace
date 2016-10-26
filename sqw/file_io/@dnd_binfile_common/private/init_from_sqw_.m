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
%
%obj = get_header_size(obj,sqw_2save);

data = struct(sqw_2save);
if strcmp(obj.data_type_,'undefined')
    obj.data_type_ = 'b+';
end
format = obj.get_data_form();
[data_pos,pos] = obj.sqw_serializer_.calculate_positions(format,data,obj.data_pos_);

obj.s_pos_=data_pos.s_pos_;
obj.e_pos_=data_pos.e_pos_;
obj.npix_pos_=data_pos.npix_pos_;
if isfield(data_pos,'urange_pos_')
    obj.urange_pos_=data_pos.urange_pos_;
end

obj.dnd_eof_pos_ = pos;


%

function [obj,app_header]=get_header_size(obj,sqw_2save)

format = obj.app_header_form_;
app_header = obj.build_app_header(sqw_2save);
[~,pos] = obj.sqw_serializer_.calculate_positions(format,app_header,0);
obj.data_pos_  = pos;
%

%

