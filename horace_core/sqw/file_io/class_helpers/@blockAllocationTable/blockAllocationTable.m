classdef blockAllocationTable
    %blockAllocationTable  class responsible for maintaining coherent
    % location of binary blocks on HDD, identification of free spaces to 
    % store updated blocks and storing/restoring information about block 
    % sizes and block location on HDD
    %

    properties
    end

    methods
        function obj = blockAllocationTable(varargin)
            %UNTITLED4 Construct an instance of this class
            %   Detailed explanation goes here
            if nargin == 0
                return;
            end
            obj = obj.init(varargin{:});
        end

        function outputArg = init(block_list)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here

        end
    end
end