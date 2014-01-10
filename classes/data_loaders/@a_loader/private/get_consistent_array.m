function array = get_consistent_array(this,field_name)
% method returns correct data array if all fields of the class are well
% defined and consistent or 'ill defined' otherwise;
%
%
%
% $Revision: 319 $ ($Date: 2014-01-08 22:27:51 +0000 (Wed, 08 Jan 2014) $)
%

if ~isempty(this.(field_name))
    if all(size(this.S_stor)==size(this.ERR_stor)) && (size(this.en_stor,1) ==size(this.S_stor,1)+1)
        array = this.(field_name);
    else
        array='ill defined';
    end
else
    array = [];
end


