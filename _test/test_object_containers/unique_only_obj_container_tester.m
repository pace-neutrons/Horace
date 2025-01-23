classdef unique_only_obj_container_tester < unique_only_obj_container
    %Class to test protected properties of unique_only_obj_container
    %   Detailed explanation goes here

    properties(Dependent)
        mem_expansion_chunk
        total_allocated
        lidx_full 
        gidx_full
    end

    methods
         function mc = get.mem_expansion_chunk(self)
            mc = self.mem_expansion_chunk_;
        end
        function self = set.mem_expansion_chunk(self,val)
            self.mem_expansion_chunk_ = val;
        end
        function lid = get.total_allocated(self)
            lid =self.total_allocated_;
        end
        function lid = get.lidx_full(obj)
            lid = obj.lidx_(1:obj.max_obj_idx_);
        end
        function gid  =get.gidx_full(obj)
            gid = obj.idx_(1:obj.max_obj_idx_);
        end
    end
end
