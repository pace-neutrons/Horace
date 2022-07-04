classdef deterministic_pseudorandom_sequence < handle
%--------------------------------------------------
% This class creates a simple deterministic series
% of numbers which can be substituted for a true pseudo-random
% number generator to enable by-eye checking of transformed input.
% Example uses are: 
%    - the random noise addition (via noisify) to the signal 
%      in the Herbert noisify method where it can substitute for randn.
%    - sqw object preservation during paging storage (not strictly random
%      but often appears to to the naked eye when checking data integrity.)
%
% This function is designed to accumulate the "pseudo-
% random" numbers across multiple calls - one for each
% page of a paged sqw object. An external global flag
% initialises these numbers, and an internal persistent
% number keeps track of where this process has got to.
%
% Input to the generator function myrand:
%     n - size of the signal vector for which the noise
%         is being generated.
% Where multiple tests are required a separate class object
% can be used for each one.
%--------------------------------------------------

    properties
        % flag to signal that this pseudo-random
        % number distribution needs to be initialised if true.
        init = 1
        % number tracking where in the generation of
        % the sequence we have got to. Initially a dummy bad value.
        got_to = -666
    end
    methods
        function vals = myrand(obj, data_length)
            % creates the pseudorandom sequence
            % inputs:
            %   - obj         - class instance this is activated from
            %   - data_length - matrix of size [1,L] as obtained e.g. from
            %                   an sqw signal vector y of size L using the
            %                   call size(y)
            % output:
            %   - vals        - vector of length L with the pseudorandom
            %                   values
            
            % On initialisation the flag is reset false and the number
            % sequence tracker is initialised to 1
            if obj.init==1
                obj.init   = 0;
                obj.got_to = 1;
            end
            
            % the length of the signal which is passed in as the argument
            % is a [1,length] matrix - the actual length is extracted from 
            % the second element.
            data_length = data_length(2);
            
            % The values generated are an ascending sequence of increment one in 
            % the range [0:999]*1e-3. The sequence starts with the previously used last
            % value; the values in the range are generated with mod(:,1000).
            % It is expected that the signal values are in the range [0:999]; the
            % resulting signal+noise sequence is 1.001, 2.002, 3.003 etc up to
            % ... 998.998, 999.999, 0, 1.001 and repeating.
            vals = mod(obj.got_to:obj.got_to+data_length-1,1000)*1e-3;
            
            % the sequence tracker is moved to the end of the positions processed.
            obj.got_to = obj.got_to + data_length;
        end
        
        function reset(obj)
            % allows the object to be reused for another test
            % by resetting the initialisation and position flags
            obj.init   = 1;
            obj.got_to = -666;
        end
    end

end

