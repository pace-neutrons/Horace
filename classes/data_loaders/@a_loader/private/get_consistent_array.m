function arr = get_consistent_array(this,field_name)
% method returns correct data array if all fields of the class are well
% defined and consistent or 'ill defined' otherwise;
%
%
%
% $Revision: 319 $ ($Date: 2014-01-08 22:27:51 +0000 (Wed, 08 Jan 2014) $)
%


if ~isempty(this.(field_name))
    s_eq_err = all(size(this.S_stor)==size(this.ERR_stor));
    en_suits_s = (size(this.en_stor,1) ==size(this.S_stor,1)+1);
    
    if  s_eq_err && en_suits_s
        arr = this.(field_name);
    else
        arr='ill defined :';
        if ~s_eq_err
            arr=[arr,' size(Signal) ~= size(ERR)'];
            return;
        end
        if ~en_suits_s
            arr = [arr,' size(en) ~= size(S,1)+1'];
        end
    end
else
    arr = [];
end


