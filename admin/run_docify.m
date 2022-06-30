function run_docify()
    if ~exist('docify', 'file'), add_herbert_path(); end
    base_dir = fileparts(which('herbert_init'));
    docifiable_folders = {'applications/multifit', ...
                          'applications/multifit_legacy', ...
                          'utilities'};
    for ii = 1:numel(docifiable_folders)
        fld = join([base_dir '/' docifiable_folders{ii}], ''); 
        docify(fld, '-recursive', '-list', 3, '-all')
    end
end

function add_herbert_path()
    if exist('../local_init', 'dir')
        % Running in CI
        addpath('../local_init');
        path = horace_on();
    else
        % Assume we're running from the admin folder
        cur_dir = fileparts(mfilename('fullpath'));
        addpath([cur_dir '/../herbert_core']);
        herbert_init();
    end
end
