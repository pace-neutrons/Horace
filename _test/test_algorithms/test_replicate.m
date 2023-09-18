classdef test_replicate < TestCase
    
    properties
    end
    
    methods
        
        function obj = test_replicate(varargin)
            if nargin > 0
                name = varargin{1};
            else
                name= mfilename('class');
            end
            obj = obj@TestCase(name);
        end
        
        function test_replicate_herbert(~)
            % test the herbert replicate_array
            
            % array of numbers of replicates to be added
            np = [1 2 3 4 5 6 7 8 9 10];
            % array of things to be replicated
            vv = [111 222 333 444 555 666 777 888 999 1000];
            % replication of vv by np using the herbert/utilities/maths
            % version of replicate array
            ww = replicate_array(vv,np);

            % check size of replicated array
            assertEqual( numel(ww), 55);
            % check last members of replications are correct
            assertEqual([ww(1),ww(3),ww(6),ww(10),ww(15), ...
                         ww(21),ww(28),ww(36),ww(45),ww(55)], ...
                         [111 222 333 444 555 666 777 888 999 1000]);
            % check first members of replications are correct
            assertEqual([ww(1),ww(2),ww(4),ww(7),ww(11), ...
                         ww(16),ww(22),ww(29),ww(37),ww(46)], ...
                         [111 222 333 444 555 666 777 888 999 1000]);
        end
        
        
        function test_replicate_horace(~)
            % test the horace replicate_array in @sqw
            % this was going to be a clone of the herbert version above.
            % however the horace version is a static method in a private
            % folder of the class and according to the matlab help should
            % therefore not exist. Accordingly this test is skipped but
            % retained here to point out the problem which may be fixed
            % some day.
            skipTest(' ');
        end
 
    end
end
