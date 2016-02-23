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
        function strpar= param_f(id,zone1,qh,qk,ql,en,...
                         proj,zone0,data_source,rez_dir)
            % function-helper to pack job parameters into srtucture array
            % of parameters to distribute among workers
            %
            % Inputs:
            % id    -- the number of zone in zones list
            % zone1 -- three-elements vector defining zone to transform 
            %          centre (in hkl units)
            % qh,qk,ql,en -- instances of the qe_range class-helper defining 
            %                cut ranges in 3-q and one dE direction
            % proj   -- class or structure, defining projection, the cut is
            %          taken in 
            % zone0   -- three-elements vector defining zone to transform to
            %          centre (in hkl units)
            %
            % rez_dir -- the folder to place results into. 
            cut_range = {qh.cut_range(),qk.cut_range(),...
                ql.cut_range(),en.cut_range()};
                       
            strpar = struct(...
                'data_source',data_source,'proj',proj,...
                'cut_ranges',[],...
                'zone1_center',zone1,...
                'zone0_center',zone0,'zone_id',id,...
                'rez_location',rez_dir);
            strpar.cut_ranges = cut_range;
        end
        
        
    end
    
end

