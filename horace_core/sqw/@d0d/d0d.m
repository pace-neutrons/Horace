classdef d0d < DnDBase
    %D0D Create an zero-dimensional DnD object
    %
    % Syntax:
    %   >> w = d0d()               % Create a default, empty, D0D object
    %   >> w = d0d(filename)       % Create a D0D object from a file
    %   >> w = d0d(struct)         % Create from a structure with valid fields (internal use)

    properties (Constant, Access = protected)
       NUM_DIMS = 0;
    end

    methods(Static)
        function obj = loadobj(S)
            % Load a d0d object from a .mat file
            %
            %   >> obj = loadobj(S)
            %
            % Input:
            % ------
            %   S       An instance of this object or struct
            %
            % -------
            % Output:
            %   obj     An instance of this object
            obj = d0d(S);
            if isa(S,'d0d')
               obj = S;
               if isstruct(obj.data_)
                    obj.data_ = data_sqw_dnd(obj.data_);
               end
               return
            end
            if numel(S)>1
               tmp = d0d();
               obj = repmat(tmp, size(S));
               for i = 1:numel(S)
                   obj(i) = d0d(S(i));
	               if isstruct(obj(i).data_)
    	                obj(i).data_ = data_sqw_dnd(obj(i).data_);
        	       end

               end
            else
               obj = d0d(S);
               if isstruct(obj.data_)
                    obj.data_ = data_sqw_dnd(obj.data_);
               end
            end
        end
    end
end
