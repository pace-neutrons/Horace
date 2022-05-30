function [ok,mess,obj] = check_combo_arg_(obj)
% verify if interdependent properties of the object are consistent

ok = true;
mess = '';
nd = obj.n_dims;
if numel(obj.dax)~=nd
    mess=sprintf(...
        'number of display axes elements (%d) have to be equal to the number of projection axes (%d)',...
        numel(obj.dax),nd);
    ok=false;
    obj.isvalid_ = false;
end
if max(obj.dax)>numel(obj.pax)
    mess=sprintf(...   
       'The maximal number of display axis can not exceed the number of projection axes');
    ok=false;
    obj.isvalid_ = false;    
end

