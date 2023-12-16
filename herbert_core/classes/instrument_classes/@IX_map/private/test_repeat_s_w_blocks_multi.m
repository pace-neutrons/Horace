classdef test_repeat_s_w_blocks_multi < TestCase
    % Test repeat_s_w_blocks_multi
    
    methods
        %-----------------------------------------------------------------------
        function test_1 (~)
            % Single block descriptor
            
            isp_beg = 11;
            isp_end = 16;
            ngroup = 4;
            isp_dcn = 1;
            iw_beg = 5;
            iw_dcn = 1;
            nrepeat = 3;
            delta_sp = 10;
            delta_w = 100;
            
            is_ref = [11:16 21:26 31:36]';
            iw_ref = [5 5 5 5 6 6, 105 105 105 105 106 106 205 205 205 205 206 206]';
            [is_out, iw_out] = repeat_s_w_blocks_multi (isp_beg, isp_end, ...
                ngroup, isp_dcn, iw_beg, iw_dcn, nrepeat, delta_sp, delta_w);
            assertEqual (is_out, is_ref)
            assertEqual (iw_out, iw_ref)
        end
        
        %-----------------------------------------------------------------------
        function test_1a (~)
            % Single block descriptor with negative isp_dcn and iw_dcn
            
            isp_beg = 56;
            isp_end = 51;
            ngroup = 5;
            isp_dcn = -1;
            iw_beg = 8;
            iw_dcn = -1;
            nrepeat = 2;
            delta_sp = 12;
            delta_w = 20;
            
            is_ref = [56:-1:51 68:-1:63]';
            iw_ref = [8 8 8 8 8 7, 28 28 28 28 28 27]';
            [is_out, iw_out] = repeat_s_w_blocks_multi (isp_beg, isp_end, ...
                ngroup, isp_dcn, iw_beg, iw_dcn, nrepeat, delta_sp, delta_w);
            assertEqual (is_out, is_ref)
            assertEqual (iw_out, iw_ref)
        end
        
        %-----------------------------------------------------------------------
        function test_2 (~)
            % Multiple block descriptors
            
            isp_beg = [11,56];
            isp_end = [16,51];
            ngroup = [4,5];
            isp_dcn = [1,-1];
            iw_beg = [5,8];
            iw_dcn = [1,-1];
            nrepeat = [3,2];
            delta_sp = [10,12];
            delta_w = [100,20];
            
            is_ref = [11:16 21:26 31:36 56:-1:51 68:-1:63]';
            iw_ref = [5 5 5 5 6 6, 105 105 105 105 106 106 ...
                205 205 205 205 206 206 8 8 8 8 8 7, 28 28 28 28 28 27]';
            [is_out, iw_out] = repeat_s_w_blocks_multi (isp_beg, isp_end, ...
                ngroup, isp_dcn, iw_beg, iw_dcn, nrepeat, delta_sp, delta_w);
            assertEqual (is_out, is_ref)
            assertEqual (iw_out, iw_ref)
        end
        
        %-----------------------------------------------------------------------
        function test_2a (~)
            % Two block descriptors, placeholder iw_beg and delta_w on second
            
            isp_beg = [11,56];
            isp_end = [16,51];
            ngroup = [4,5];
            isp_dcn = [1,-1];
            iw_beg = [5,NaN];
            iw_dcn = [1,-1];
            nrepeat = [3,2];
            delta_sp = [10,12];
            delta_w = [100,NaN];
            
            is_ref = [11:16 21:26 31:36 56:-1:51 68:-1:63]';
            iw_ref = [5 5 5 5 6 6, 105 105 105 105 106 106 ...
                205 205 205 205 206 206 208 208 208 208 208 207, 210 210 210 210 210 209]';
            [is_out, iw_out] = repeat_s_w_blocks_multi (isp_beg, isp_end, ...
                ngroup, isp_dcn, iw_beg, iw_dcn, nrepeat, delta_sp, delta_w);
            assertEqual (is_out, is_ref)
            assertEqual (iw_out, iw_ref)
        end
        
        %-----------------------------------------------------------------------
        function test_3 (~)
            % Workspaces go < 1. Should fail
            
            isp_beg = [11,56];
            isp_end = [16,51];
            ngroup = [4,5];
            isp_dcn = [1,-1];
            iw_beg = [1,NaN];
            iw_dcn = [-1,-1];
            nrepeat = [3,2];
            delta_sp = [10,12];
            delta_w = [100,NaN];
            
            func = @()repeat_s_w_blocks_multi (isp_beg, isp_end, ...
                ngroup, isp_dcn, iw_beg, iw_dcn, nrepeat, delta_sp, delta_w);
            
            assertExceptionThrown (func, 'IX_map:invalid_argument');
        end
        
        %-----------------------------------------------------------------------
    end
end
