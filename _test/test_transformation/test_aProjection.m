classdef test_aProjection<TestCase
    % The test class to verify how projection works
    %
    properties
        tests_folder
        par_file
        %en, par_file, sqw_file, efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs
        fake_sqw_par = {[],'','',35.5,1,[4.4,5.5,6.6],[100,105,110],...
            [1.02,0.99,0.02],[0.025,-0.01,1.04],...
            90,10.5,0.2,3-1/6,2.4+1/7};
        
    end
    
    methods
        function this=test_aProjection(varargin)
            if nargin == 0
                name = 'test_aProjection';
            else
                name = varargin{1};
            end
            this=this@TestCase(name);
            this.tests_folder = fileparts(fileparts(mfilename('fullpath')));
            this.par_file=fullfile( this.tests_folder,'test_sqw','gen_sqw_96dets.nxspe');
            
            efix = this.fake_sqw_par{4};
            en = 0.05*efix:0.2+1/50:0.95*efix;
            this.fake_sqw_par{1} = en;
            this.fake_sqw_par{2} = this.par_file;
            
        end
        function test_constructor(this)
            %
            proj = aProjectionTester();
            lab = proj.labels;
            assertTrue(all(ismember({'Q_\zeta','Q_\xi','Q_\eta','E'},lab)));
            
            proj = aProjectionTester(1,[-1,1;-2,2;-3,3;-10,10],{'q1','q2','q3','E'});
            lab = proj.labels;
            assertTrue(all(ismember({'q1','q2','q3','E'},lab)));
            assertElementsAlmostEqual(proj.urange,proj.iax_range);
            assertElementsAlmostEqual(proj.iax,[1,2,3,4]);
            assertElementsAlmostEqual(proj.urange,[-1,1;-2,2;-3,3;-10,10]');
            assertElementsAlmostEqual(proj.data_binning,[1,1,1,1]);
            
            proj = aProjectionTester([1,2,2,1],[-1,1;-2,2;-3,3;-10,10]);
            lab = proj.labels;
            assertTrue(all(ismember({'Q_\zeta','Q_\xi','Q_\eta','E'},lab)));
            assertElementsAlmostEqual(proj.iax_range,[-1,1;-10,10]');
            assertElementsAlmostEqual(proj.iax,[1,4]);
            assertElementsAlmostEqual(proj.urange,[-1,1;-2,2;-3,3;-10,10]');
            assertElementsAlmostEqual(proj.data_binning,[1,2,2,1]);
            assertElementsAlmostEqual(proj.p{1},proj.iax_range(:,1));
            assertElementsAlmostEqual(proj.p{4},proj.iax_range(:,2));
            
            
            proj = aProjectionTester([10,10,10,10]',[-1,1;-2,2;-3,3;-10,10]);
            lab = proj.labels;
            assertTrue(all(ismember({'Q_\zeta','Q_\xi','Q_\eta','E'},lab)));
            assertTrue(isempty(proj.iax_range));
            assertTrue(isempty(proj.iax));
            assertElementsAlmostEqual(proj.urange,[-1,1;-2,2;-3,3;-10,10]');
            assertElementsAlmostEqual(proj.data_binning,[10,10,10,10]);
            
            p2_range = [proj.p{2}(1);proj.p{2}(end)];
            assertElementsAlmostEqual(proj.urange(:,2),p2_range);
        end
        function test_generation(this)
            hc = hor_config();
            cur_mex = hc.use_mex;
            hc.use_mex = false;
            clob = onCleanup(set(hor_config,'use_mex',cur_mex));
            [w, grid_size, urange]=fake_sqw (this.fake_sqw_par{:});
            w = w{1};
            ref_range = [ -1.812616558535415  -0.930959024069884  -3.293203404727652   1.884968320000000;...
                -0.142959060694314  -0.018983129127738  -0.166445736852040  33.565031679999997];
            
            assertElementsAlmostEqual(urange,ref_range,'absolute',1.e-14);
            assertEqual(grid_size,2);
            
            assertElementsAlmostEqual(size(w.data.pix),[9,13920]);
            ref_pix1=[-1.057368665663188  -0.486072931091035  -0.287851245332019   1.885000000000000;...
                -1.053922923456541  -0.484315249520338  -0.300473560166881   2.105000000000000;...
                -1.050465812481682  -0.482551768713027  -0.313137520651086   2.325000000000000;...
                -1.046997219461286  -0.480782430886060  -0.325843541737918   2.545000000000000;...
                -1.043517029224299  -0.479007177290398  -0.338592045317708   2.765000000000000;...
                -1.040025124661312  -0.477225948188246  -0.351383460381284   2.985000000000000;...
                -1.036521386678588  -0.475438682829594  -0.364218223188408   3.205000000000000;...
                -1.095094813886248  -0.503612930630137  -0.300839155677155   1.885000000000000;...
                -1.091525415914737  -0.501797757845497  -0.313418899773595   2.105000000000000;...
                -1.087944241189261  -0.499976596139628  -0.326040149062885   2.325000000000000];
            assertElementsAlmostEqual(w.data.pix(1:4,1:10),ref_pix1');
            
            ref_pix2 = [ -0.909109215604996  -0.336655076899044  -1.706848836993316  21.244999999999997;...
                -0.902114021672666  -0.333658435228646  -1.725688135594244  21.464999999999996;...
                -0.975269767446998  -0.344083542362057  -1.625718694851832  20.144999999999996;...
                -0.968301839264932  -0.341248943373542  -1.643786793676909  20.364999999999995;...
                -0.961283081999372  -0.338393666779734  -1.661986694219763  20.584999999999997;...
                -0.954212366798768  -0.335517253356401  -1.680321323634759  20.805000000000000;...
                -0.947088522398412  -0.332619226625362  -1.698793719055163  21.024999999999999;...
                -0.939910332855373  -0.329699091933039  -1.717407033466548  21.244999999999997;...
                -0.973065240276864  -0.361662591402449  -1.691932419696777  20.805000000000000;...
                -0.965799739765635  -0.358568114676169  -1.710317572039195  21.024999999999999;...
                -0.958478813470272  -0.355450031345117  -1.728842977827805  21.244999999999997];
            assertElementsAlmostEqual(w.data.pix(1:4,13910:13920),ref_pix2');
            
            ref_pix3 = [-1.250295240109043  -0.569186450629647  -1.003244803659441  11.125000000000000;...
                -1.244667714529097  -0.566385033227920  -1.017427049665763  11.345000000000001;...
                -1.239014502747314  -0.563570829074397  -1.031674028924428  11.565000000000001;...
                -1.233335249794267  -0.560743661463082  -1.045986636013994  11.785000000000000;...
                -1.227629592448607  -0.557903349580114  -1.060365786309160  12.004999999999999;...
                -1.221897158965975  -0.555049708368831  -1.074812416663943  12.225000000000001;...
                -1.216137568796357  -0.552182548389055  -1.089327486123993  12.445000000000000;...
                -1.210350432289268  -0.549301675670341  -1.103911976669569  12.664999999999999;...
                -1.204535350386130  -0.546406891558836  -1.118566893990800  12.885000000000002;...
                -1.198691914299141  -0.543497992557416  -1.133293268296984  13.105000000000000;...
                -1.192819705175920  -0.540574770158748  -1.148092155161730  13.324999999999999];
            assertElementsAlmostEqual(w.data.pix(1:4,510:520),ref_pix3');
            
            s_ref = 90*ones(1,16);
            s_ref(1:4) = 0;
            assertElementsAlmostEqual(reshape(w.data.s,1,16),s_ref);
            
            npix_ref = [ 0, 0, 0, 0,3032,180,797,2999,119,55,202,4792,185,38,...
                182,1339];
            assertElementsAlmostEqual(sum(reshape(w.data.npix,1,16)),sum(npix_ref));
            
        end
        
    end
end
