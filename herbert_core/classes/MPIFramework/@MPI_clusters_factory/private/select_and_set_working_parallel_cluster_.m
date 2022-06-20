function select_and_set_working_parallel_cluster_(obj,val)
% Set up MPI cluster to use. Available options are:
% h[erbert], p[arpool], m[pi_cluster] or s[lurm]
% (can be defined by single symbol) or by a framework number
% in the list of frameworks.
%
% If the cluster is not available, it is still set up as the
% internal cluster, but the framework_available property of the
% cluster factory is set up to false, so get_cluster function
% would return empty value.
if isa(val,'ClusterWrapper')
    cl_name = class(val);
    if ~ismember(cl_name,obj.known_cluster_names_)
        error('HERBERT:MPI_clusters_factory:invalid_argument',...
            'Cluster with name %s is not subscribed to factory',val);
    end
    obj.known_clusters_(cl_name) = val;
    %
elseif ischar(val) || isstring(val)
    if isstring(val)
        val_length = val.strlength;
    else
        val_length = numel(val);
    end
    names = obj.known_cluster_names_;
    short_names = cellfun(@(nm)trim_name_(nm,val_length),names,...
        'UniformOutput',false);
    member = ismember(short_names,val);
    if ~any(member)
        error('HERBERT:MPI_clusters_factory:invalid_argument',...
            'Setting up the the cluster with unknown name ''%s''',val);
    else
        ind = find(member>0);
        if numel(ind)> 1
            multicelected = strjoin(names(ind),'; ');
            error('HERBERT:MPI_clusters_factory:invalid_argument',...
                'The input ''%s'' is an ambiguous abbreviation of multiple valid options: %s.',...
                val,multicelected)
        end
        cl_name = names{ind};
    end
elseif isnumeric(val)
    names = obj.known_cluster_names_;
    if val<1 || val>numel(names)
        error('HERBERT:MPI_clusters_factory:invalid_argument',...
            'Cluster number can be selected in range [1-%d] only. Requested number: %d ',...
            numel(names),val);
    end
    cl_name = names{val};
    
else
    error('HERBERT:MPI_clusters_factory:invalid_argument',...
        'Unknown parallel cluster: ''%s'' type: ''%s'' requested',...
        strtrim(evalc('disp(val)')),class(val));
end
cl = obj.known_clusters_(cl_name);
try
    cl.check_availability();
catch ME
    if strcmp(ME.identifier,'HERBERT:ClusterWrapper:not_available')
        obj.framework_available_ = false;
        return
    else
        rethrow(ME);
    end
end
obj.parallel_cluster_name_ = cl_name;
obj.framework_available_   = true;
%
