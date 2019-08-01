function fields = check_defined_fields(this)
%

fields =this.loader_can_define();
df = @(field)check_defined(this,field);
defined  = cellfun(df,fields );
fields  = fields(defined);


function is=check_defined(class_inst,field)

try
    fv=class_inst.(field);
    if isempty(fv)
        is=false;
    else
        if ischar(fv)
            is=false;
        else
            is=true;
        end
    end
catch
    is=false;
end
