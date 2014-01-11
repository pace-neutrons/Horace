function this = set_consistent_array(this,field_name,value)
% set consistent data array
% and break connection between the class and data file -- currently
% disabled
%
%
% $Revision: 319 $ ($Date: 2014-01-08 22:27:51 +0000 (Wed, 08 Jan 2014) $)
%

if isempty(value)
    this=this.delete();
    return
end

this.(field_name) = value;
%this.data_file_name_stor = '';

if ~strcmp(field_name,'en_stor')
    this.n_detindata_stor = size(value,2);
end

