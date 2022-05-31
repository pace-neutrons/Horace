function  obj = set_creation_date_(obj,val)
% explicitly set up creation date and make it "defined"

if ischar(val)
    val = num2cell(sscanf(val,obj.DT_format_));
    dt = datetime(val{:});
elseif isa(val,'datetime')
    dt  = val;
else
    error('HORACE:main_header:invalid_argument', ...
        'file creation date may be datetime class or string, transferrable to datetime function according to format %s. Provided %s', ...
        obj.DT_format_,evalc('disp(val)'));
end
obj.creation_date_    = dt;
obj.creation_date_defined_ = true;
