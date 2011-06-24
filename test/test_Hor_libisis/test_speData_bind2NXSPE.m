classdef test_speData_bind2NXSPE< TestCase
    properties 
       spe_data;
    end
    methods       
        % 
        function this=test_speData_bind2NXSPE(name)
            this = this@TestCase(name);
        end
        function setUp(this)         
            this.spe_data=speData('MAP11014.nxspe');
        end  
        function teadDown(this)
            delete(this.spe_data);
        end
        % tests themself
        function test_GetSpeHeaderCorrect(this)       
            assertEqual((this.spe_data.fileName),'MAP11014');
            assertEqual((this.spe_data.fileExt),'.nxspe');            
            assertEqual((this.spe_data.data_loaded),false);
            assertEqual((this.spe_data.nDetectors),28160);                        
            en = this.spe_data.en;
            en_grid = [0:5:150]';
            assertEqual(en_grid,en);
        end
    
       function test_getPar(this)       
           det = getPar(this.spe_data);
           phi_sample=1:2:10;
           assertEqual(det.phi,phi_sample);
        end        
    end
end