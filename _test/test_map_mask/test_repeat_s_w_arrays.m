classdef test_repeat_s_w_arrays < TestCase
    % Test private utility function of IX_map named repeat_s_w_arrays
    % That function appends copies of arrays of workspace and spectrum numbers
    % with offsets multiple times according as its input argument nrepeat.
    % See that function for details of its functionality.
    
    methods
        %-----------------------------------------------------------------------
        function test_oneRepeat (~)
            % nrepeat = 1 i.e. no appended copies of workspaces and spectra
            % arrays. Tests the possibility of branch that makes trivial return
            
            wkno = [10 12 14 15];
            ns = [1 3 0 1];
            s = [1 4 5 2 7];
            nrepeat = 1;
            delta_s = 10;
            delta_w = 2;
                        
            wkno_ref = wkno(:);
            ns_ref = ns(:);
            s_ref = s(:);
            [wkno_out, ns_out, s_out] = exposed_IX_map.repeat_s_w_arrays ...
                (wkno, ns, s, nrepeat, delta_s, delta_w);
            assertEqual (wkno_out, wkno_ref)
            assertEqual (ns_out, ns_ref)
            assertEqual (s_out, s_ref)
        end
        
        %-----------------------------------------------------------------------
        function test_manyRepeats (~)
            % nrepeat = 3 i.e. three appended copies of workspace and spectra
            % arrays with offsets.
            
            wkno = [10 12 14 15];
            ns = [1 3 0 1];
            s = [1 4 5 2 7];
            nrepeat = 3;
            delta_s = 10;
            delta_w = 2;
                        
            wkno_ref = [10 12 14 15 12 14 16 17 14 16 18 19]';
            ns_ref = [1 3 0 1 1 3 0 1 1 3 0 1]';
            s_ref = [1 4 5 2 7 11 14 15 12 17 21 24 25 22 27]';
            [wkno_out, ns_out, s_out] = exposed_IX_map.repeat_s_w_arrays ...
                (wkno, ns, s, nrepeat, delta_s, delta_w);
            assertEqual (wkno_out, wkno_ref)
            assertEqual (ns_out, ns_ref)
            assertEqual (s_out, s_ref)
        end
        
        %-----------------------------------------------------------------------
    end
end
