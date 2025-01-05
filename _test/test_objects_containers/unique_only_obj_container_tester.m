classdef unique_only_obj_container_tester < unique_only_obj_container
    %Class to test protected properties of unique_only_obj_container
    %   Detailed explanation goes here

    properties(Dependent)
        lidx
        mem_expansion_chunk
        total_allocated
    end

    methods
        function lid = get.lidx(self)
            lid =self.lidx_;
        end
        function mc = get.mem_expansion_chunk(self)
            mc = self.mem_expansion_chunk_;
        end
        function self = set.mem_expansion_chunk(self,val)
            self.mem_expansion_chunk_ = val;
        end
        function lid = get.total_allocated(self)
            lid =self.total_allocated_;
        end
    end
end