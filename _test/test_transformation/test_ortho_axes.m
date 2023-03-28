classdef test_ortho_axes < TestCase
    % Tests for main operations of the ortho_axes

    properties
        out_dir=tmp_dir();
    end

    methods
        function obj=test_ortho_axes(varargin)
            if nargin<1
                name = 'test_ortho_axes';
            else
                name = varargin{1};
            end
            obj = obj@TestCase(name);

        end
        %------------------------------------------------------------------
        function test_set_nonorthogonal_cell_throws_separately(~)
            range= zeros(2,4);
            range(2,:) = 1;
            oa = ortho_axes('img_range',range,'nbins_all_dims', ...
                [1,20,20,1]);
            function thrower(cl,prop,val)
                cl.(prop) = val;
            end

            assertExceptionThrown(@()thrower(oa,'nonorthogonal',true), ...
                'HORACE:ortho_axes:invalid_argument');
        end
        %
        function test_unit_cell_set_get(~)
            range= zeros(2,4);
            range(2,:) = 1;
            oa = ortho_axes('img_range',range,'nbins_all_dims', ...
                [1,20,20,1],'nonorthogonal',true,'unit_cell',[eye(4)]);

            assertEqual(oa.unit_cell,eye(4));
            assertTrue(oa.nonorthogonal);            
        end
        %------------------------------------------------------------------
        function test_correct_binning_and_indx_2D(~)
            dbr = [0,0.1,0,0.5;1,1.9,3,9.5];
            bin0 = {[dbr(1,1),dbr(2,1)];[dbr(1,2),0.2,dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab = ortho_axes(bin0{:});

            nd = ab.dimensions;
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

            pix = PixelDataBase.create(pix_dat_full);

            assertExceptionThrown(@()bin_pixels(ab,pix_data,[],[]), ...
                'HORACE:AxesBlockBase:invalid_argument');
            assertExceptionThrown(@()bin_pixels(ab,pix_data,[],[],[]), ...
                'HORACE:AxesBlockBase:invalid_argument');

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
        %
        function test_correct_binning_and_indx_2D_accumulated(~)
            dbr = [0,0.1,0,0.5;1,1.9,3,9.5];
            bin0 = {[dbr(1,1),dbr(2,1)];[dbr(1,2),0.2,dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab = ortho_axes(bin0{:});

            nd = ab.dimensions;
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
            pix = PixelDataBase.create(pix_dat_full);

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
            ab = ortho_axes(bin0{:});

            nd = ab.dimensions;
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
            pix = PixelDataBase.create(pix_dat_full);

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
            ab = ortho_axes(bin0{:});

            nd  = ab.dimensions;
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
            pix = PixelDataBase.create(pix_dat_full);

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
            ab = ortho_axes(bin0{:});

            nd  = ab.dimensions;
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
            pix = PixelDataBase.create(pix_dat_full);

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
            ab = ortho_axes(bin0{:});

            nd  = ab.dimensions;
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
            pix = PixelDataBase.create(pix_dat_full);

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
            ab = ortho_axes(bin0{:});

            nd  = ab.dimensions;
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
            pix = PixelDataBase.create(pix_dat_full);

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
            ab = ortho_axes(bin0{:});

            nd  = ab.dimensions;
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
            pix = PixelDataBase.create(pix_dat_full);

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
            ab = ortho_axes(bin0{:});

            nd  = ab.dimensions;
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
            pix = PixelDataBase.create(pix_dat_full);

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
            ab = ortho_axes(bin0{:});

            nd  = ab.dimensions;
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
            ab = ortho_axes(bin0{:});

            nd  = ab.dimensions;
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
            ab = ortho_axes(bin0{:});

            nd  = ab.dimensions;
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
            ab = ortho_axes(bin0{:});

            nd = ab.dimensions;
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
            ab = ortho_axesTester(bin0{:});

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
            ab = ortho_axesTester(bin0{:});

            pix_data = ones(4,10);
            pix = PixelDataBase.create();
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
            assertEqual(pix_candidates.num_pixels,0);
            assertTrue(isempty(argi));
        end
        %
        function test_1Dbin_inputs_3par(~)
            dbr = [-1,-2,-3,0;1,2,3,10];
            bin0 = {[dbr(1,1),dbr(2,1)];[dbr(1,2),dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab = ortho_axesTester(bin0{:});

            pix_data = ones(4,10);
            pix = PixelDataBase.create();

            [npix,s,e,pix_candidates,argi]= ...
                ab.get_bin_inputs(pix_data,3,[],[],[],pix);
            assertEqual(size(npix),[11,1]);
            assertEqual(size(s),[11,1]);
            assertEqual(size(e),[11,1]);
            assertEqual(npix,zeros(11,1))
            assertEqual(s,zeros(11,1))
            assertEqual(e,zeros(11,1))
            assertEqual(pix_candidates.num_pixels,0);
            assertTrue(isempty(argi));
        end
        %
        function test_1Dbin_inputs_1par(~)
            dbr = [-1,-2,-3,0;1,2,3,10];
            bin0 = {[dbr(1,1),dbr(2,1)];[dbr(1,2),dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab = ortho_axesTester(bin0{:});

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
            ab = ortho_axesTester(4);
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
            ab = ortho_axesTester(4);
            pix_data = ones(4,10);
            pix = PixelDataBase.create();
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
            assertEqual(pix_candidates.num_pixels,0);
            assertTrue(isempty(argi));
        end
        %
        function test_0Dbin_inputs_3par(~)
            ab = ortho_axesTester(4);
            pix_data = ones(4,10);
            pix = PixelDataBase.create();

            [npix,s,e,pix_candidates,argi]= ...
                ab.get_bin_inputs(pix_data,3,[],[],[],pix);
            assertEqual(size(npix),[1,1]);
            assertEqual(size(s),[1,1]);
            assertEqual(size(e),[1,1]);
            assertEqual(npix,0)
            assertEqual(s,0)
            assertEqual(e,0)
            assertEqual(pix_candidates.num_pixels,0);
            assertTrue(isempty(argi));
        end
        %
        function test_0Dbin_inputs_1par(~)
            ab = ortho_axesTester(4);
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
        function test_get_bin_nodes_4D_2d(~)
            dbr = [-1,-2,-3,0;1,2,3,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),0.2,dbr(2,2)];...
                [dbr(1,3),0.3,dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab = ortho_axes(bin0{:});

            [nodes,en] = ab.get_bin_nodes('-3D');
            assertEqual(size(nodes,1),3);
            sz = ab.nbins_all_dims();
            sz = sz+1;

            assertEqual(numel(en),sz(4));

            the_size = prod(sz(1:3));
            assertEqual(size(nodes,2),the_size);
        end
        %
        function test_get_bin_centers_2D_4d(~)
            dbr = [-1,-2,-3,0;1,2,3,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
	        % Define 2-dimensional grid.
            ab = ortho_axes(bin0{:});

            % create multiplier to produce 4-dimensional grid 
			% with requested number of bins (10x10x10x10)
            char_size_des = (dbr(2,:)-dbr(1,:))/10;
            char_size_ex  = (ab.img_range(2,:)-ab.img_range(1,:))./ab.nbins_all_dims;
            mult = ceil(char_size_ex./char_size_des);
			% ensure multiplier is never smaller then 1
            mult(mult<1) = 1;
            [nodes,en,nbins] = ab.get_bin_nodes('-bin_centre',mult);
            assertEqual(size(nodes,1),4);

            assertEqual(numel(en),nbins(end));

            the_size = prod(nbins);
            assertEqual(size(nodes,2),the_size);
        end
        %
        function test_get_bin_centers_2D_native(~)
            dbr = [-1,-2,-3,0;1,2,3,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab = ortho_axes(bin0{:});

            [centers,en,ncenters] = ab.get_bin_nodes('-bin_centre');
            assertEqual(size(centers,1),4);

            ndd = ab.nbins_all_dims;
            assertEqual(ndd,ncenters);
            sz = ab.dims_as_ssize();

            assertEqual(numel(en),sz(end));

            the_size = prod(sz);
            assertEqual(size(centers,2),the_size);
        end
        %
        function test_wrong_mult_throw(~)
            dbr = [-1,-2,-3,0;1,2,3,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab = ortho_axes(bin0{:});
            mult = ones(3,1);
            ex = assertExceptionThrown(@()get_bin_nodes(ab,'-bin_centre',mult),...
                'HORACE:AxesBlockBase:invalid_argument');
            assertTrue(strncmp(ex.message,'nnodes multipler should',23));
        end
        %
        function test_wrong_keyword_throw(~)
            dbr = [-1,-2,-3,0;1,2,3,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab = ortho_axes(bin0{:});
			% procedure to produce multiplier, which gives requested number of bins
			% does not used here but left for correct code execution in case of 
			% the requested exception is not thrown 
            char_size_des = (dbr(2,:)-dbr(1,:))'/10;
            char_size_ex  = (dbr(2,:)-dbr(1,:))'./ab.nbins_all_dims;
            mult = ceil(char_size_ex./char_size_des);
            mult(mult<1) = 1;

            ex = assertExceptionThrown(@()get_bin_nodes(ab,'-wrong',mult),...
                'HORACE:AxesBlockBase:invalid_argument');
            assertTrue(strncmp(ex.message,'nodes_multiplier, if present, should',36));
        end
        %
        function test_get_bin_nodes_2D_2d(~)
            dbr = [-1,-2,-3,0;1,2,3,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab = ortho_axes(bin0{:});

            [nodes,en] = ab.get_bin_nodes('-3D');
            assertEqual(size(nodes,1),3);

            nd = ab.dimensions;
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
            ab = ortho_axes(bin0{:});

            nodes = ab.get_bin_nodes();
            assertEqual(size(nodes,1),4);

            sz = ab.dims_as_ssize();
            sz = sz+1;

            the_size = prod(sz);
            assertEqual(size(nodes,2),the_size);
        end
        %
        function test_get_bin_nodes_2D_2d_mult(~)
            dbr = [-1,-2,-3,0;1,2,3,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab = ortho_axes(bin0{:});


            [nodes,en,nbins] = ab.get_bin_nodes(2);
            assertEqual(numel(en),nbins(4));
            assertEqual(size(nodes,1),4);
            node_range = [min(nodes,[],2)';max(nodes,[],2)'];
            assertEqual(ab.img_range,node_range);

            %nns = floor((ab.img_range(2,:)-ab.img_range(1,:))'./(0.5*new_step))+1;
            nns = [43,3,3,23];
            assertEqual(nns,nbins);
            the_size = prod(nns);
            assertEqual(size(nodes,2),the_size);
        end
        %
        function test_get_bin_nodes_2D_4d_mult(~)
            dbr = [-1,-2,-3,0;1,2,3,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab = ortho_axes(bin0{:});

            nnodes_mult = [2,40,40,10];
            [nodes3D,dEgrid,npoints_in_axes] = ab.get_bin_nodes(nnodes_mult,'-3D');
            assertEqual(size(nodes3D,1),3);
            node_range = [min(nodes3D,[],2)';max(nodes3D,[],2)'];
            assertEqual(ab.img_range(:,1:3),node_range);

            %nns = floor((ab.img_range(2,:)-ab.img_range(1,:))'./(0.5*new_step))+1;

            nns = [43,41,41,111];
            assertEqual(npoints_in_axes,nns);
            q_size = prod(nns(1:3));
            assertEqual(numel(dEgrid),nns(4))
            assertEqual(size(nodes3D,2),q_size);
        end
        %
        function test_get_bin_nodes_2D_4d(~)
            dbr = [-1,-2,-3,0;1,2,3,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab = ortho_axes(bin0{:});

            nodes = ab.get_bin_nodes();
            assertEqual(size(nodes,1),4);

            nd = ab.dimensions;
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
            ab = ortho_axes(bin0{:});

            tob = DnDBase.dnd(ab,ortho_proj());
            range  = tob.targ_range([],'-binning');

            assertEqual(bin0,range);
        end
        %------------------------------------------------------------------
        function test_default_binning_2D_cross_proj(~)
            dbr = [-1,-1.05,-3,0;1,1.05,3,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),dbr(2,2)];...
                [dbr(1,3),0.3,dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab = ortho_axes(bin0{:});

            proj1 = ortho_proj([1,0,0],[0,1,0]);
            proj2 = ortho_proj([1,1,0],[1,-1,0]);

            tob = DnDBase.dnd(ab,proj1);
            bin = tob.targ_range(proj2,'-binning');

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
            ab = ortho_axes(bin0{:});

            proj1 = ortho_proj([1,0,0],[0,1,0]);
            proj2 = ortho_proj([1,1,0],[1,-1,0]);

            tob = DnDBase.dnd(ab,proj1);
            bin = tob.targ_range(proj2,'-binning');

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
            ab = ortho_axes(bin0{:});

            proj1 = ortho_proj([1,0,0],[0,1,0]);
            tob = DnDBase.dnd(ab,proj1);
            proj2 = ortho_proj([1,0,0],[0,0,1]);

            bin = tob.targ_range(proj2,'-binning');

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

            ab = ortho_axes(bin0{:});
            assertEqual(ab.pax,[1,3]);
            assertEqual(ab.dax,[1,2]);
            assertEqual(ab.iax,[2,4]);
            assertEqual(ab.iint,[-2,0;2,10]);

            proj1 = ortho_proj([1,0,0],[0,1,0]);
            tob = DnDBase.dnd(ab,proj1);

            bin = tob.targ_range(proj1,'-binning');

            assertEqualToTol(bin0,bin,'abstol',1.e-12);
        end
        %------------------------------------------------------------------
        function test_build_from_input_binning_more_infs(~)
            default_binning = {[-1,0.1,1],[-2,0.2,2],[-3,0.3,3],[0,1,10.05]};
            pbin = {[-inf,inf],[inf,0.1,1],[-2,0.1,inf],[-inf,0.1,inf]};
            block = AxesBlockBase.build_from_input_binning('ortho_axes',default_binning,pbin);
            assertTrue(isa(block,'ortho_axes'));
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
            block = AxesBlockBase.build_from_input_binning('ortho_axes',default_binning,pbin);
            assertTrue(isa(block,'ortho_axes'));
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
        function test_dax_eq_pax(~)
            ab = ortho_axes('img_range',ones(2,4),'nbins_all_dims',[50,1,1,40]);

            assertEqual(ab.pax,[1,4])
            assertEqual(ab.dax,[1,2])
        end
        %------------------------------------------------------------------
        function test_bin_edges_provided_2D(~)
            dbr = [-1,-2,-3,0;1,2,3,10];
            bin0 = {[dbr(1,1),dbr(2,1)];[dbr(1,2),dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),dbr(2,4)]};
            ab = ortho_axes(bin0{:},'single_bin_defines_iax',[true,false,false,true]);

            assertEqual(ab.img_range,[-1,-2,-3,0;1,2,3,10])
            assertEqual(ab.dimensions(),2)

        end
        %
        function test_bin_edges_provided_4D(~)
            dbr = [-1,-2,-3,0;1,2,3,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),0.2,dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab = ortho_axes(bin0{:},'single_bin_defines_iax',[true,false,false,true]);

            assertEqual(ab.img_range,[-1-0.05,-2,-3,0-0.5;1+0.05,2,3,10+0.5])
            assertEqual(ab.dimensions(),4)

        end
        %
        function test_ortho_axes_0D_explicit(~)
            ab = ortho_axes(0);
            assertEqual(ab.dimensions,0);
            assertEqual(ab.nbins_all_dims,ones(1,4))
            iiax = true(1,4);
            assertEqual(ab.single_bin_defines_iax,iiax)
        end
        %
        function test_ortho_axes_1D_explicit(~)
            ab = ortho_axes(1);
            assertEqual(ab.dimensions,1);
            assertEqual(ab.nbins_all_dims,ones(1,4))
            iiax = true(1,4);
            iiax(1) = false;
            assertEqual(ab.single_bin_defines_iax,iiax)
        end
        %
        function test_ortho_axes_2D_explicit(~)
            ab = ortho_axes(2);
            assertEqual(ab.dimensions,2);
            assertEqual(ab.nbins_all_dims,ones(1,4))
            iiax = false(1,4);
            iiax(3) = true;
            iiax(4) = true;
            assertEqual(ab.single_bin_defines_iax,iiax)
        end
        %
        function test_ortho_axes_3D_explicit(~)
            ab = ortho_axes(3);
            assertEqual(ab.dimensions,3);
            assertEqual(ab.nbins_all_dims,ones(1,4))
            iiax = false(1,4);
            iiax(4) = true;
            assertEqual(ab.single_bin_defines_iax,iiax)
        end
        %
        function test_ortho_axes_4D_explicit(~)
            ab = ortho_axes(4);
            assertEqual(ab.dimensions,4);
            assertEqual(ab.nbins_all_dims,ones(1,4))
            assertEqual(ab.single_bin_defines_iax,false(1,4))
        end
        %

    end
end
