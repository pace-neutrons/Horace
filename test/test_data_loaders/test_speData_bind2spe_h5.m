classdef test_speData_bind2spe_h5< TestCase
    properties 
       spe_data;
    end
    methods       
        % 
        function this=test_speData_bind2spe_h5(name)
            this = this@TestCase(name);
        end
        function setUp(this)         
            this.spe_data=speData('MAP11020.spe_h5 ');
        end  
        function teadDown(this)
            delete(this.spe_data);
        end
        % tests themself
        function test_GetSpeHeaderCorrect(this)       
            assertEqual((this.spe_data.fileName),'MAP11020');
            assertEqual((this.spe_data.fileExt),'.spe_h5');            
            assertEqual((this.spe_data.data_loaded),false);
            assertEqual((this.spe_data.nDetectors),28160);                        
            en = this.spe_data.en;
            en_grid = [0:5:150]';
            assertEqual(en_grid,en);
        end
         function test_GetEi(this)       
            assertEqual(getEi(this.spe_data),786.9);
        end                
    
    end
end