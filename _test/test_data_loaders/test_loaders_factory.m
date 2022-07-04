classdef test_loaders_factory< TestCase
    properties
        test_data_path;
    end
    methods
        %
        function this=test_loaders_factory(name)
            this = this@TestCase(name);
            [~,tdp] = herbert_root();
            this.test_data_path = tdp;
        end
        
        function test_select_loader_throws(this)
            not_a_file = 'non_existing_file';
            not_a_data = fullfile(this.test_data_path,'map_4to1_jul09.par');
            
            
            f = @()loaders_factory.instance().get_loader(not_a_file);
            assertExceptionThrown(f,'LOADERS_FACTORY:get_loader');
            f = @()loaders_factory.instance().get_loader(not_a_data);
            assertExceptionThrown(f,'LOADERS_FACTORY:get_loader');
        end
        
        function test_select_loader(this)
            ascii_spe  = fullfile(this.test_data_path,'MAP10001.spe');
            nxspe_f    = fullfile(this.test_data_path,'MAP11014v2.nxspe');
            
            
            asc_loader=loaders_factory.instance().get_loader(ascii_spe);
            nxspe_ld =  loaders_factory.instance().get_loader(nxspe_f);
            
            assertTrue(isa(asc_loader,'loader_ascii'))
            assertTrue(isa(nxspe_ld,'loader_nxspe'))
        end
        
    end
end
