function this=build_from_struct(this,a_struct,varargin)
% function to fill the rundata class from data, defined in the input structure
        set_fields     = fieldnames(a_struct);
        present_fields = fieldnames(this);
        if ~any(ismember(set_fields,present_fields))
                error('RUNDATA:invalid_argument',' attempting to set field %s but such field does not exist in run_data class\n',set_fields{ismember(set_fields,present_fields)});            
        end
        for i=1:numel(set_fields)
            if ~isempty(a_struct.(set_fields{i}))
                this.(set_fields{i})=a_struct.(set_fields{i});          
            end
        end
        
        this=parse_arg(this,varargin{:});
end

