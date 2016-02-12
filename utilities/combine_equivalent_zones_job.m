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
            zoneok= true(n_zones,1);
            zoneid = zeros(n_zones,1);
            for ji = 1:n_zones
                par = JobDispatcher.restore_param(varargin{ji});
                zoneok(ji) = move_zone1_to_zone0(par);
                zoneid(ji) = par.zone_id;
            end
            %str = input('enter something to continue:','s');
            %disp(str);
            this = this.set_outputs(struct('zoneok',zoneok,'zone_id',zoneid));
            
        end
        
    end
    
end

