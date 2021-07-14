function short_name=trim_name_(name,sample_len)
% Cut the name provided, to be not longer then the length provided as
% second input
%
if numel(name) <=sample_len
    short_name = name;
else
    short_name = name(1:sample_len);
end

