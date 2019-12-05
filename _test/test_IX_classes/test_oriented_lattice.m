classdef test_oriented_lattice< TestCase
    %
    % $Revision:: 833 ($Date:: 2019-10-24 20:46:09 +0100 (Thu, 24 Oct 2019) $)
    %
    
    properties
        test_data_path;
    end
    methods
        %
        function this=test_oriented_lattice(varargin)
            if nargin == 0
                name = 'test_oriented_lattice';
            else
                name = varargin{1};
            end
            this = this@TestCase(name);
            [~,tdp] = herbert_root();
            this.test_data_path = tdp;
        end
        
        function test_constructor_defaults(this)
            ol = oriented_lattice();
            default_fld = oriented_lattice.fields_with_defaults();
            for i=1:numel(default_fld)
                cur_field = default_fld{i};
                if strcmp(cur_field,'u')
                    assertEqual([1,0,0],ol.u);
                    continue
                end
                if strcmp(cur_field,'v')
                    assertEqual([0,1,0],ol.v);
                    continue
                end
                assertEqual(0,ol.(cur_field));
            end
        end
        %
        function test_degrees_rad(this)
            ol = oriented_lattice();
            ol.psi   = 10;
            ol.omega = 20;
            ol.dpsi  = 30;
            ol.gl    = 40;
            ol.gs    = 50;
            ol.angdeg= 90;
            assertEqual('deg',ol.angular_units)
            
            ol = ol.set_rad();
            assertEqual('rad',ol.angular_units)
            
            toRad=pi/180.;
            assertElementsAlmostEqual(10*toRad,ol.psi)
            assertElementsAlmostEqual(20*toRad,ol.omega)
            assertElementsAlmostEqual(30*toRad,ol.dpsi)
            assertElementsAlmostEqual(40*toRad,ol.gl)
            assertElementsAlmostEqual(50*toRad,ol.gs)
            
            ol=ol.set_deg();
            assertElementsAlmostEqual(10,ol.psi)
            assertElementsAlmostEqual(20,ol.omega)
            assertElementsAlmostEqual(30,ol.dpsi)
            assertElementsAlmostEqual(40,ol.gl)
            assertElementsAlmostEqual(50,ol.gs)
            
            ol.angular_units = 'rad';
            assertEqual('rad',ol.angular_units)
            
            
            assertElementsAlmostEqual(10*toRad,ol.psi)
            assertElementsAlmostEqual(20*toRad,ol.omega)
            assertElementsAlmostEqual(30*toRad,ol.dpsi)
            assertElementsAlmostEqual(40*toRad,ol.gl)
            assertElementsAlmostEqual(50*toRad,ol.gs)
            
            ol.angular_units = 'degree';
            assertEqual('deg',ol.angular_units)
            
            assertElementsAlmostEqual(10,ol.psi)
            assertElementsAlmostEqual(20,ol.omega)
            assertElementsAlmostEqual(30,ol.dpsi)
            assertElementsAlmostEqual(40,ol.gl)
            assertElementsAlmostEqual(50,ol.gs)
            
        end
        %
        function test_3Dvectors(this)
            
            ol = oriented_lattice();
            assertVectorsAlmostEqual([1,0,0],ol.u);
            assertVectorsAlmostEqual([0,1,0],ol.v);
            
            ol.v = [1,0,0];
            assertTrue(is_string(ol.v));
            assertTrue(is_string(ol.u));
            
            ol.u = 1;
            assertEqual([1,1,1],ol.u)
            assertEqual([1,0,0],ol.v)
            
            ol.alatt =10;
            assertEqual([10,10,10],ol.alatt);
            
            ol.alatt = [3,5,6]';
            assertEqual([3,5,6],ol.alatt);
            
            %rd.u='a';
            ws=warning('off','MATLAB:subsasgnMustHaveOutput');
            f=@()subsasgn(ol,struct('type','.','subs','u'),'a');
            assertExceptionThrown(f,'ORIENTED_LATTICE:invalid_argument');
            %rd.v=[]; -- does not accept empty vectors
            f=@()subsasgn(ol,struct('type','.','subs','v'),[]);
            assertExceptionThrown(f,'ORIENTED_LATTICE:invalid_argument');
            
            %rd.alatt=[10^-10,0,0]; -- does not accept empty vectors
            f=@()subsasgn(ol,struct('type','.','subs','alatt'),[1.e-10,0,0]);
            assertExceptionThrown(f,'ORIENTED_LATTICE:invalid_argument');
            
            warning(ws);
            
        end
        %
        function this = test_1vectors_errors(this)
            ol=oriented_lattice();
            
            %ol.gl='a';
            ws=warning('off','MATLAB:subsasgnMustHaveOutput');
            f=@()subsasgn(ol,struct('type','.','subs','gl'),'a');
            %            assertEqual(mess,' field: gl has to be numeric but it is not');
            assertExceptionThrown(f,'ORIENTED_LATTICE:invalid_argument');
            
            
            %ol.gl=[1,2];
            f=@()subsasgn(ol,struct('type','.','subs','gl'),[1,2]);
            %            assertEqual(mess,' field: gl has to have 1 element but has: 2
            %            element(s)');
            assertExceptionThrown(f,'ORIENTED_LATTICE:invalid_argument');
            
            f=@()subsasgn(ol,struct('type','.','subs','gl'),400);
            %            assertEqual(mess,' field: gl has to in range of +-360 deg but it is not');
            assertExceptionThrown(f,'ORIENTED_LATTICE:invalid_argument');
            
            %ol.angdeg = [-400,0,0]
            f=@()subsasgn(ol,struct('type','.','subs','angdeg'),[-400,0,0]);
            assertExceptionThrown(f,'ORIENTED_LATTICE:invalid_argument');
            
            %assertEqual(mess,'field ''angldeg'' does not define correct 3D lattice');
            %ol.angldeg = [45,120,45]
            f=@()subsasgn(ol,struct('type','.','subs','angdeg'),[45,120,50]);
            assertExceptionThrown(f,'ORIENTED_LATTICE:invalid_argument');
            
            warning(ws);
            
        end
        function test_full_constructor(this)
            ol = oriented_lattice([2;3;4]);
            assertEqual(ol.alatt,[2,3,4])
            
            undef = ol.get_undef_fields();
            assertEqual(numel(undef),2);
            assertEqual(undef{1},'angdeg');
            assertEqual(undef{2},'psi');
            
            ol = oriented_lattice([2;3;4],[30,40,50],10,[1,1,0],[0;0;1],1,2,3,4);
            assertEqual(ol.alatt,[2,3,4])
            assertEqual(ol.angdeg,[30,40,50])
            assertEqual(ol.psi,10)
            assertEqual(ol.u,[1,1,0])
            assertEqual(ol.v,[0,0,1])
            undef = ol.get_undef_fields();
            assertTrue(isempty(undef));
            
            
            ol = oriented_lattice([2;3;4],'psi',20,'gl',3,'alatt',[1,2,3],'angular_units','rad');
            
            assertTrue(ol.is_defined('psi'));
            assertTrue(ol.is_defined('alatt'));
            assertFalse(ol.is_defined('angdeg'));
            
            assertEqual(ol.alatt,[1,2,3])
            assertEqual(ol.angular_units,'rad')
            assertEqual(ol.psi,20*pi/180)
        end
        function test_matrixes(this)
            %
            ol = oriented_lattice();
            bm  = ol.bmatrix();
            assertElementsAlmostEqual(bm,eye(3)*2*pi,'absolute',1.e-9);
            [ub,umat] = ol.ubmatrix();
            assertElementsAlmostEqual(ub,eye(3)*2*pi,'absolute',1.e-9);
            assertElementsAlmostEqual(umat,eye(3),'absolute',1.e-9);
            [spec_to_u, u_to_rlu, spec_to_rlu] = ol.calc_proj_matrix();
            assertElementsAlmostEqual(spec_to_u,eye(3),'absolute',1.e-9);
            assertElementsAlmostEqual(u_to_rlu,eye(3)*(2*pi)^-1,'absolute',1.e-9);
            assertElementsAlmostEqual(spec_to_rlu,eye(3)*(2*pi)^-1,'absolute',1.e-9);
            
            %-------------------------------------------------------------
            ol = oriented_lattice([2,3,4],[30;40;50],10,[1,1,0],[0;0;1],1,2,3,4);
            bm  = ol.bmatrix();
            ref_bm =   [ 4.8975    0.2694   -2.0508; ...
                0    4.1888   -2.7207; ...
                0         0    1.5708];
            
            assertElementsAlmostEqual(bm,ref_bm,'absolute',1.e-4);
            ref_ub = [  3.8044    2.8471   -3.3064;...
                1.4299   -1.4299    1.7728;...
                2.7327   -2.7327    0.0000];
            ubm = ol.ubmatrix();
            assertElementsAlmostEqual(ubm,ref_ub,'absolute',1.e-4);
            
            %-------------------------------------------------------------
            ref_spec_to_u = [ 0.7364    0.4150    0.5343; ...
                0.6427   -0.1823   -0.7441;...
                -0.2115    0.8914   -0.4010];
            ref_u_to_rlu =[  0.2042   -0.0131    0.2438;...
                0    0.2387    0.4135; ...
                0         0    0.6366];
            ref_spec_to_rlu =[0.0904    0.3045    0.0211;...
                0.0660    0.3251   -0.3434; ...
                -0.1346    0.5675   -0.2553];
            [spec_to_u, u_to_rlu, spec_to_rlu] = ol.calc_proj_matrix();            
            assertElementsAlmostEqual(spec_to_u,ref_spec_to_u,'absolute',1.e-4);
            assertElementsAlmostEqual(u_to_rlu,ref_u_to_rlu,'absolute',1.e-4);
            assertElementsAlmostEqual(spec_to_rlu,ref_spec_to_rlu,'absolute',1.e-4);
            %-------------------------------------------------------------            
        end
        
        
    end
end
