function obj = check_combo_arg_(obj)
% verify if interdependent properties of the object are consistent

nd = obj.dimensions;
if numel(obj.dax)~=nd
    error('HORACE:AxesBlockBase:invalid_argument',...
        'number of display axes elements (%d) have to be equal to the number of projection axes (%d)',...
        numel(obj.dax),nd);
end
% if dax have not been set explicitly, it has to be equal to pax
if ~obj.dax_set_ 
    obj.dax_ = 1:numel(obj.pax);
else
    if numel(obj.dax)~=numel(obj.pax) || any(sort(obj.dax) ~= 1:numel(obj.pax))
        error('HORACE:AxesBlockBase:invalid_argument',...
            'Number of dax have to be equal to number of pax and every dax should refer to a pax.\n Actually: dax = %s; pax = %s', ...
            mat2str(obj.dax),mat2str(obj.pax));
    end    
end


