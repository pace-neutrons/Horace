classdef test_deterministic_pseudorandom_sequence < TestCase
%=========================================================================
% Test(s) to ensure that the "pseudo-random" sequence generated by
% the noisify_test_rand class over multiple calls to one of its objects
% for the myrand method yield the same sequence as one created directly
% over an explicit single range.
%
% Cloned from "test_rand_like.m" without altering that script's 
% particular idiosyncrasies.
%=========================================================================

    properties
        % Current path for noisify_test_rand.
        % Needs to be added and removed from the path to make the
        % test function
        deterministic_pseudorandom_sequence_path = '../shared';
    end
    methods
        
        % constructor for the test class - constructs base
        % TestClass instance and minimally displays the name argument.
        function this=test_deterministic_pseudorandom_sequence(name)
            this = this@TestCase(name);
            disp(name)
            addpath(this.deterministic_pseudorandom_sequence_path);
        end
        
        function delete(this)
            rmpath(this.deterministic_pseudorandom_sequence_path);
        end
        
        % test function to verify operation of noisify_test_rand
        % tests one usage - see below for extended tests
        function test_if_single_deterministic_pseudorandom_sequence_ok(this)
            % find noisify_test_rand
            % create object for deterministic_psuedorandom_sequence to
            % initialise state at the start of the deterministic
            % sequence and hold the state for multiple calls.
            my_sequence_gen = deterministic_pseudorandom_sequence();
            % create one sequence of size sy1
            % NB sizes are designed to push the sequence through 
            %    the value 999 where the sequence restarts from 0
            sy = 1191;
            dy = my_sequence_gen.myrand([1,sy]); 
            % generate the full sequence that the above operations
            % ought to generate and test for equality
            ey = mod((1:sy),1000)*1e-3;
            assertEqual(dy,ey);
        end
        
        % test function to verify operation of noisify_test_rand
        % tests repeated usage for one distribution of equal size
        function test_if_equal_twocall_deterministic_pseudorandom_sequence_ok(this)
            % find noisify_test_rand
            % create object for deterministic_psuedorandom_sequence to
            % initialise state at the start of the deterministic
            % sequence and hold the state for multiple calls.
            my_sequence_gen = deterministic_pseudorandom_sequence();
            % create one sequence of size sy1
            % NB sizes are designed to push the sequence through 
            %    the value 999 where the sequence restarts from 0
            sy1 = 1191;
            dy1 = my_sequence_gen.myrand([1,sy1]);
            % create a second sequence of the same size, starting
            % after the endpoint of the first sequence
            sy2 = 1191;
            dy2 = my_sequence_gen.myrand([1,sy2]);
            % concatenate the two sequences
            dy = [dy1,dy2];
            % generate the full sequence that the above operations
            % ought to generate and test for equality
            ey = mod((1:sy1+sy2),1000)*1e-3;
            assertEqual(dy,ey);
        end
        
        % test function to verify operation of noisify_test_rand
        % tests repeated usage for one distribution of unequal sizes
        function test_if_unequal_twocall_deterministic_pseudorandom_sequence_ok(this)
            % find noisify_test_rand
            % create object for deterministic_psuedorandom_sequence to
            % initialise state at the start of the deterministic
            % sequence and hold the state for multiple calls.
            my_sequence_gen = deterministic_pseudorandom_sequence();
            % create one sequence of size sy1
            % NB sizes are designed to push the sequence through 
            %    the value 999 where the sequence restarts from 0
            sy1 = 1103;
            dy1 = my_sequence_gen.myrand([1,sy1]);
            % create a second sequence of the same size, starting
            % after the endpoint of the first sequence
            sy2 = 1047;
            dy2 = my_sequence_gen.myrand([1,sy2]);
            % concatenate the two sequences
            dy = [dy1,dy2];
            % generate the full sequence that the above operations
            % ought to generate and test for equality
            ey = mod((1:sy1+sy2),1000)*1e-3;
            assertEqual(dy,ey);
        end
        
        % repeat above equal test twice with an rnd reset between the two
        function test_if_repeated_equal_deterministic_pseudorandom_sequence_ok(this)
            % find noisify_test_rand
            % create object for deterministic_psuedorandom_sequence to
            % initialise state at the start of the deterministic
            % sequence and hold the state for multiple calls.
            my_sequence_gen = deterministic_pseudorandom_sequence();
            % create one sequence of size sy1
            % NB sizes are designed to push the sequence through 
            %    the value 999 where the sequence restarts from 0
            sy1 = 1191;
            dy1 = my_sequence_gen.myrand([1,sy1]);
            % create a second sequence of the same size, starting
            % after the endpoint of the first sequence
            sy2 = 1191;
            dy2 = my_sequence_gen.myrand([1,sy2]);
            % concatenate the two sequences
            dy = [dy1,dy2];
            % generate the full sequence that the above operations
            % ought to generate and test for equality
            ey = mod((1:sy1+sy2),1000)*1e-3;
            assertEqual(dy,ey);
            % test that the generator can reset its state to
            % what it was on construction: start of sequence
            my_sequence_gen.reset();
            % repeat above sequence #1 with a different size
            sz1 = sy1;
            dz1 = my_sequence_gen.myrand([1,sz1]);
            % repeat above sequence #2 using a different size
            sz2 = sy2;
            dz2 = my_sequence_gen.myrand([1,sz2]);
            dz = [dz1,dz2];
            % again generate the full sequence that the above operations
            % ought to generate and test for equality
            ez = mod((1:sz1+sz2),1000)*1e-3;
            assertEqual(dz,ez);
        end
        
        
        function test_if_repeated_unequal_deterministic_pseudorandom_sequence_ok(this)
            % find noisify_test_rand
            % create object for deterministic_psuedorandom_sequence to
            % initialise state at the start of the deterministic
            % sequence and hold the state for multiple calls.
            my_sequence_gen = deterministic_pseudorandom_sequence();
            % create one sequence of size sy1
            % NB sizes are designed to push the sequence through 
            %    the value 999 where the sequence restarts from 0
            sy1 = 1191;
            dy1 = my_sequence_gen.myrand([1,sy1]);
            % create a second sequence of the same size, starting
            % after the endpoint of the first sequence
            sy2 = 1191;
            dy2 = my_sequence_gen.myrand([1,sy2]);
            % concatenate the two sequences
            dy = [dy1,dy2];
            % generate the full sequence that the above operations
            % ought to generate and test for equality
            ey = mod((1:sy1+sy2),1000)*1e-3;
            assertEqual(dy,ey);
            % test that the generator can reset its state to
            % what it was on construction: start of sequence
            my_sequence_gen.reset();
            % repeat above sequence #1 with a different size
            sz1 = 1103;
            dz1 = my_sequence_gen.myrand([1,sz1]);
            % repeat above sequence #2 using a different size
            sz2 = 1047;
            dz2 = my_sequence_gen.myrand([1,sz2]);
            dz = [dz1,dz2];
            % again generate the full sequence that the above operations
            % ought to generate and test for equality
            ez = mod((1:sz1+sz2),1000)*1e-3;
            assertEqual(dz,ez);
        end
    end
end