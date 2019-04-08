classdef test_fix_magnetic_ff< TestCase
    %
    % $Revision:: 1720 ($Date:: 2019-04-08 16:49:36 +0100 (Mon, 8 Apr 2019) $)
    %
    
    properties
        tests_folder
        sample_sqw;
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
            this.tests_folder = fileparts(fileparts(mfilename('fullpath')));
            
            persistent sample_sqw_;
            if isempty(sample_sqw_)
                en = -1:1:50;
                par_file = fullfile(this.tests_folder,'test_sqw','gen_sqw_96dets.nxspe');
                
                fsqw = fake_sqw (en, par_file, '', 51, 1,[2.8,3.86,4.86], [120,80,90],...
                    [1,0,0],[0,1,0], 10, 1.,0.1, -0.1, 0.1, [50,50,50,50]);
                sample_sqw_ = fsqw{1};
                
            end
            this.sample_sqw = sample_sqw_;
        end
        % tests themself
        function test_magnetic_Ions(this)
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
            assertElementsAlmostEqual(fsqw.data.pix,inv_sqw.data.pix);
            
            fsqw_s   = struct(fsqw);
            inv_sqw_s= struct(inv_sqw);
            fsqw_s.data.s = [];
            inv_sqw_s.data.s=[];
            fsqw_s.data.pix = [];
            inv_sqw_s.data.pix=[];
            
            assertEqual(fsqw_s,inv_sqw_s);
            
            
            fdnd = dnd(fsqw);
            fdnd_with_mag = mff.apply_mag_ff(fdnd);
            inv_dnd = mff.correct_mag_ff(fdnd_with_mag);
            
            assertElementsAlmostEqual(fdnd.s,inv_dnd.s);
            assertElementsAlmostEqual(fdnd.e,inv_dnd.e);
            
            fdnd_s   = struct(fdnd);
            inv_dnd_s= struct(inv_dnd);
            fdnd_s.s = [];
            inv_dnd_s.s=[];
            fdnd_s.e = [];
            inv_dnd_s.e=[];
            assertEqual(fdnd_s,inv_dnd_s);
            
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
            assertElementsAlmostEqual(cut1.s,cut2.s,'absolute',0.06);
            assertElementsAlmostEqual(cut1.e,cut2.e,'absolute',0.01);            

            fdnd_cut_s = struct(fdnd_cut);
            fdnd_mag_s = struct(fdnd_with_mag);            
            fdnd_cut_s.s = [];
            fdnd_mag_s.s=[];
            fdnd_cut_s.e = [];
            fdnd_mag_s.e=[];            
            fdnd_cut_s.npix = [];
            fdnd_mag_s.npix=[];
            
            assertEqual(fdnd_cut_s,fdnd_mag_s);            
            
            
        end
        
        
    end
end

