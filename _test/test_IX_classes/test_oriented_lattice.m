classdef test_oriented_lattice< TestCase
    %
    % $Revision: 349 $ ($Date: 2014-03-06 08:47:12 +0000 (Thu, 06 Mar 2014) $)
    %
    
    properties
        test_data_path;
    end
    methods
        %
        function this=test_oriented_lattice(name)
            this = this@TestCase(name);
            rootpath=fileparts(which('herbert_init.m'));
            this.test_data_path = fullfile(rootpath,'_test/common_data');
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
            assertExceptionThrown(f,'ORIENTED_LATTICE:set_lattice_param');
            
            warning(ws);
  
        end
       function this = test_1vectors_errors(this)
            ol=oriented_lattice();
            
             %ol.gl='a';
            ws=warning('off','MATLAB:subsasgnMustHaveOutput');
            f=@()subsasgn(ol,struct('type','.','subs','gl'),'a');
            %            assertEqual(mess,' field: gl has to be numeric but it is not');
            assertExceptionThrown(f,'ORIENTED_LATTICE:set_angular_value');
            
            
            %ol.gl=[1,2];
            f=@()subsasgn(ol,struct('type','.','subs','gl'),[1,2]);
            %            assertEqual(mess,' field: gl has to have 1 element but has: 2
            %            element(s)');
            assertExceptionThrown(f,'ORIENTED_LATTICE:set_angular_value');
            
            f=@()subsasgn(ol,struct('type','.','subs','gl'),400);
            %            assertEqual(mess,' field: gl has to in range of +-360 deg but it is not');
            assertExceptionThrown(f,'ORIENTED_LATTICE:set_angular_value');
            
            %ol.angdeg = [-400,0,0]
            f=@()subsasgn(ol,struct('type','.','subs','angdeg'),[-400,0,0]);
            assertExceptionThrown(f,'ORIENTED_LATTICE:set_lattice_angles');
            
            %assertEqual(mess,'field ''angldeg'' does not define correct 3D lattice');
            %ol.angldeg = [45,120,45]
            f=@()subsasgn(ol,struct('type','.','subs','angdeg'),[45,120,50]);
            assertExceptionThrown(f,'ORIENTED_LATTICE:set_lattice_angles');
            
            warning(ws);
                        
        end
        


        
        
    end
end