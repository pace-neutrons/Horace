classdef noggle<handle
    properties
        nog = 'Default nog';
    end
    
    methods
        function this = noggle(str)
            if nargin>0
                this.nog = str;
            end
        end
        
        function change(this,str)
            this.nog = str;
        end
    end
end
