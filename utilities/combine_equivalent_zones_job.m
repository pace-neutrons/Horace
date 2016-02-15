classdef combine_equivalent_zones_job < JobDispatcher
    %Class to convert partial zones to seleted one using separtate Matlab session
    %
    %
    
    properties
    end
    
    methods
        function obj = combine_equivalent_zones_job()
            obj = obj@JobDispatcher();
        end
        function this=do_job(this,varargin)
            % Run jobs of creating zones in separate Matlab
            % session.
            %
            % work together with combine_equivalent_zone_list in multisession mode,
            % accepting parameters, generated there in multisession mode
            %
            n_zones = numel(varargin);
            %job_num = this.job_id();
            zone_fnames= cell(n_zones,1);
            zone_id = zeros(n_zones,1);
            for ji = 1:n_zones
                par = JobDispatcher.restore_param(varargin{ji});
                zone_fnames{ji} = move_zone1_to_zone0(par);
                zone_id(ji)     = par.zone_id;
                stop
            end
            %str = input('enter something to continue:','s');
            %disp(str);
            zone_fnames = flatten_cell_array(zone_fnames);
            this = this.set_outputs(struct('zone_id',zone_id,...
                'zone_files',zone_fnames));
            
        end
        
    end
    
end

