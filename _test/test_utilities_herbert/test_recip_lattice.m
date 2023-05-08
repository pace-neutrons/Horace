classdef test_recip_lattice < TestCase
    properties
    end
    methods
        function obj = test_recip_lattice(varargin)
            if nargin<1
                name = 'test_recip_lattice';
            else
                name = varargin{1};
            end
            obj = obj@TestCase(name);
        end
        function test_tricl_all(~)
            alatt = [1,2,3];
            angdeg = [80,70,110];

            [b_vectors,normbec,angvec,dir_vec_directions] = direct2recip(alatt,angdeg);

            [abc_adjucent_vect,alatt_r,angdeg_r,res_vec_directions] = direct2recip(normbec,angvec);

            assertElementsAlmostEqual(alatt_r,alatt)
            assertElementsAlmostEqual(angdeg_r,angdeg )            

            [bmat,brlu,angrlu] = bmatrix(alatt,angdeg);


            assertElementsAlmostEqual(brlu,normbec)            
            assertElementsAlmostEqual(angrlu,angvec)            

            assertElementsAlmostEqual(bmat./brlu,res_vec_directions)            
        end

        

        function test_tricl_sharp(~)
            alatt = [1,2,3];
            angdeg = [80,70,90];

            [b_vectors,normbec,angvec,dir_vec] = direct2recip(alatt,angdeg);

            [direct_lattice_ort,alatt_r,angdeg_r,res_vec] = direct2recip(normbec,angvec);

            assertElementsAlmostEqual(alatt_r,alatt)
            assertElementsAlmostEqual(angdeg_r,angdeg )            

            [bmat,brlu,angrlu] = bmatrix(alatt,angdeg);


            assertElementsAlmostEqual(brlu,normbec)            
            assertElementsAlmostEqual(angrlu,angvec)            

            assertElementsAlmostEqual(bmat./brlu,res_vec)            
        end


        function test_ortho_recip(~)
            bb = direct2recip([1,2,3],[90,90,90]);

            assertElementsAlmostEqual(bb(:,1),[2*pi;0;0]);
            assertElementsAlmostEqual(bb(:,2),[0;2*pi/2;0]);
            assertElementsAlmostEqual(bb(:,3),[0;0;2*pi/3]);
        end

    end
end