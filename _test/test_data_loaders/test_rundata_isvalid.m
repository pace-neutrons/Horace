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
            rd.is_crystal = false;
            assertTrue(isvalid(rd));
            
            rd.is_crystal = true;
            assertTrue(isvalid(rd));
            
            ws=warning('off','MATLAB:subsasgnMustHaveOutput');            
            f=@()subsasgn(rd,struct('type','.','subs','is_crystal'),3);
            assertExceptionThrown(f,'RUNDATA:set_is_crystal');
            warning(ws);
        end
        function this = test_3vectors(this)
            rd=rundata();
            %rd.u='a';
            ws=warning('off','MATLAB:subsasgnMustHaveOutput');
            f=@()subsasgn(rd,struct('type','.','subs','u'),'a');
            assertExceptionThrown(f,'RUNDATA:invalid_argument');
            
            %rd.u=1;
            f=@()subsasgn(rd,struct('type','.','subs','u'),1);
            assertExceptionThrown(f,'RUNDATA:invalid_argument');
            warning(ws);
            
            rd.u=[1,2,3];
            rd.v=[3;4;5];
            rd.alatt=1:3;
            rd.angldeg=(2:4)';
            [ok,mess]=isvalid(rd);
            assertTrue(ok);
            assertEqual(mess,'');
        end
        function this = test_1vectors(this)
            rd=rundata();
            %rd.gl='a';
            ws=warning('off','MATLAB:subsasgnMustHaveOutput');            
            f=@()subsasgn(rd,struct('type','.','subs','gl'),'a');
            %            assertEqual(mess,' field: gl has to be numeric but it is not');
            assertExceptionThrown(f,'RUNDATA:set_angular_value');
            
            
            %rd.gl=[1,2];
            f=@()subsasgn(rd,struct('type','.','subs','gl'),[1,2]);
            %            assertEqual(mess,' field: gl has to have 1 element but has: 2
            %            element(s)');
            assertExceptionThrown(f,'RUNDATA:set_angular_value');
            
            f=@()subsasgn(rd,struct('type','.','subs','gl'),400);
            %            assertEqual(mess,' field: gl has to in range of +-360 deg but it is not');
            assertExceptionThrown(f,'RUNDATA:set_angular_value');
            warning(ws);
            
            rd.gl=0;
            rd.gs=1;
            rd.psi=1;
            rd.omega=10;
            rd.dpsi=-10;
            
            [ok,mess]=isvalid(rd);
            assertTrue(ok);
            assertEqual(mess,'');
        end
        function this = test_degrees(this)
            rd=rundata();
            rd.gl=0;          
            
            rd.angldeg=[45,90,50];
            [ok,mess]=isvalid(rd);
            assertTrue(ok);
            assertEqual(mess,'');
        end
        function this = test_LatticeCorrect(this)
            rd=rundata();
            %rd.angldeg = [-400,0,0]
            ws=warning('off','MATLAB:subsasgnMustHaveOutput');            
            f=@()subsasgn(rd,struct('type','.','subs','angldeg'),[-400,0,0]);
            assertExceptionThrown(f,'RUNDATA:set_lattice_angles');
            
            %assertEqual(mess,'field ''angldeg'' does not define correct 3D lattice');
            %rd.angldeg = [45,120,45]
            f=@()subsasgn(rd,struct('type','.','subs','angldeg'),[45,120,50]);
            assertExceptionThrown(f,'RUNDATA:set_lattice_angles');
            warning(ws);
        end
        
        
    end
    
end

