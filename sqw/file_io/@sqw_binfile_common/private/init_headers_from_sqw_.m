function obj=init_headers_from_sqw_(obj,sqw_obj)
% Initialize the strucute of sqw header block for subsequent write operations
% using sqw object, stored in memory
%
%
% $Revision$ ($Date$)
%

main_h_form = obj.get_main_header_form();
main_h = sqw_obj.main_header;

[obj.main_head_pos_info_,pos]= obj.sqw_serializer_.calculate_positions(main_h_form,main_h ,obj.main_header_pos_);
%
n_files = main_h.nfiles;
%
obj.num_contrib_files_ = n_files;
%
obj.header_pos_ = zeros(1,n_files);
obj.header_pos_(1) = pos;

headers = sqw_obj.header;
header_form = obj.get_header_form();
[header_pos,pos]=obj.sqw_serializer_.calculate_positions(header_form,headers(1),pos);
obj.header_pos_info_ = repmat(header_pos,1,n_files);

for i=2:n_files
    obj.header_pos_(i) = pos;
    % [header_pos,pos] =
    [header_pos,pos]=obj.sqw_serializer_.calculate_positions(header_form,headers(i),pos);
    obj.header_pos_info(i) = header_pos;
end
obj.detpar_pos_ = pos;

detpar = sqw_obj.detpar;
detpar_form = obj.get_detpar_form();
[detpar_pos,pos]=obj.sqw_serializer_.calculate_positions(detpar_form,detpar,pos);
obj.detpar_pos_info_ = detpar_pos;
obj.data_pos_ = pos;

