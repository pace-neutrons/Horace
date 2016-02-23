classdef qe_range
    % Simple helper class, which simplifies settings of q-range in one
    % q-direction for combine_equivalent_zones algorithm
    
    properties(Dependent)
        qe_min,
        dqe,
        qe_max
        center;
    end
    properties(Access=private)
        qe_min_=-1;
        dqe_=0.01;
        qe_max_=1;
        center_ = 0;
    end
    
    
    methods
        function obj=qe_range(varargin)
            if nargin==1
                obj.dqe_=varargin{1};
            elseif nargin==2
                obj.qe_min_=varargin{1};
                obj.qe_max_=varargin{2};
                obj.dqe_ = 0;
            elseif nargin==3
                obj.qe_min_=varargin{1};
                obj.dqe_   =varargin{2};
                obj.qe_max_=varargin{3};
                
            end
        end
        function step = get.dqe(obj)
            step = obj.dqe_;
        end
        function min = get.qe_min(obj)
            min = obj.qe_min_+obj.center_;
        end
        function max = get.qe_max(obj)
            max = obj.qe_max_+obj.center_;
        end
        function obj=set.center(obj,center)
            obj.center_ = center;
        end
        function val = get.center(obj)
            val = obj.center_;
        end
        function range=cut_range(obj)
            % convert qe_range into the form accepted by cut_sqw
            if obj.dqe_ == 0
                range = [obj.qe_min,obj.qe_max];
            else
                range = [obj.qe_min,obj.dqe_,obj.qe_max];
            end
        end
    end
    
end

