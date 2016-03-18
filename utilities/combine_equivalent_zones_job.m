classdef combine_equivalent_zones_job < JobExecutor
    %Class to convert partial zones to seleted one using separtate Matlab session
    %
    %
    properties
    end
    
    methods
        function obj = combine_equivalent_zones_job(varargin)
            obj = obj@JobExecutor(varargin{:});
        end
        function this=do_job(this,varargin)
            % Run jobs of creating zones in separate Matlab
            % session.
            %
            % work together with combine_equivalent_zone_list in multisession mode,
            % accepting parameters, generated there in multisession mode
            %

            args   = varargin{1};
            n_zones = numel(args);            
            %job_num = this.job_id();
            zone_fnames= cell(n_zones,1);
            zone_id = zeros(n_zones,1);
            for ji = 1:n_zones
                par = args(ji);
                par.n_zone = ji;
                par.n_tot_zones = n_zones;
                zone_fnames{ji} = move_zone1_to_zone0(par);
                zone_id(ji)     = par.zone_id;
            end
            %str = input('enter something to continue:','s');
            %disp(str);
            zone_fnames = flatten_cell_array(zone_fnames);
            out = struct('zone_id',zone_id,'zone_files',[]);
            out.zone_files = zone_fnames;
            this = this.return_results(out);
            
        end
    end
    methods(Static)
        function strpar= param_f(cut_transformation,...
                         proj,data_source,rez_dir,n_tot_zones)
            % function-helper to pack job parameters into srtucture array
            % of parameters to distribute among workers
            %
            % Inputs:
            % cut_transformation -- fully defined cut_transf class,
            %                      containing cut transformation parameters
            % proj      -- class or structure, defining projection, the cut is
            %              taken in 
            %data_source -- file to cut data from 
            %rez_dir     -- the folder to place results into. 
            %n_tot_zones -- the total number of zones to process by a worker 
            %               (for logging purposes)
            strpar = struct(...
                'data_source',data_source,'proj',proj,...
                'cut_transf', cut_transformation,...
                'rez_location',rez_dir,...
                'n_tot_zones',n_tot_zones);

        end
        
        
    end
    
end

