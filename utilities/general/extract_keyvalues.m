function [keyval_list,other]=extract_keyvalues(data,keys)
% funcntion to extract key-val pairs from the list of data in the form
%data={something1,key1,val1,something2,key2,val2,key3,val3}
% 
%Usave:
%>>[keyval_list,other_data] = extract_keyvalues(data,keys)
%Where data are the cellarray in the form:
%data={something1,key1,val1,something2,key2,val2,key3,val3}
%keys is the cellarray of strings, defining  the key-values pairs to extract:
%keys = {key1,key2,key3}
% and the result have form:
%other_data = {something1,something2}
%keyval_list = {key1,val1,key2,val2,key3,val3}
%
%
% Throws if a key is not followed by a value e.g:
%
%data={something1,key1,key2,val2,key3,val3}
%and the keys requested are {key1,key2,key3}
if numel(data) == 0
    keyval_list=[];
    other = [];
    return;
end

keys_check = @(x)iskey(x,keys);
keys_present = cellfun(keys_check,data);
vals_present = logical(zeros(1,numel(keys_present)));
vals_present(2:end) = keys_present(1:end-1);

collisions = vals_present&keys_present;
if any(collisions)
    error('EXTRACT_KEYVALUES:invalid_argument',' some keys do not have values attached');
end

keyval_pres = vals_present|keys_present;


keyval_list = data(keyval_pres);
other       = data(~keyval_pres);

function is = iskey(val,keys)

if isstring(val)
    is = any(ismember(keys,val));
else
    is = false;
end
