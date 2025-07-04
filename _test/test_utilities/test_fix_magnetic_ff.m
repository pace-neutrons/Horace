classdef test_fix_magnetic_ff< TestCase

    properties
        tests_folder = fileparts(fileparts(mfilename('fullpath')));
        sample_sqw;
        sample_sqw_const;
    end
    methods
        %
        function this=test_fix_magnetic_ff(varargin)
            if nargin>0
                name = varargin{1};
            else
                name = 'test_correct_magnetif_ff';
            end
            this = this@TestCase(name);

            en = -1:1:50;
            par_file = fullfile(this.tests_folder,'common_data','gen_sqw_96dets.nxspe');
            fsqw = dummy_sqw (en, par_file, '', 51, 1,[2.8,3.86,4.86], [120,80,90],...
                [1,0,0],[0,1,0], 10, 1.,0.1, -0.1, 0.1, [50,50,50,50]);
            this.sample_sqw_const = copy(fsqw{1});
        end
        %
        function obj = setUp(obj)
            obj.sample_sqw = copy(obj.sample_sqw_const);
        end
        function  test_get_formFactor_fh_withIon(~)
            mff = MagneticIons('Fe0');
            [J0,J2,J4,J6] = mff.getInterpolant('Fe3');
            [fh,mff] = mff.get_fomFactor_fh('Fe3');
            fh_strr = cellfun(@(x)func2str(x),fh,'UniformOutput',false);
            Js_strr = {func2str(J0),func2str(J2),func2str(J4),func2str(J6)};
            assertEqual(fh_strr ,Js_strr );
            source =rand(1,200);

            res1 = J0(source).^2+J2(source).^2+J4(source).^2+J6(source).^2;
            res2  = fh{1}(source).^2+fh{2}(source).^2+fh{3}(source).^2+fh{4}(source).^2;
            assertEqual(res1,res2);

            assertEqual(mff.currentIon,'Fe3');
        end
        
        function  test_get_formFactor_fh(~)
            mff = MagneticIons('Fe1');
            [J0,J2,J4,J6] = mff.getInterpolant('Fe1');
            fh = mff.get_fomFactor_fh();
            fh_strr = cellfun(@(x)func2str(x),fh,'UniformOutput',false);
            Js_strr = {func2str(J0),func2str(J2),func2str(J4),func2str(J6)};
            assertEqual(fh_strr ,Js_strr );
            source =rand(1,200);
            %tic
            res1 = J0(source).^2+J2(source).^2+J4(source).^2+J6(source).^2;
            %toc
            %tic
            res2  = fh{1}(source).^2+fh{2}(source).^2+fh{3}(source).^2+fh{4}(source).^2;
            %toc
            % tic
            % res3= fh{1}(source).^2;
            % for i=2:4
            %     res3 = res3+fh{i}(source).^2;
            % end
            % toc
            assertEqual(res1,res2);
        end

        % tests themself
        function test_MagFF_with_sphere(obj)
            sph_cut = cut(obj.sample_sqw,sphere_proj,[],[0,180],[-180,180],[]);
            valid = sph_cut.data.s(:)~=0;
            assertEqual(min(sph_cut.data.s(valid)),10)
            assertEqual(max(sph_cut.data.s(valid)),10)

            mff = MagneticIons('Fe1');
            ff = mff.correct_mag_ff(sph_cut);
            assertEqualToTol(min(ff.data.s(valid)),11.1731,'tol',[0.001,0.001])
            assertEqualToTol(max(ff.data.s(valid)),68.7170,'tol',[0.001,0.001])
        end

        function test_magnetic_Ions(~)
            mi = MagneticIons();
            [J0,J2,J4,J6] = mi.getInterpolant('Fe0');

            %ion	A        a       B      b       C       c        D           e
            %Fe0 	0.0706 	35.008 	0.3589 	15.358 	0.5819 	5.561 	-0.0114 	0.1398
            A=0.0706; a=35.008; B=0.3589; b=15.358; C=0.5819;c=5.561; D=-0.0114;
            J0_ff = @(x2)((A*exp(-a*x2)+B*exp(-b*x2)+C*exp(-c*x2)+D));
            %J2
            %        A 	     a     	    B 	     b      	C   	c 	      D         e
            %Fe0 	1.9405 	18.473 	    1.9566     6.323 	0.5166 	 2.161  	0.0036  0.0394
            A2=1.9405;   a2 = 18.4733; B2 = 1.9566;b2 = 6.323;C2 = 0.5166;c2 = 2.1607; D2 = 0.0036;
            J2_ff = @(x2)(((A2*exp(-a2*x2)+B2*exp(-b2*x2)+C2*exp(-c2*x2)+D2).*x2));

            x = [0.1,1,10,100];
            x2 = x.*x;

            J0_rez = J0(x2);
            J2_rez = J2(x2);

            J6_rez = J6(x2);

            J0_sample = J0_ff(x2);
            J2_sample = J2_ff(x2);

            assertElementsAlmostEqual(J0_rez,J0_sample);
            assertElementsAlmostEqual(J2_rez,J2_sample);
            zer = zeros(1,4);
            assertElementsAlmostEqual(J6_rez,zer);
        end
        %
        function test_correct_magnetif_ff(this)
            fsqw = this.sample_sqw;
            %
            mff = MagneticIons('Fe1');
            fsqw_with_mag = mff.apply_mag_ff(fsqw);
            inv_sqw = mff.correct_mag_ff(fsqw_with_mag);

            assertElementsAlmostEqual(fsqw.data.s,inv_sqw.data.s);
            assertElementsAlmostEqual(fsqw.pix.data,inv_sqw.pix.data);

            fsqw_s   = fsqw.to_struct();
            inv_sqw_s= inv_sqw.to_struct();
            fsqw_s.data.s = [];
            inv_sqw_s.data.s=[];
            fsqw_s.pix = PixelDataBase.create();
            inv_sqw_s.pix = PixelDataBase.create();

            tol = 1e-6; % added to get signal comparison to pass
            % now fails with different dirty page flag
            tol = [tol, tol];
            assertEqual(fsqw_s,inv_sqw_s,"",tol);


            fdnd = dnd(fsqw);
            fdnd_with_mag = mff.apply_mag_ff(fdnd);
            inv_dnd = mff.correct_mag_ff(fdnd_with_mag);

            assertElementsAlmostEqual(fdnd.s,inv_dnd.s);
            assertElementsAlmostEqual(fdnd.e,inv_dnd.e);

            assertEqualToTol(fdnd,inv_dnd,'tol',1.e-12,'-ignore_date')

        end
        function test_dnd_vs_sqw(this)
            fsqw = this.sample_sqw;
            %
            mff = MagneticIons('Ni0');
            fsqw_with_mag = mff.apply_mag_ff(fsqw);

            fdnd = dnd(fsqw);
            fdnd_with_mag = mff.apply_mag_ff(fdnd);

            fdnd_cut = dnd(fsqw_with_mag);

            cut1= cut_dnd(fdnd_with_mag,[],[],[-0.1,0.1],[-10,10]);
            cut2= cut_dnd(fdnd_cut,[],[],[-0.1,0.1],[-10,10]);
            assertEqualToTol(cut1,cut2,'tol',[0.01,0.01])

        end
    end
end
