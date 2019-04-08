classdef test_get_par< TestCase
    %
    % $Revision:: 1750 ($Date:: 2019-04-08 17:55:21 +0100 (Mon, 8 Apr 2019) $)
    %
    
    properties
    end
    methods
        %
        function this=test_get_par(name)
            this = this@TestCase(name);
        end
        % tests themself
        function test_wrong_file_name(this)
            f = @()get_par('non-existent-file-name');
            assertExceptionThrown(f,'LOADERS_FACTORY:get_loader');
        end
        function test_get_par_from_ASCII(this)
            par = get_par('one2one_112.par','-array');
            assertEqual([6,69632],size(par));
        end
        function test_gethor_par_from_ASCII(this)
            par = get_par('one2one_112.par');
            assertTrue(isstruct(par));
            assertTrue(isfield(par,'x2'));
            assertTrue(isfield(par,'phi'));
            assertTrue(isfield(par,'azim'));
            assertTrue(isfield(par,'width'));
            assertTrue(isfield(par,'height'));
            
            parar=get_par('one2one_112.par','-nohor');
            assertTrue(all(parar(3,:)==par.azim));
        end
        function test_wrong_data_format_ignored(this)
            par = get_par('one2one_112.par','-nohor');
            assertTrue(~isstruct(par));
            assertEqual([6,69632],size(par));
        end
        function test_get_par_nxspe(this)
            parar = get_par('MAR11001_test.nxspe','-nohor');
            assertTrue(~isstruct(parar));
            
            assertEqual([6,285],size(parar));
            
            par = get_par('MAR11001_test.nxspe');
            assertTrue(all(parar(3,:)== par.azim));
        end
        
        
    end
end

