classdef test_repeat_s_w_blocks < TestCase
    % Test repeat_s_w_blocks
    
    methods
        %-----------------------------------------------------------------------
        function test_oneDescriptor_repeatedBlock (~)
            % Single grouping descriptor
            
            s_beg = 11;
            s_end = 16;
            ngroup = 4;
            s_dcn = 1;
            w_beg = 5;
            w_dcn = 1;
            nrepeat = 3;
            delta_s = 10;
            delta_w = 100;
            
            wkno_ref = [5; 6; 105; 106; 205; 206];
            ns_ref = [4; 2; 4; 2; 4; 2];
            s_ref = [11:16 21:26 31:36]';
            
            [wkno, ns, s_out] = exposed_IX_map.repeat_s_w_blocks (s_beg, s_end, ...
                ngroup, s_dcn, w_beg, w_dcn, nrepeat, delta_s, delta_w);
            assertEqual (wkno, wkno_ref)
            assertEqual (ns, ns_ref)
            assertEqual (s_out, s_ref)
        end
        
        %-----------------------------------------------------------------------
        function test_oneDescriptor_repeatedBlock_exactGrouping (~)
            % Single grouping descriptor
            % Catches an error that earlier was not spotted: if the spectrum
            % range is an exact multiple of the spectrum grouping: was adding a
            % workspace with zero spectra.
            
            s_beg = 11;
            s_end = 18;
            ngroup = 4;
            s_dcn = 1;
            w_beg = 5;
            w_dcn = 1;
            nrepeat = 3;
            delta_s = 10;
            delta_w = 100;
            
            wkno_ref = [5; 6; 105; 106; 205; 206];
            ns_ref = [4; 4; 4; 4; 4; 4];
            s_ref = [11:18 21:28 31:38]';
            
            [wkno, ns, s_out] = exposed_IX_map.repeat_s_w_blocks (s_beg, s_end, ...
                ngroup, s_dcn, w_beg, w_dcn, nrepeat, delta_s, delta_w);
            assertEqual (wkno, wkno_ref)
            assertEqual (ns, ns_ref)
            assertEqual (s_out, s_ref)
        end
        
        %-----------------------------------------------------------------------
        function test_oneDescriptor_repeatedBlock_spNegDcn_wNegDcn (~)
            % Single block descriptor with negative s_dcn and w_dcn
            
            s_beg = 56;
            s_end = 51;
            ngroup = 5;
            s_dcn = -1;
            w_beg = 8;
            w_dcn = -1;
            nrepeat = 2;
            delta_s = 12;
            delta_w = 20;
            
            wkno_ref = [8; 7; 28; 27];
            ns_ref = [5; 1; 5; 1];
            s_ref = [56:-1:51 68:-1:63]';
            
            [wkno, ns, s_out] = exposed_IX_map.repeat_s_w_blocks (s_beg, s_end, ...
                ngroup, s_dcn, w_beg, w_dcn, nrepeat, delta_s, delta_w);
            assertEqual (wkno, wkno_ref)
            assertEqual (ns, ns_ref)
            assertEqual (s_out, s_ref)
        end
        
        %-----------------------------------------------------------------------
        function test_twoDescriptors_repeatedBlocks_spMixedDcn_wMixedDcn (~)
            % Multiple block descriptors
            
            s_beg = [11,56];
            s_end = [16,51];
            ngroup = [4,5];
            s_dcn = [1,-1];
            w_beg = [5,8];
            w_dcn = [1,-1];
            nrepeat = [3,2];
            delta_s = [10,12];
            delta_w = [100,20];
            
            wkno_ref = [5; 6; 105; 106; 205; 206; 8; 7; 28; 27];
            ns_ref = [4; 2; 4; 2; 4; 2; 5; 1; 5; 1];
            s_ref = [11:16 21:26 31:36 56:-1:51 68:-1:63]';
            
            [wkno, ns, s_out] = exposed_IX_map.repeat_s_w_blocks (s_beg, s_end, ...
                ngroup, s_dcn, w_beg, w_dcn, nrepeat, delta_s, delta_w);
            assertEqual (wkno, wkno_ref)
            assertEqual (ns, ns_ref)
            assertEqual (s_out, s_ref)
        end
        
        %-----------------------------------------------------------------------
        function test_twoDescriptors_repeatedBlocks_wPlaceholders (~)
            % Two block descriptors, placeholder w_beg and delta_w on second
            
            s_beg = [11,56];
            s_end = [16,51];
            ngroup = [4,5];
            s_dcn = [1,-1];
            w_beg = [5,NaN];
            w_dcn = [1,-1];
            nrepeat = [3,2];
            delta_s = [10,12];
            delta_w = [100,NaN];
            
            wkno_ref = [5; 6; 105; 106; 205; 206; 208; 207; 210; 209];
            ns_ref = [4; 2; 4; 2; 4; 2; 5; 1; 5; 1];
            s_ref = [11:16 21:26 31:36 56:-1:51 68:-1:63]';
            [wkno, ns, s_out] = exposed_IX_map.repeat_s_w_blocks (s_beg, s_end, ...
                ngroup, s_dcn, w_beg, w_dcn, nrepeat, delta_s, delta_w);
            assertEqual (wkno, wkno_ref)
            assertEqual (ns, ns_ref)
            assertEqual (s_out, s_ref)
        end
        
        %-----------------------------------------------------------------------
        function test_twoDescriptors_repeatedBlocks_wGoesnegative_ERROR (~)
            % Workspaces go < 1. Should fail
            
            s_beg = [11,56];
            s_end = [16,51];
            ngroup = [4,5];
            s_dcn = [1,-1];
            w_beg = [1,NaN];
            w_dcn = [-1,-1];
            nrepeat = [3,2];
            delta_s = [10,12];
            delta_w = [100,NaN];
            
            func = @()exposed_IX_map.repeat_s_w_blocks (s_beg, s_end, ...
                ngroup, s_dcn, w_beg, w_dcn, nrepeat, delta_s, delta_w);
            
            ME = assertExceptionThrown (func, 'HERBERT:IX_map:invalid_argument');
            assertTrue(contains(ME.message, 'Workspace array constructed for'))
        end
        
        %-----------------------------------------------------------------------
    end
end
