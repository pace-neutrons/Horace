function padded = paddata_horace(input,new_size)
% version independent paddata, expanding size of the input array in
% the requested dimensions.
%
persistent ver_bigger_than_2023a;
if isempty(ver_bigger_than_2023a)
    try
        padded = paddata(input,new_size);
        ver_bigger_than_2023a = true;
        return;
    catch
        ver_bigger_than_2023a = false;
    end
end
if ver_bigger_than_2023a
    padded = paddata(input,new_size);
else
    padded  = input;
    sz0     = size(input);
    if numel(sz0)~=numel(new_size) || any(sz0>new_size)
        error('HORACE:utilities:invalid_argument', ...
            'shape of the padded dimensins have to be equal to the shape of the source array')
    end
    for i=1:numel(new_size)
        sz0    = size(padded);
        sz0(i) = new_size(i)-sz0(i);
        if sz0(i)<=0
            continue;
        end
        padded = cat(1,padded,false(sz0));
    end
end
end