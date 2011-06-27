classdef test_find_root_nxspeDir< TestCase
    properties 
    end
    methods       
        % 
        function this=test_find_root_nxspeDir(name)
            this = this@TestCase(name);
        end
        % tests themself
        function test_FormatCurrentlyNotSupported(this)               
            f = @()find_root_nxspeDir('currently_not_supported_NXSPE.nxspe');            
            assertExceptionThrown(f,'ISIS_UTILITES:find_root_nxspeDir');
        end               
        function test_CorrectHeader(this)       
            result = find_root_nxspeDir('MAP11014.nxspe'); % file name has no relation to the result
            assertEqual(result{1},'/11014.spe');
        end               

        
    end
end

