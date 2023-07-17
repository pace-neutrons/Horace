classdef test_proj_alignment<TestCase
    % testing ortho_proj class constructor
    %
    properties
        tests_folder
    end

    methods
        function this=test_proj_alignment(varargin)
            if nargin == 0
                name = 'test_proj_alignment';
            else
                name = varargin{1};
            end
            this=this@TestCase(name);
        end

        function test_get_projection_from_legacy_sqw_data(~)

            data = struct();
            data.alatt = [2,3,4];
            data.angdeg = [90,90,90];
            %
            data.u_to_rlu = eye(4).*[1/pi;1.5/pi;2/pi;1]; %(4x4)
            data.uoffset = zeros(1,4);      %(4x1)
            data.ulabel = {'a','b','c','d'};
            data.ulen = ones(4,1);
            data.iax=[];
            data.pax=[1,2,3,4];
            data.iint=[];
            data.p={1:10;1:20;1:30;1:40};
            ax = ortho_axes.get_from_old_data(data);
            proj0 = ortho_proj.get_from_old_data(data);


            projr = ortho_proj('alatt',data.alatt,'angdeg',data.angdeg,...
                'label',{'a','b','c','d'},'type','aaa');

            pix_cc = [eye(3),ones(3,1)];
            % this is what is what is only important for any transformation
            tpixo = proj0.transform_pix_to_img(pix_cc);
            tpixr = projr.transform_pix_to_img(pix_cc);
            assertElementsAlmostEqual(tpixo,tpixr);
        end
    end
end
