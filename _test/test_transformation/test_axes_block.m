classdef test_axes_block < TestCase
    % Tests for main operations of the axes_block

    properties
        out_dir=tmp_dir();
    end

    methods
        function obj=test_axes_block(varargin)
            if nargin<1
                name = 'test_axes_block';
            else
                name = varargin{1};
            end
            obj = obj@TestCase(name);

        end
        %------------------------------------------------------------------
        function test_correct_binning_and_indx_2D(~)
            dbr = [0,0.1,0,0.5;1,1.9,3,9.5];
            bin0 = {[dbr(1,1),dbr(2,1)];[dbr(1,2),0.2,dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab = axes_block(bin0{:});

            nd = ab.n_dims;
            szs = ab.dims_as_ssize();
            assertEqual(nd,2)

            xi = dbr(1,1)+0.05:0.1:dbr(2,1);
            yi = dbr(1,2):0.2:dbr(2,2); % 10 points
            zi = dbr(1,3)+0.15:0.3:dbr(2,3);
            ei = dbr(1,4):1:dbr(2,4); % 10 points
            [X,Y,Z,E] = ndgrid(xi,yi,zi,ei);

            % draw cross in [yi,ei] plane
            pix_data = [reshape(X,1,numel(X));reshape(Y,1,numel(Y));...
                reshape(Z,1,numel(Z));reshape(E,1,numel(E))];
            pix_dat_full = [pix_data;zeros(5,numel(X))];
            line1 = pix_dat_full(2,:)>1 & pix_dat_full(2,:)<=1.1;
            npoints = sum(line1); % 10xi*10yi*10zi = 1000;
            pix_dat_full(8,line1)=1;
            pix_dat_full(9,line1)=1;
            line2 = pix_dat_full(4,:)>5 & pix_dat_full(4,:)<6;
            npoints = npoints + sum(line2);

            pix_dat_full(8,line2)=pix_dat_full(8,line2)+1;
            pix_dat_full(9,line2)=1;

            pix = PixelData(pix_dat_full);

            assertExceptionThrown(@()bin_pixels(ab,pix_data,[],[]),'HORACE:axes_block:invalid_argument');
            assertExceptionThrown(@()bin_pixels(ab,pix_data,[],[],[]),'HORACE:axes_block:invalid_argument');

            [npix,s,e,pix_ok,unique_runid,indx] = ab.bin_pixels(pix_data,[],[],[],pix);

            assertEqual(numel(unique_runid),1);
            assertEqual(s(6,1),100);
            assertEqual(s(1,6),100);
            assertEqual(s(6,6),200);
            assertTrue(all(e(6,:)==100));
            assertTrue(all(e(:,6)==100));
            assertEqual(sum(sum(s)),npoints)
            % no pixels were lost at binning
            assertEqual(sum(sum(npix)),size(pix_data,2));
            % homogeneous distribution
            assertTrue(any(any(npix==100)));
            assertEqual(pix_ok.num_pixels,pix.num_pixels);
            assertEqual(numel(indx),pix_ok.num_pixels);
            for i=1:10
                ii = (i-1)*10+1:1000:10000;
                assertEqual(indx(ii)',i:10:100);
            end
            assertEqual(size(npix),szs);
            assertEqual(size(s),szs);
            assertEqual(size(e),szs);

        end
        function test_correct_binning_and_indx_2D_accumulated(~)
            dbr = [0,0.1,0,0.5;1,1.9,3,9.5];
            bin0 = {[dbr(1,1),dbr(2,1)];[dbr(1,2),0.2,dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab = axes_block(bin0{:});

            nd = ab.n_dims;
            assertEqual(nd,2)

            xi = dbr(1,1)+0.05:0.1:dbr(2,1);
            yi = dbr(1,2):0.2:dbr(2,2); % 10 points
            zi = dbr(1,3)+0.15:0.3:dbr(2,3);
            ei = dbr(1,4):1:dbr(2,4); % 10 points
            [X,Y,Z,E] = ndgrid(xi,yi,zi,ei);

            % draw cross in [yi,ei] plain
            pix_data = [reshape(X,1,numel(X));reshape(Y,1,numel(Y));...
                reshape(Z,1,numel(Z));reshape(E,1,numel(E))];
            pix_dat_full = [pix_data;ones(5,numel(X))];
            pix = PixelData(pix_dat_full);

            [npix1] = ab.bin_pixels(pix_data);
            [npix2] = ab.bin_pixels(pix_data,npix1);
            assertEqual(2*npix1,npix2)


            [npix3,s1,e1,pix_ok1,unique_runid1] = ab.bin_pixels(pix_data,npix1,[],[],pix);
            assertEqual(npix3,npix2)
            assertEqual(npix1,s1)
            assertEqual(npix1,e1)

            assertEqual(numel(unique_runid1),1);
            [~,~,~,pix_ok,unique_runid2] = ab.bin_pixels(pix_data,npix1,s1,e1,pix,unique_runid1);
            assertEqual(unique_runid1,unique_runid2);
            assertEqual(pix_ok,pix_ok1);
            assertEqual(unique_runid2,1);

            %


        end
        %
        function test_bin_all_pix_indx_0D(~)
            dbr = [-1,-2,-3,0;1,2,3,10];
            bin0 = {[dbr(1,1),dbr(2,1)];[dbr(1,2),dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),dbr(2,4)]};
            ab = axes_block(bin0{:});

            nd = ab.n_dims;
            szs = ab.dims_as_ssize();
            assertEqual(nd,0)

            xi = dbr(1,1):0.1:dbr(2,1);
            yi = dbr(1,2):0.2:dbr(2,2);
            zi = dbr(1,3):0.3:dbr(2,3);
            ei = dbr(1,4):1:dbr(2,4);
            [X,Y,Z,E] = ndgrid(xi,yi,zi,ei);
            pix_data = [reshape(X,1,numel(X));reshape(Y,1,numel(Y));...
                reshape(Z,1,numel(Z));reshape(E,1,numel(E))];
            pix_dat_full = [pix_data;ones(5,numel(X))];
            pix = PixelData(pix_dat_full);

            [npix,s,e,pix_ok,uniq_runid,indx] = ab.bin_pixels(pix_data,[],[],[],pix);
            assertEqual(uniq_runid,1)

            assertEqual(size(npix),szs);
            assertEqual(size(s),szs);
            assertEqual(size(e),szs);
            % no pixels were lost at binning
            assertEqual(npix,size(pix_data,2));
            assertEqual(s,size(pix_data,2));
            assertEqual(e,size(pix_data,2));
            assertEqual(pix_ok.num_pixels,pix.num_pixels);
            assertEqual(pix_ok.num_pixels,numel(indx));
            assertEqual(indx,ones(pix_ok.num_pixels,1));

        end
        %
        function test_bin_all_pix_0D(~)
            dbr = [-1,-2,-3,0;1,2,3,10];
            bin0 = {[dbr(1,1),dbr(2,1)];[dbr(1,2),dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),dbr(2,4)]};
            ab = axes_block(bin0{:});

            nd  = ab.n_dims;
            szs = ab.dims_as_ssize();
            assertEqual(nd,0)

            xi = dbr(1,1):0.1:dbr(2,1);
            yi = dbr(1,2):0.2:dbr(2,2);
            zi = dbr(1,3):0.3:dbr(2,3);
            ei = dbr(1,4):1:dbr(2,4);
            [X,Y,Z,E] = ndgrid(xi,yi,zi,ei);
            pix_data = [reshape(X,1,numel(X));reshape(Y,1,numel(Y));...
                reshape(Z,1,numel(Z));reshape(E,1,numel(E))];
            pix_dat_full = [pix_data;ones(5,numel(X))];
            pix = PixelData(pix_dat_full);

            [npix,s,e,pix_ok] = ab.bin_pixels(pix_data,[],[],[],pix);

            assertEqual(size(npix),szs);
            assertEqual(size(s),szs);
            assertEqual(size(e),szs);
            % no pixels were lost at binning
            assertEqual(npix,size(pix_data,2));
            assertEqual(s,size(pix_data,2));
            assertEqual(e,size(pix_data,2));
            assertEqual(pix_ok.num_pixels,pix.num_pixels);

        end
        %
        function test_bin_all_pix_1D_nopix(~)
            dbr = [-1,-2,-3,0;1,2,3,10];
            bin0 = {[dbr(1,1),dbr(2,1)];[dbr(1,2),dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab = axes_block(bin0{:});

            nd  = ab.n_dims;
            szs = ab.dims_as_ssize();
            assertEqual(nd,1)

            xi = dbr(1,1):0.1:dbr(2,1);
            yi = dbr(1,2):0.2:dbr(2,2);
            zi = dbr(1,3):0.3:dbr(2,3);
            ei = dbr(1,4):1:dbr(2,4);
            [X,Y,Z,E] = ndgrid(xi,yi,zi,ei);
            pix_data = [reshape(X,1,numel(X));reshape(Y,1,numel(Y));...
                reshape(Z,1,numel(Z));reshape(E,1,numel(E))];

            pix_dat_full = [pix_data;ones(5,numel(X))];
            pix = PixelData(pix_dat_full);

            [npix,s,e] = ab.bin_pixels(pix_data,[],[],[],pix);

            assertEqual(size(npix),szs);
            assertEqual(size(s),szs);
            assertEqual(size(e),szs);
            % no pixels were lost at binning
            assertEqual(sum(reshape(npix,1,numel(npix))),size(pix_data,2));
            assertEqual(sum(reshape(s,1,numel(npix))),size(pix_data,2));
            assertEqual(sum(reshape(e,1,numel(npix))),size(pix_data,2));

        end
        %
        function test_bin_all_pix_1D(~)
            dbr = [-1,-2,-3,0;1,2,3,10];
            bin0 = {[dbr(1,1),dbr(2,1)];[dbr(1,2),dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab = axes_block(bin0{:});

            nd  = ab.n_dims;
            szs = ab.dims_as_ssize();
            assertEqual(nd,1)

            xi = dbr(1,1):0.1:dbr(2,1);
            yi = dbr(1,2):0.2:dbr(2,2);
            zi = dbr(1,3):0.3:dbr(2,3);
            ei = dbr(1,4):1:dbr(2,4);
            [X,Y,Z,E] = ndgrid(xi,yi,zi,ei);
            pix_data = [reshape(X,1,numel(X));reshape(Y,1,numel(Y));...
                reshape(Z,1,numel(Z));reshape(E,1,numel(E))];

            pix_dat_full = [pix_data;ones(5,numel(X))];
            pix = PixelData(pix_dat_full);

            [npix,s,e,pix_ok,uniq_runid] = ab.bin_pixels(pix_data,[],[],[],pix);

            assertEqual(size(npix),szs);
            assertEqual(size(s),szs);
            assertEqual(size(e),szs);
            % no pixels were lost at binning
            assertEqual(sum(reshape(npix,1,numel(npix))),size(pix_data,2));
            assertEqual(sum(reshape(s,1,numel(npix))),size(pix_data,2));
            assertEqual(sum(reshape(e,1,numel(npix))),size(pix_data,2));
            assertEqual(pix_ok.num_pixels,pix.num_pixels);

        end
        %
        function test_bin_all_pix_indx_2D(~)
            dbr = [-1,-2,-3,0;1,2,3,10];
            bin0 = {[dbr(1,1),dbr(2,1)];[dbr(1,2),0.2,dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab = axes_block(bin0{:});

            nd  = ab.n_dims;
            szs = ab.dims_as_ssize();
            assertEqual(nd,2)

            xi = dbr(1,1):0.1:dbr(2,1);
            yi = dbr(1,2):0.2:dbr(2,2);
            zi = dbr(1,3):0.3:dbr(2,3);
            ei = dbr(1,4):1:dbr(2,4);
            [X,Y,Z,E] = ndgrid(xi,yi,zi,ei);
            pix_data = [reshape(X,1,numel(X));reshape(Y,1,numel(Y));...
                reshape(Z,1,numel(Z));reshape(E,1,numel(E))];
            pix_dat_full = [pix_data;ones(5,numel(X))];
            pix = PixelData(pix_dat_full);

            [npix,s,e,pix_ok,uniq_runid,pix_indx] = ab.bin_pixels(pix_data,[],[],[],pix);

            assertEqual(size(npix),szs);
            assertEqual(size(s),szs);
            assertEqual(size(e),szs);
            % no pixels were lost at binning
            assertEqual(sum(reshape(npix,1,numel(npix))),size(pix_data,2));
            assertEqual(sum(reshape(s,1,numel(npix))),size(pix_data,2));
            assertEqual(sum(reshape(e,1,numel(npix))),size(pix_data,2));
            assertEqual(pix_ok.num_pixels,pix.num_pixels);
            assertEqual(pix_ok.num_pixels,numel(pix_indx));
        end
        %
        function test_bin_all_pix_2D(~)
            dbr = [-1,-2,-3,0;1,2,3,10];
            bin0 = {[dbr(1,1),dbr(2,1)];[dbr(1,2),0.2,dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab = axes_block(bin0{:});

            nd  = ab.n_dims;
            szs = ab.dims_as_ssize();
            assertEqual(nd,2)

            xi = dbr(1,1):0.1:dbr(2,1);
            yi = dbr(1,2):0.2:dbr(2,2);
            zi = dbr(1,3):0.3:dbr(2,3);
            ei = dbr(1,4):1:dbr(2,4);
            [X,Y,Z,E] = ndgrid(xi,yi,zi,ei);
            pix_data = [reshape(X,1,numel(X));reshape(Y,1,numel(Y));...
                reshape(Z,1,numel(Z));reshape(E,1,numel(E))];
            pix_dat_full = [pix_data;ones(5,numel(X))];
            pix = PixelData(pix_dat_full);

            [npix,s,e,pix_ok,uniq_runid] = ab.bin_pixels(pix_data,[],[],[],pix);

            assertEqual(size(npix),szs);
            assertEqual(size(s),szs);
            assertEqual(size(e),szs);
            % no pixels were lost at binning
            assertEqual(sum(reshape(npix,1,numel(npix))),size(pix_data,2));
            assertEqual(sum(reshape(s,1,numel(npix))),size(pix_data,2));
            assertEqual(sum(reshape(e,1,numel(npix))),size(pix_data,2));
            assertEqual(pix_ok.num_pixels,pix.num_pixels);
        end
        %
        function test_bin_all_pix_4D(~)
            dbr = [-1,-2,-3,0;1,2,3,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),0.2,dbr(2,2)];...
                [dbr(1,3),0.3,dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab = axes_block(bin0{:});

            nd  = ab.n_dims;
            szs = ab.dims_as_ssize();
            assertEqual(nd,4)

            xi = dbr(1,1):0.1:dbr(2,1);
            yi = dbr(1,2):0.2:dbr(2,2);
            zi = dbr(1,3):0.3:dbr(2,3);
            ei = dbr(1,4):1:dbr(2,4);
            [X,Y,Z,E] = ndgrid(xi,yi,zi,ei);
            pix_data = [reshape(X,1,numel(X));reshape(Y,1,numel(Y));...
                reshape(Z,1,numel(Z));reshape(E,1,numel(E))];
            pix_dat_full = [pix_data;ones(5,numel(X))];
            pix = PixelData(pix_dat_full);

            [npix,s,e,pix_ok,uniq_runid] = ab.bin_pixels(pix_data,[],[],[],pix);

            assertEqual(size(npix),szs);
            assertEqual(size(s),szs);
            assertEqual(size(e),szs);
            % no pixels were lost at binning
            assertEqual(sum(reshape(npix,1,numel(npix))),size(pix_data,2));
            assertEqual(sum(reshape(s,1,numel(npix))),size(pix_data,2));
            assertEqual(sum(reshape(e,1,numel(npix))),size(pix_data,2));
            assertEqual(pix_ok.num_pixels,pix.num_pixels);

        end
        %------------------------------------------------------------------
        function test_bin_all_coord_0D(~)
            dbr = [-1,-2,-3,0;1,2,3,10];
            bin0 = {[dbr(1,1),dbr(2,1)];[dbr(1,2),dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),dbr(2,4)]};
            ab = axes_block(bin0{:});

            nd  = ab.n_dims;
            szs = ab.dims_as_ssize();
            assertEqual(nd,0)

            xi = dbr(1,1):0.1:dbr(2,1);
            yi = dbr(1,2):0.2:dbr(2,2);
            zi = dbr(1,3):0.3:dbr(2,3);
            ei = dbr(1,4):1:dbr(2,4);
            [X,Y,Z,E] = ndgrid(xi,yi,zi,ei);
            pix_data = [reshape(X,1,numel(X));reshape(Y,1,numel(Y));...
                reshape(Z,1,numel(Z));reshape(E,1,numel(E))];

            npix = ab.bin_pixels(pix_data);

            assertEqual(size(npix),szs);
            % no pixels were lost at binning
            assertEqual(npix,size(pix_data,2));
        end
        %
        function test_bin_all_coord_1D(~)
            dbr = [-1,-2,-3,0;1,2,3,10];
            bin0 = {[dbr(1,1),dbr(2,1)];[dbr(1,2),dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab = axes_block(bin0{:});

            nd  = ab.n_dims;
            szs = ab.dims_as_ssize();
            assertEqual(nd,1)

            xi = dbr(1,1):0.1:dbr(2,1);
            yi = dbr(1,2):0.2:dbr(2,2);
            zi = dbr(1,3):0.3:dbr(2,3);
            ei = dbr(1,4):1:dbr(2,4);
            [X,Y,Z,E] = ndgrid(xi,yi,zi,ei);
            pix_data = [reshape(X,1,numel(X));reshape(Y,1,numel(Y));...
                reshape(Z,1,numel(Z));reshape(E,1,numel(E))];

            npix = ab.bin_pixels(pix_data);

            assertEqual(size(npix),szs);
            % no pixels were lost at binning
            assertEqual(sum(reshape(npix,1,numel(npix))),size(pix_data,2));

        end
        %
        function test_bin_all_coord_2D(~)
            dbr = [-1,-2,-3,0;1,2,3,10];
            bin0 = {[dbr(1,1),dbr(2,1)];[dbr(1,2),0.2,dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab = axes_block(bin0{:});

            nd  = ab.n_dims;
            szs = ab.dims_as_ssize();
            assertEqual(nd,2)

            xi = dbr(1,1):0.1:dbr(2,1);
            yi = dbr(1,2):0.2:dbr(2,2);
            zi = dbr(1,3):0.3:dbr(2,3);
            ei = dbr(1,4):1:dbr(2,4);
            [X,Y,Z,E] = ndgrid(xi,yi,zi,ei);
            pix_data = [reshape(X,1,numel(X));reshape(Y,1,numel(Y));...
                reshape(Z,1,numel(Z));reshape(E,1,numel(E))];

            npix = ab.bin_pixels(pix_data);

            assertEqual(size(npix),szs);
            % no pixels were lost at binning
            assertEqual(sum(reshape(npix,1,numel(npix))),size(pix_data,2));

        end
        %
        function test_bin_all_coord_4D(~)
            dbr = [-1,-2,-3,0;1,2,3,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),0.2,dbr(2,2)];...
                [dbr(1,3),0.3,dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab = axes_block(bin0{:});

            nd = ab.n_dims;
            szs = ab.dims_as_ssize();
            assertEqual(nd,4)

            xi = dbr(1,1):0.1:dbr(2,1);
            yi = dbr(1,2):0.2:dbr(2,2);
            zi = dbr(1,3):0.3:dbr(2,3);
            ei = dbr(1,4):1:dbr(2,4);
            [X,Y,Z,E] = ndgrid(xi,yi,zi,ei);
            pix_data = [reshape(X,1,numel(X));reshape(Y,1,numel(Y));...
                reshape(Z,1,numel(Z));reshape(E,1,numel(E))];

            npix = ab.bin_pixels(pix_data);

            assertEqual(size(npix),szs);
            % no pixels were lost at binning
            assertEqual(sum(reshape(npix,1,numel(npix))),size(pix_data,2));

        end
        %------------------------------------------------------------------
        function test_1Dbin_inputs_1par_provided(~)
            dbr = [-1,-2,-3,0;1,2,3,10];
            bin0 = {[dbr(1,1),dbr(2,1)];[dbr(1,2),dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab = axes_blockTester(bin0{:});

            pix_data = ones(4,10);
            npix = zeros(11,1);

            [npix_r,s,e,pix_candidates,argi]= ...
                ab.get_bin_inputs(pix_data,1,npix);
            assertEqual(size(npix_r),size(npix));
            assertTrue(isempty(s));
            assertTrue(isempty(e));
            assertTrue(isempty(pix_candidates));
            assertTrue(isempty(argi));
        end
        %
        function test_1Dbin_inputs_3par_provided(~)
            dbr = [-1,-2,-3,0;1,2,3,10];
            bin0 = {[dbr(1,1),dbr(2,1)];[dbr(1,2),dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab = axes_blockTester(bin0{:});

            pix_data = ones(4,10);
            pix = PixelData();
            npix = zeros(11,1);
            s =  zeros(11,1);
            e =  zeros(11,1);

            [npix_r,sr,er,pix_candidates,argi]= ...
                ab.get_bin_inputs(pix_data,3,npix,s,e,pix);
            assertEqual(size(npix),size(npix_r));
            assertEqual(size(s),size(sr));
            assertEqual(size(e),size(er));
            assertEqual(npix,npix_r)
            assertEqual(s,sr)
            assertEqual(e,er)
            assertTrue(isempty(pix_candidates));
            assertTrue(isempty(argi));
        end
        %
        function test_1Dbin_inputs_3par(~)
            dbr = [-1,-2,-3,0;1,2,3,10];
            bin0 = {[dbr(1,1),dbr(2,1)];[dbr(1,2),dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab = axes_blockTester(bin0{:});

            pix_data = ones(4,10);
            pix = PixelData();

            [npix,s,e,pix_candidates,argi]= ...
                ab.get_bin_inputs(pix_data,3,[],[],[],pix);
            assertEqual(size(npix),[11,1]);
            assertEqual(size(s),[11,1]);
            assertEqual(size(e),[11,1]);
            assertEqual(npix,zeros(11,1))
            assertEqual(s,zeros(11,1))
            assertEqual(e,zeros(11,1))
            assertTrue(isempty(pix_candidates));
            assertTrue(isempty(argi));
        end
        %
        function test_1Dbin_inputs_1par(~)
            dbr = [-1,-2,-3,0;1,2,3,10];
            bin0 = {[dbr(1,1),dbr(2,1)];[dbr(1,2),dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab = axes_blockTester(bin0{:});

            pix_data = ones(4,10);

            [npix,s,e,pix_candidates,argi]= ...
                ab.get_bin_inputs(pix_data,1);
            assertEqual(size(npix),[11,1]);
            assertTrue(isempty(s));
            assertTrue(isempty(e));
            assertTrue(isempty(pix_candidates));
            assertTrue(isempty(argi));
        end
        %--
        function test_0Dbin_inputs_1par_provided(~)
            ab = axes_blockTester(4);
            pix_data = ones(4,10);
            npix = 0;

            [npix,s,e,pix_candidates,argi]= ...
                ab.get_bin_inputs(pix_data,1,npix);
            assertEqual(size(npix),[1,1]);
            assertTrue(isempty(s));
            assertTrue(isempty(e));
            assertEqual(npix,0)
            assertTrue(isempty(pix_candidates));
            assertTrue(isempty(argi));
        end
        %
        function test_0Dbin_inputs_3par_provided(~)
            ab = axes_blockTester(4);
            pix_data = ones(4,10);
            pix = PixelData();
            npix = 0;
            s = 0;
            e = 0;

            [npix,s,e,pix_candidates,argi]= ...
                ab.get_bin_inputs(pix_data,3,npix,s,e,pix);
            assertEqual(size(npix),[1,1]);
            assertEqual(size(s),[1,1]);
            assertEqual(size(e),[1,1]);
            assertEqual(npix,0)
            assertEqual(s,0)
            assertEqual(e,0)
            assertTrue(isempty(pix_candidates));
            assertTrue(isempty(argi));
        end
        %
        function test_0Dbin_inputs_3par(~)
            ab = axes_blockTester(4);
            pix_data = ones(4,10);
            pix = PixelData();

            [npix,s,e,pix_candidates,argi]= ...
                ab.get_bin_inputs(pix_data,3,[],[],[],pix);
            assertEqual(size(npix),[1,1]);
            assertEqual(size(s),[1,1]);
            assertEqual(size(e),[1,1]);
            assertEqual(npix,0)
            assertEqual(s,0)
            assertEqual(e,0)
            assertTrue(isempty(pix_candidates));
            assertTrue(isempty(argi));
        end
        %
        function test_0Dbin_inputs_1par(~)
            ab = axes_blockTester(4);
            pix_data = ones(4,10);

            [npix,s,e,pix_candidates,argi]= ...
                ab.get_bin_inputs(pix_data,1);
            assertEqual(size(npix),[1,1]);
            assertTrue(isempty(s));
            assertTrue(isempty(e));
            assertTrue(isempty(pix_candidates));
            assertTrue(isempty(argi));
        end
        %------------------------------------------------------------------
        function test_axes_scales_2D(~)
            dbr = [-1,-2,-3,0;1,2,3,10];
            bin0 = {[dbr(1,1),dbr(2,1)];[dbr(1,2),0.2,dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab = axes_block(bin0{:});

            [cube,step]  = ab.get_axes_scales();
            assertEqual(size(cube,2),16)
            assertEqual(zeros(4,1),cube(:,1))
            assertEqual(step,cube(:,16))
            assertEqual(step,...
                [dbr(2,1)-dbr(1,1);0.2;dbr(2,3)-dbr(1,3);1]);
        end
        %------------------------------------------------------------------
        function test_get_bin_nodes_4D_2d(~)
            dbr = [-1,-2,-3,0;1,2,3,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),0.2,dbr(2,2)];...
                [dbr(1,3),0.3,dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab = axes_block(bin0{:});

            [nodes,en] = ab.get_bin_nodes('-3D');
            assertEqual(size(nodes,1),3);
            sz = ab.nbins_all_dims();
            sz = sz+1;

            assertEqual(numel(en),sz(4));

            the_size = prod(sz(1:3));
            assertEqual(size(nodes,2),the_size);
        end
        %
        function test_get_bin_nodes_2D_2d(~)
            dbr = [-1,-2,-3,0;1,2,3,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab = axes_block(bin0{:});

            [nodes,en] = ab.get_bin_nodes('-3D');
            assertEqual(size(nodes,1),3);

            nd = ab.n_dims;
            sz = ab.dims_as_ssize();
            sz = sz+1;

            assertEqual(numel(en),sz(end));

            ni = 4-nd;
            the_size = ni*2*prod(sz(1:nd-1));
            assertEqual(size(nodes,2),the_size);
        end
        %
        function test_get_bin_nodes_4D_4d(~)
            dbr = [-1,-2,-3,0;1,2,3,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),0.2,dbr(2,2)];...
                [dbr(1,3),0.3,dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab = axes_block(bin0{:});

            nodes = ab.get_bin_nodes();
            assertEqual(size(nodes,1),4);

            sz = ab.dims_as_ssize();
            sz = sz+1;

            the_size = prod(sz);
            assertEqual(size(nodes,2),the_size);
        end
        %
        function test_get_bin_nodes_2D_2d_ext_block(~)
            dbr = [-1,-2,-3,0;1,2,3,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab = axes_block(bin0{:});

            new_step = [0.05;4;6;0.1];
            r0 = [-1;-2;-3;0];
            r1 = r0+new_step;
            char_block =[r0,r1];
            nodes = ab.get_bin_nodes(char_block);
            assertEqual(size(nodes,1),4);
            node_range = [min(nodes,[],2)';max(nodes,[],2)'];
            assertEqual(ab.img_range,node_range);

            %nns = floor((ab.img_range(2,:)-ab.img_range(1,:))'./(0.5*new_step))+1;
            nns = [84,3,3,221];
            the_size = prod(nns);
            assertEqual(size(nodes,2),the_size);
        end
        %
        function test_get_bin_nodes_2D_4d_ext_block(~)
            dbr = [-1,-2,-3,0;1,2,3,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab = axes_block(bin0{:});

            new_step = [0.05;0.1;0.15;0.1];
            r0 = [-1;-2;-3;0];
            r1 = r0+new_step;
            char_block =[r0,r1];
            [nodes3D,dEgrid] = ab.get_bin_nodes(char_block,'-3D');
            assertEqual(size(nodes3D,1),3);
            node_range = [min(nodes3D,[],2)';max(nodes3D,[],2)'];
            assertEqual(ab.img_range(:,1:3),node_range);

            %nns = floor((ab.img_range(2,:)-ab.img_range(1,:))'./(0.5*new_step))+1;

            nns = [84,80,81,12];
            q_size = prod(nns(1:3));
            assertEqual(numel(dEgrid),nns(4))
            assertEqual(size(nodes3D,2),q_size);
        end
        %
        function test_get_bin_nodes_2D_4d(~)
            dbr = [-1,-2,-3,0;1,2,3,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab = axes_block(bin0{:});

            nodes = ab.get_bin_nodes();
            assertEqual(size(nodes,1),4);

            nd = ab.n_dims;
            sz = ab.dims_as_ssize();
            ni = 4-nd;
            %sz = sz+1;
            the_size = ni*2*prod(sz+1);
            assertEqual(size(nodes,2),the_size);
        end
        %------------------------------------------------------------------
        function test_axes_ranges(~)
            dbr = [-1,-2,-3,0;1,2,3,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)],[dbr(1,2),dbr(2,2)],...
                [dbr(1,3),0.3,dbr(2,3)],[dbr(1,4),dbr(2,4)]};
            ab = axes_block(bin0{:});
            range = ab.get_binning_range();
            assertEqual(bin0,range);
        end
        %------------------------------------------------------------------
        function test_default_binning_2D_cross_proj(~)
            dbr = [-1,-1.05,-3,0;1,1.05,3,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),dbr(2,2)];...
                [dbr(1,3),0.3,dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab = axes_block(bin0{:});

            proj1 = ortho_proj([1,0,0],[0,1,0]);
            proj2 = ortho_proj([1,1,0],[1,-1,0]);

            bin = ab.get_binning_range(proj1,proj2);

            % characteristic size of the block, transformed into proj2
            % coordinate system. This is absolutely unclear why does this
            % happen and why does it look lie this.
            nb = ab.nbins_all_dims;
            transformed_block_size = 2;
            step = transformed_block_size/(nb(1)-1);
            int_range = [-0.5*(transformed_block_size+step),0.5*(transformed_block_size+step)];
            bin_range = [int_range(1)+0.5*step,step,int_range(2)-0.5*step];

            assertEqualToTol(bin_range,bin{1},'abstol',1.e-12);
            assertEqualToTol(int_range,bin{2},'abstol',1.e-12);
            assertEqualToTol(bin0{3},bin{3},'abstol',1.e-12);
            assertEqualToTol(bin0{4},bin{4},'abstol',1.e-12);
        end
        %
        function test_default_binning_4D_cross_proj(~)
            dbr = [-1,-1,-3,0;1,1,3,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),0.1,dbr(2,2)];...
                [dbr(1,3),0.3,dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab = axes_block(bin0{:});

            proj1 = ortho_proj([1,0,0],[0,1,0]);
            proj2 = ortho_proj([1,1,0],[1,-1,0]);

            bin = ab.get_binning_range(proj1,proj2);

            %proj1.targ_proj = proj2;

            assertEqualToTol([-1,0.1,1],bin{1},'abstol',1.e-12);
            assertEqualToTol([-1,0.1,1],bin{2},'abstol',1.e-12);
            assertEqualToTol(bin0{3},bin{3},'abstol',1.e-12);
            assertEqualToTol(bin0{4},bin{4},'abstol',1.e-12);
        end
        %
        function test_default_binning_4D_ortho_proj(~)
            dbr = [-1,-2,-3,0;1,2,3,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),0.2,dbr(2,2)];...
                [dbr(1,3),0.3,dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab = axes_block(bin0{:});

            proj1 = ortho_proj([1,0,0],[0,1,0]);
            proj2 = ortho_proj([1,0,0],[0,0,1]);

            bin = ab.get_binning_range(proj1,proj2);

            assertEqualToTol(bin0{1},bin{1},'abstol',1.e-12);
            assertEqualToTol(bin0{2},bin{3},'abstol',1.e-12);
            assertEqualToTol(bin0{3},bin{2},'abstol',1.e-12);
            assertEqualToTol(bin0{4},bin{4},'abstol',1.e-12);
        end
        %
        function test_default_binning_2D_same_proj(~)
            dbr = [-1,-2,-3,0;1,2,3,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)],[dbr(1,2),dbr(2,2)],...
                [dbr(1,3),0.3,dbr(2,3)],[dbr(1,4),dbr(2,4)]};

            ab = axes_block(bin0{:});
            assertEqual(ab.pax,[1,3]);
            assertEqual(ab.dax,[1,2]);
            assertEqual(ab.iax,[2,4]);
            assertEqual(ab.iint,[-2,0;2,10]);

            proj1 = ortho_proj([1,0,0],[0,1,0]);

            bin = ab.get_binning_range(proj1,proj1);

            assertEqualToTol(bin0,bin,'abstol',1.e-12);
        end
        %------------------------------------------------------------------
        function test_build_from_input_binning_more_infs(~)
            default_binning = {[-1,0.1,1],[-2,0.2,2],[-3,0.3,3],[0,1,10.05]};
            pbin = {[-inf,inf],[inf,0.1,1],[-2,0.1,inf],[-inf,0.1,inf]};
            block = axes_block.build_from_input_binning(default_binning,pbin);
            assertTrue(isa(block,'axes_block'));
            assertElementsAlmostEqual(block.img_range,...
                [-1.,-2.05,-2.05,-0.05;...
                1, 1.05,3.05,10.15]);
            assertEqual(block.nbins_all_dims,[1,31,51,102]);
            assertEqual(block.iax,1)
            assertEqual(block.iint,[-1;1])
            assertEqual(block.pax,[2,3,4])
            assertEqual(block.dax,[1,2,3])
            assertElementsAlmostEqual(block.p{1},-2.05:0.1:1.05,'absolute',1.e-12);
            assertElementsAlmostEqual(block.p{2},-2.05:0.1:3.05,'absolute',1.e-12)
            assertElementsAlmostEqual(block.p{3},-0.05:0.1:10.15,'absolute',1.e-12)
        end
        %
        function test_build_from_input_binning(~)
            default_binning = {[-1,0.1,1],[-2,0.2,2],[-3,0.3,3],[0,1,10]};
            pbin = {[],[-1,1],[-2,0.1,2],[-inf,0,inf]};
            block = axes_block.build_from_input_binning(default_binning,pbin);
            assertTrue(isa(block,'axes_block'));
            assertElementsAlmostEqual(block.img_range,[-1.05,-1,-2.05,-0.5;1.05,1,2.05,10.5]);
            assertEqual(block.nbins_all_dims,[21,1,41,11]);
            assertEqual(block.dax,[1,2,3]);
            assertEqual(block.iax,2)
            assertEqual(block.pax,[1,3,4])
            assertEqual(block.iint,[-1;1])
            assertEqual(block.dax,[1,2,3])
            assertElementsAlmostEqual(block.p{1},-1.05:0.1:1.05,'absolute',1.e-12);
            assertElementsAlmostEqual(block.p{2},-2.05:0.1:2.05,'absolute',1.e-12)
            assertElementsAlmostEqual(block.p{3},-0.5:1:10.5,'absolute',1.e-12)
        end
        %------------------------------------------------------------------
        function test_axes_block_0D_explicit(~)
            ab = axes_block(0);
            assertEqual(ab.n_dims,0);
            assertEqual(ab.nbins_all_dims,ones(1,4))
            iiax = true(1,4);
            assertEqual(ab.one_nb_is_iax,iiax)
        end

        function test_axes_block_1D_explicit(~)
            ab = axes_block(1);
            assertEqual(ab.n_dims,1);
            assertEqual(ab.nbins_all_dims,ones(1,4))
            iiax = true(1,4);
            iiax(1) = false;
            assertEqual(ab.one_nb_is_iax,iiax)
        end

        function test_axes_block_2D_explicit(~)
            ab = axes_block(2);
            assertEqual(ab.n_dims,2);
            assertEqual(ab.nbins_all_dims,ones(1,4))
            iiax = false(1,4);
            iiax(3) = true;
            iiax(4) = true;
            assertEqual(ab.one_nb_is_iax,iiax)
        end

        function test_axes_block_3D_explicit(~)
            ab = axes_block(3);
            assertEqual(ab.n_dims,3);
            assertEqual(ab.nbins_all_dims,ones(1,4))
            iiax = false(1,4);
            iiax(4) = true;
            assertEqual(ab.one_nb_is_iax,iiax)
        end

        function test_axes_block_4D_explicit(~)
            ab = axes_block(4);
            assertEqual(ab.n_dims,4);
            assertEqual(ab.nbins_all_dims,ones(1,4))
            assertEqual(ab.one_nb_is_iax,false(1,4))
        end

        function test_axes_scales_4D(~)
            dbr = [-1,-2,-3,0;1,2,3,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),0.2,dbr(2,2)];...
                [dbr(1,3),0.3,dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab = axes_block(bin0{:});

            [cube,step]  = ab.get_axes_scales();
            assertEqual(size(cube,2),16)
            assertEqual(step,cube(:,16))
        end

    end
end
