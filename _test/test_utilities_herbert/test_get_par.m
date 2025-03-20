classdef test_get_par< TestCase
    %
    %    
    properties
        small_nxspe_file_path        
    end
    methods
        %
        function obj=test_get_par(name)
            obj = obj@TestCase(name);
            hp = horace_paths;
            obj.small_nxspe_file_path = fullfile(hp.test_common,'MAR11001_test.nxspe');            
        end
        % tests themself
        function test_wrong_file_name(this)
            f = @()get_par('non-existent-file-name');
            assertExceptionThrown(f,'HERBERT:loaders_factory:invalid_argument');
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
        %
        function test_get_par_nxspe(obj)
            parar = get_par(obj.small_nxspe_file_path,'-nohor');
            assertTrue(~isstruct(parar));
            
            assertEqual([6,285],size(parar));
            
            par = get_par(obj.small_nxspe_file_path);
            assertTrue(all(parar(3,:)== par.azim));
        end
        
        
    end
end

