classdef test_repeat_s_w_blocks < TestCase
    % Test repeat_s_w_blocks
    
    methods
        %-----------------------------------------------------------------------
        function test_oneDescriptor_repeatedBlock (~)
            % Single grouping descriptor
            
            isp_beg = 11;
            isp_end = 16;
            ngroup = 4;
            isp_dcn = 1;
            iw_beg = 5;
            iw_dcn = 1;
            nrepeat = 3;
            delta_isp = 10;
            delta_iw = 100;
            
            is_ref = [11:16 21:26 31:36]';
            iw_ref = [5 5 5 5 6 6, 105 105 105 105 106 106 205 205 205 205 206 206]';
            [is_out, iw_out] = exposed_IX_map.repeat_s_w_blocks (isp_beg, isp_end, ...
                ngroup, isp_dcn, iw_beg, iw_dcn, nrepeat, delta_isp, delta_iw);
            assertEqual (is_out, is_ref)
            assertEqual (iw_out, iw_ref)
        end
        
        %-----------------------------------------------------------------------
        function test_oneDescriptor_repeatedBlock_spNegDcn_wNegDcn (~)
            % Single block descriptor with negative isp_dcn and iw_dcn
            
            isp_beg = 56;
            isp_end = 51;
            ngroup = 5;
            isp_dcn = -1;
            iw_beg = 8;
            iw_dcn = -1;
            nrepeat = 2;
            delta_isp = 12;
            delta_iw = 20;
            
            is_ref = [56:-1:51 68:-1:63]';
            iw_ref = [8 8 8 8 8 7, 28 28 28 28 28 27]';
            [is_out, iw_out] = exposed_IX_map.repeat_s_w_blocks (isp_beg, isp_end, ...
                ngroup, isp_dcn, iw_beg, iw_dcn, nrepeat, delta_isp, delta_iw);
            assertEqual (is_out, is_ref)
            assertEqual (iw_out, iw_ref)
        end
        
        %-----------------------------------------------------------------------
        function test_twoDescriptors_repeatedBlocks_spMixedDcn_wMixedDcn (~)
            % Multiple block descriptors
            
            isp_beg = [11,56];
            isp_end = [16,51];
            ngroup = [4,5];
            isp_dcn = [1,-1];
            iw_beg = [5,8];
            iw_dcn = [1,-1];
            nrepeat = [3,2];
            delta_isp = [10,12];
            delta_iw = [100,20];
            
            is_ref = [11:16 21:26 31:36 56:-1:51 68:-1:63]';
            iw_ref = [5 5 5 5 6 6, 105 105 105 105 106 106 ...
                205 205 205 205 206 206 8 8 8 8 8 7, 28 28 28 28 28 27]';
            [is_out, iw_out] = exposed_IX_map.repeat_s_w_blocks (isp_beg, isp_end, ...
                ngroup, isp_dcn, iw_beg, iw_dcn, nrepeat, delta_isp, delta_iw);
            assertEqual (is_out, is_ref)
            assertEqual (iw_out, iw_ref)
        end
        
        %-----------------------------------------------------------------------
        function test_twoDescriptors_repeatedBlocks_wPlaceholders (~)
            % Two block descriptors, placeholder iw_beg and delta_iw on second
            
            isp_beg = [11,56];
            isp_end = [16,51];
            ngroup = [4,5];
            isp_dcn = [1,-1];
            iw_beg = [5,NaN];
            iw_dcn = [1,-1];
            nrepeat = [3,2];
            delta_isp = [10,12];
            delta_iw = [100,NaN];
            
            is_ref = [11:16 21:26 31:36 56:-1:51 68:-1:63]';
            iw_ref = [5 5 5 5 6 6, 105 105 105 105 106 106 ...
                205 205 205 205 206 206 208 208 208 208 208 207, 210 210 210 210 210 209]';
            [is_out, iw_out] = exposed_IX_map.repeat_s_w_blocks (isp_beg, isp_end, ...
                ngroup, isp_dcn, iw_beg, iw_dcn, nrepeat, delta_isp, delta_iw);
            assertEqual (is_out, is_ref)
            assertEqual (iw_out, iw_ref)
        end
        
        %-----------------------------------------------------------------------
        function test_twoDescriptors_repeatedBlocks_wGoesnegative_ERROR (~)
            % Workspaces go < 1. Should fail
            
            isp_beg = [11,56];
            isp_end = [16,51];
            ngroup = [4,5];
            isp_dcn = [1,-1];
            iw_beg = [1,NaN];
            iw_dcn = [-1,-1];
            nrepeat = [3,2];
            delta_isp = [10,12];
            delta_iw = [100,NaN];
            
            func = @()exposed_IX_map.repeat_s_w_blocks (isp_beg, isp_end, ...
                ngroup, isp_dcn, iw_beg, iw_dcn, nrepeat, delta_isp, delta_iw);
            
            assertExceptionThrown (func, 'IX_map:invalid_argument');
        end
        
        %-----------------------------------------------------------------------
    end
end
