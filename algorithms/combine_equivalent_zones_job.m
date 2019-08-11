classdef combine_equivalent_zones_job < JobExecutor
    %Class running Herbert MPI job to convert partial zones into selected one
    %using separate Matlab session
    %
    %
    %
    % $Revision:: 1752 ($Date:: 2019-08-11 23:26:06 +0100 (Sun, 11 Aug 2019) $)
    %
    
    properties
    end
    
    methods
        function obj = combine_equivalent_zones_job(varargin)
            obj = obj@JobExecutor();
        end
        function this=do_job(this,varargin)
            % Run jobs of creating zones in separate Matlab
            % session.
            %
            % work together with combine_equivalent_zone_list in multisession mode,
            % accepting parameters, generated there in multisession mode with help of 
            % the param_f method below.
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
                zone_id(ji)     = par.cut_transf.zone_id;
                %zone_id(ji)     = par.zone_id;                
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
            % function-helper to pack job parameters into structure array
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

