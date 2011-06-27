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
           nDet = this.spe_data.nDetectors;
           det_sample=1:nDet;
           assertEqual(det.group,det_sample);
           
           % samples, based on particular values, obtained from MAP11014           
           assertEqual(det.phi(1),     5.866932879559765);
           assertEqual(det.phi(nDet),19.537259416041927);           

           assertEqual(det.azim(1),      59.33325299493517);
           assertEqual(det.azim(nDet),-107.13442361911451);           

           assertEqual(det.width(1),      0.26707200839453427);
           assertEqual(det.width(nDet), 0.3681035530150125);           
           assertEqual(det.height(1),     0.2999842562055065);
           assertEqual(det.height(nDet),0.3502617512439143); 

           assertEqual(det.x2(1),     6.023328912324858);
           assertEqual(det.x2(nDet),6.0368611720148655);     
           
           assertEqual(det.filepath,['.',filesep]);
           assertEqual(det.filename,'MAP11014.nxspe');           
           
        end        
    end
end