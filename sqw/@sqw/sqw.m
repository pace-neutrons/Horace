classdef sqw
    % Create an sqw object
    %
    % Syntax:
    %   >> w = sqw (filename)       % Create an sqw object from a file
    %   >> w = sqw (din)            % Create from a structure with valid fields
    %                               % Structure array will output an array of sqw objects
    
    % For private use by d0d/d0d d0d/sqw,...d4d/d4d d4d/sqw
    %   >> w = sqw ('$dnd',filename)% Create an sqw object from a file
    %   >> w = sqw ('$dnd',din)     % Create from a structure with valid fields
    %                               % Structure array will output an array of sqw objects
    %   >> w = sqw ('$dnd',u0,u1,p1,u2,p2,...,un,pn)
    %   >> w = sqw ('$dnd',u0,u1,p1,u2,p2,...,un-1,pn-1,pn)
    %   >> w = sqw ('$dnd',lattice,u0,...)
    %   >> w = sqw ('$dnd',ndim)
    %
    % Will enforce dnd-type sqw object.
    %
    % Input:
    % ------
    %   u0      Vector of form [h0,k0,l0] or [h0,k0,l0,en0]
    %          that defines an origin point on the manifold of the dataset.
    %          If en0 omitted, then assumed to be zero.
    %   u1      Vector [h1,k1,l1] or [h1,k1,l1,en1] defining a plot axis. Must
    %          not mix momentum and energy components e.g. [1,1,2], [0,2,0,0] and
    %          [0,0,0,1] are valid; [1,0,0,1] is not.
    %   p1      Vector of form [plo,delta_p,phi] that defines limits and step
    %          in multiples of u1.
    %   u2,p2   For next plot axis etc.
    %           If un is omitted, it is assumed to be [0,0,0,1] i.e. the energy axis]
    %
    %   lattice Defines crystal lattice: [a,b,c,alpha,beta,gamma]
    %
    %   ndim    Number of dimensions
    
    % Original author: T.G.Perring
    %
    % $Revision$ ($Date$)    properties
    properties(Dependent)
        main_header;
        header;
        detpar;
        data
        
    end
    properties(Access=protected)
        main_header_ = [];
        header_=[];
        detpar_=[];
        data_ = [];
    end
    
    methods
        function obj = sqw (varargin)
            % class constructor
            if nargin>0
                obj = build_sqw_(obj,varargin{:});
            end
            
        end
        %------------------------------------------------------------------        
        function hd = get.main_header(obj)
            hd = obj.main_header_;
        end
        function hd = get.header(obj)
            hd = obj.header_;
        end
        function dp = get.detpar(obj)
            dp = obj.detpar_;
        end
        function dat = get.data(obj)
            dat= obj.data_;
        end
        %------------------------------------------------------------------
        function obj = set.main_header(obj,val)
            obj.main_header_ = check_and_set_main_header_(val);
        end
        function obj = set.header(obj,val)
            obj.header_ = check_and_set_header_(val);
        end
        function obj = set.detpar(obj,val)
           obj.detpar_ = check_and_set_detpar_(val);
        end        
        function obj = set.data(obj,val)
           obj.data_ = check_and_get_data_(val);
        end
        %------------------------------------------------------------------
        
        
    end
    
end

