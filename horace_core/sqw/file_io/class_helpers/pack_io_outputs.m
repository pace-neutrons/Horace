function argout = pack_io_outputs(argin,n_inputs,n_outputs)
% pack cellarray of output objects in the form, most appropriate for the
% type of the objects and output type given cellarray of input objects
%
%
if n_outputs == 1 && n_inputs == 1
    argout{1} = argin{1};
    return
end

type_list = cellfun(@class,argin,'UniformOutput',false);
boss_type = type_list{1};
same_types = cellfun(@(x)strcmp(boss_type,x),type_list,'UniformOutput',true);
if n_outputs == 1
    if all(same_types)    % return array of the same type classes
        boss_class = feval(boss_type);
        out = repmat(boss_class,1,n_inputs);
        for i=1:n_inputs
            out(i) = argin{i};
        end
        argout = {out};
    else % return cellarray of heterogeneous types
        argout = {argin};
    end
else
    argout = argin(1:n_outputs);
end


