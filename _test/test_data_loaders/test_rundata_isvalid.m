classdef test_rundata_isvalid<TestCase
    
    properties
        log_level;
    end
    
    methods
        function this=test_rundata_isvalid(name)
            this = this@TestCase(name);
        end
        function this=setUp(this)
            this.log_level = get(herbert_config,'log_level');
            set(herbert_config,'log_level',-1,'-buffer');
        end
        function this=tearDown(this)
            set(herbert_config,'log_level',this.log_level,'-buffer');
        end
        
        %
        function this=test_SERR(this)
            rd = rundata();
            rd.S = ones(3,5);
            assertTrue(~isvalid(rd));
            rd.ERR=ones(4,7);
            [ok,mess]=isvalid(rd);
            assertFalse(ok);
            base_mess = ' field: S has to be numeric but its value is: ill defined';
            assertTrue(strncmp(base_mess,mess,numel(base_mess)));
            rd.ERR=zeros(3,5);
            [ok,mess]=isvalid(rd);
            assertFalse(ok);
            base_mess = ' field: S has to be numeric but its value is: ill defined';
            assertTrue(strncmp(base_mess,mess,numel(base_mess)));
            
        end
        function this = test_Sen(this)
            rd=rundata();
            rd.en = ones(5,1);
            assertTrue(isvalid(rd));
            rd.en = ones(1,5);
            [ok,mess,rd]=isvalid(rd);
            assertTrue(ok);
            assertTrue(isempty(mess));
            assertEqual(size(rd.en),[5,1]);
            
            rd.S = ones(4,6);
            [ok,mess]=isvalid(rd);
            assertFalse(ok);
            % S is ill-defined
            base_mess = ' field: S has to be numeric but its value is: ill defined';
            assertTrue(strncmp(base_mess,mess,numel(base_mess)));
            
            
            rd.ERR = ones(4,6);
            assertTrue(isvalid(rd));
        end
        function this = test_enEfix(this)
            rd=rundata();
            rd.efix = 6;
            assertTrue(isvalid(rd));
            
            rd.en=(1:10)';
            [ok,mess]=isvalid(rd);
            assertTrue(~ok);
            base_mess = ' field: efix has to be numeric but its value is: Emode=1';
            assertTrue(strncmp(base_mess,mess,numel(base_mess)));
            
            
            rd.en=(1:6)';
            assertTrue(isvalid(rd));
        end
        function this = test_det_par(this)
            rd=rundata();
            rd.det_par = ones(6,3);
            assertTrue(isvalid(rd));
            
            %rd.det_par =
            %[ok,mess]=isvalid(rd);
            %assertFalse(ok);
            f = @()get_hor_format(ones(5,3),'');
            assertExceptionThrown(f,'GET_HOR_FORMAT:invalid_file_format');
            %assertEqual(mess,'det_par field has to be a [6xndet] array, but has: 5 columns');
            
            rd.det_par = ones(6,10);
            rd.S       = ones(3,9);
            [ok,mess]=isvalid(rd);
            assertFalse(ok);
            base_mess = ' field: S has to be numeric but its value is: ill defined';
            assertTrue(strncmp(base_mess,mess,numel(base_mess)));
            
            rd.S       = ones(3,10);
            rd.ERR     = zeros(3,10);
            rd.en      = 1:4;
            assertTrue(isvalid(rd));
        end
        function this = test_is_crystal(this)
            rd=rundata();
            assertTrue(isvalid(rd));
            
            rd.lattice = oriented_lattice();
            assertTrue(isvalid(rd));
            
            ws=warning('off','MATLAB:subsasgnMustHaveOutput');
            f=@()subsasgn(rd,struct('type','.','subs','is_crystal'),3);
            assertExceptionThrown(f,'RUNDATA:set_is_crystal');
            warning(ws);
        end
        function this = test_3vectors(this)
            rd=rundata();
            
            rd = set_lattice_field(rd,'u',[1,2,3]);
            rd = set_lattice_field(rd,'v',[3;4;5]);
            rd = set_lattice_field(rd,'alatt',1:3);
            rd = set_lattice_field(rd,'angdeg',(2:4)');
            
            [ok,mess]=isvalid(rd);
            assertTrue(ok);
            assertEqual(mess,'');
        end
        
        function this = test_1vectors(this)
            rd=rundata();
            rd.is_crystal = true;
            
            rd.lattice.gl=0;
            rd.lattice.gs=1;
            rd.lattice.psi=1;
            rd.lattice.omega=10;
            rd.lattice.dpsi=-10;
            
            [ok,mess]=isvalid(rd);
            assertTrue(ok);
            assertEqual(mess,'');
        end
        function this = test_degrees(this)
            rd=rundata();
            rd.is_crystal = true;
            rd.lattice.gl=0;
            
            rd.lattice.angdeg=[45,90,50];
            [ok,mess]=isvalid(rd);
            assertTrue(ok);
            assertEqual(mess,'');
        end
        
        
    end
    
end

