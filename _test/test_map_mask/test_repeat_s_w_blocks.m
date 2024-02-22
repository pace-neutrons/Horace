classdef test_repeat_s_w_blocks < TestCase
    % Test private utility function of IX_map named repeat_s_w_blocks
    % That function takes a descriptor that defines blocks of workspace and
    % spectra and also appends multiple copies of those blocks with offsets
    % according to input argument nrepeat.
    % See the function repeat_s_w_blocks for details.
    
    methods
        %-----------------------------------------------------------------------
        function test_oneDescriptor_repeatedBlock (~)
            % Single workspace-spectra descriptor with multiple repeats of the
            % defined blocks of workspaces and spectra
            
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
            % Single workspace-spectra descriptor with multiple repeats of the
            % defined blocks of workspaces and spectra
            % This tests that what was originally an obscure bug is not
            % inadvertently reinstituted: if the number of spectra in the full
            % spectrum range (s_beg to s_end) is an exact multiple of the
            % number of spectra grouped into one workspace (ngroup) the bug was
            % also creating a final workspace with zero spectra.
            
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
            % Single workspace-spectra descriptor with multiple repeats of the
            % defined blocks of workspaces and spectra, in this test with
            % negative s_dcn and w_dcn
            
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
            % Two workspace-spectra descriptor each with multiple repeats
            % of the defined blocks of workspaces and spectra. One descriptor
            % has negative s_dcn and w_dcn
            
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
            % Two workspace-spectra descriptor each with multiple repeats
            % of the defined blocks of workspaces and spectra.
            % Placeholder initial workspace number and offsets (w_beg and
            % delta_w) on the second descriptor to be determined within
            % repeat_s_w_blocks after the first block is constructed.
            
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
        function test_twoDescriptors_repeatedBlocks_wGoesNegative_ERROR (~)
            % Create an error condition with two workspace-spectra descriptors
            % where the workspace numbers defined by the block descriptors go
            % negative - not permitted as workpsace numbers must be positive.
            
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
            assertTrue(contains(ME.message, ['Workspace array constructed for ',...
            'at least one block descriptor includes zero or negative workspace numbers']))
        end
        
        %-----------------------------------------------------------------------
    end
end
