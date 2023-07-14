% helper for deserialize_handle
function f = restore_function(decl__,workspace__)
% create workspace
    for fn__=fieldnames(workspace__)'
        % we use underscore names here to not run into conflicts with names defined in the workspace
        eval([fn__{1} ' = workspace__.(fn__{1}) ;']);
    end
    clear workspace__ fn__;
    % evaluate declaration
    f = eval(decl__);
end
