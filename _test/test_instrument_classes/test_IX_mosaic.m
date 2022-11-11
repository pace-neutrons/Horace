classdef test_IX_mosaic < TestCaseWithSave
    % Test of IX_moderator
    properties
        mik
        mikp
        mtable
        mdelta

        home_folder;
    end

    methods
        %--------------------------------------------------------------------------
        function obj = test_IX_mosaic(name)
            home_folder = fileparts(mfilename('fullpath'));
            if nargin == 0
                name = 'test_IX_mosaic';
            end
            file = fullfile(home_folder,'test_IX_mosaic_output.mat');
            obj@TestCaseWithSave(name,file);
            obj.home_folder = home_folder;

            obj.save()
        end
        %--------------------------------------------------------------------------
        function test_mosaic_fwhh_deg(obj)
            mosaic = IX_mosaic (10);
            assertEqualWithSave(obj,mosaic);
        end
        %
        function test_mosaic_anisotropic(obj)
            mosaic = IX_mosaic ([1,1,0],[1,-1,0],[10,12,7]);
            assertEqualWithSave(obj,mosaic);
        end
        %
        function test_mosaic_matrix(obj)
            xmos = [1,1,0];
            ymos = [0,0,1];
            eta =[...
                1,0,0;...
                0,4,5;...
                0,5,9 ...
                ];
            %
            mos = IX_mosaic (xmos,ymos,eta);
            assertEqualWithSave(obj,mos);
        end
        function test_mosaic_spread(~)
            % Test random rotation matricies created by mosaic spread

            % Set up lattice and reflection we want to study
            alatt = [4,4,4];
            angdeg = [90,90,90];

            bragg1 = [1,1,0];
            bragg2 = [0,0,1];

            npnt = 1e6;

            % Set up sample
            xgeom = [1,1,0];
            ygeom = [0,0,1];
            shape = 'cuboid';
            pshape = [0.02,0.03,0.04];

            xmos = [1,1,0];
            ymos = [0,0,1];
            eta =[...
                1,0,0;...
                0,4,5;...
                0,5,9 ...
                ];

            % Create sample
            mos = IX_mosaic (xmos,ymos,eta);
            sample = IX_sample(xgeom,ygeom,shape,pshape,mos);

            % Random mosaic spread
            R = sample.rand_mosaic([1,npnt],alatt,angdeg);

            % Get actual hkl after mosaic broadening, convert to intensity map perpendicular
            % to the Bragg peak bragg1
            ub = ubmatrix (bragg1, bragg2, bmatrix (alatt, angdeg));
            hkl = mtimesx_horace(R,bragg1(:));      % the hkl for the mosaic distribution
            xyz = mtimesx_horace(repmat(ub,1,1,size(hkl,3)),hkl);           % now in orthonormal frame
            xyz = squeeze(xyz);

            modQ = norm(ub*bragg1(:));    % length of bragg1 in Ang^-1
            xyz = ((180/pi)/modQ)*xyz;  % convert to degrees


            % Test covariance
            fwhh_cov_rand = cov(xyz(2:3,:)')*log(256);
            fwhh_cov_expect = [9,-5; -5,4];
            assertEqualToTol (fwhh_cov_rand,fwhh_cov_expect,'reltol',0.01)

            %-----------------------------------------------------
            % % Plot - handcraft test
            % [N,Xedges,Yedges] = histcounts2(xyz(2,:),xyz(3,:));     % can make a plot of distribution from this
            % w = IX_dataset_2d(Xedges,Yedges,N);
            % da(w)
            % aspect(1,1)
            %-----------------------------------------------------
        end

        %--------------------------------------------------------------------------
        function test_prev_versions(obj)
            %--------------------
            % Scalar example
            mosaic = IX_mosaic ([1,1,0], [1,-1,0], @gauss, [1,2,3]);

            sample_files_location = obj.home_folder;
            if obj.save_output
                % run test_IX_moderator with -save option to obtain reference
                % files when changed to new class version
                save_variables=true;
                ver = mosaic.classVersion();
                verstr = ['ver',num2str(ver)];
                check_matfile_IO(verstr, save_variables, sample_files_location,mosaic);

            else
                save_variables=false;

                verstr= 'ver1';
                check_matfile_IO(verstr, save_variables, sample_files_location ,mosaic );
            end
        end

    end
end

