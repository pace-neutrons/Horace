classdef test_IX_detectors_4 < TestCaseWithSave
    % Test the calculation of quantities for a detector object
    properties
        dia
        height
        thick
        atms
        path
    end

    methods
        %--------------------------------------------------------------------------
        function self = test_IX_detectors_4 (name)
            self@TestCaseWithSave(name);

        end
        %------------------------------------------------------------------
        function test_hashable_prop_det_slab(~)
            depth = repmat(0.1,9,1);
            width = repmat(0.2,9,1);
            hght = repmat(0.3,9,1);
            atten = repmat(0.4,9,1);
            dsl = IX_det_slab(depth,width,hght,atten);

            hashable_obj_tester(dsl);
        end
        function test_hashable_prop_det_TFClassic(~)
            diaph = repmat(0.01,9,1);
            hght = repmat(0.02,9,1);
            det = IX_det_TobyfitClassic(diaph, hght);

            hashable_obj_tester(det);
        end
        function test_hashable_prop_de_He3tube(~)
            hght = (0.0001:0.001:0.0099)';
            wall = (1.8:18:179.999)';
            atmss = (1.8:18:179.999)';
            diaph = wall.*2.2; % dia must be >2*wall, see IX_det_he3tube code
            tube = IX_det_He3tube(diaph, hght, wall, atmss);

            hashable_obj_tester(tube);
        end

        %--------------------------------------------------------------------------
        function test_det_slab (~)
            % construct a detector bank with a default IX_det_slab
            % and check its initialisation
            depth = repmat(0.1,9,1);
            width = repmat(0.2,9,1);
            hght = repmat(0.3,9,1);
            atten = repmat(0.4,9,1);
            dsl = IX_det_slab(depth,width,hght,atten);
            assertEqual(dsl.depth, depth);
            assertEqual(dsl.width, width);
            assertEqual(dsl.height, hght);
            assertEqual(dsl.atten, atten);
            assertEqual(dsl.ndet, 9);

            save('dsl.mat','dsl');
            clob1 = onCleanup( @()delete('dsl.mat'));
            loaded_data_1 = load('dsl.mat');
            assertEqual(loaded_data_1.dsl.depth, depth);
            assertEqual(loaded_data_1.dsl.width, width);
            assertEqual(loaded_data_1.dsl.height, hght);
            assertEqual(loaded_data_1.dsl.atten, atten);
            assertEqual(loaded_data_1.dsl.ndet, 9);

            dsl = IX_det_slab();
            assertEqual(dsl.depth,0);
            assertEqual(dsl.width,0);
            assertEqual(dsl.height,0);
            assertEqual(dsl.atten,0);
            assertEqual(dsl.ndet,1);
            save('dsl2.mat','dsl');
            loaded_data_2 = load('dsl2.mat');
            clob2 = onCleanup( @()delete('dsl2.mat'));
            assertEqual(loaded_data_2.dsl, dsl);
        end

        %--------------------------------------------------------------------------
        function test_IX_detector_tobyfitClassic (~)
            dia_ = repmat(0.01,9,1);
            hght = repmat(0.02,9,1);
            det = IX_det_TobyfitClassic(dia_, hght);
            % id here serving both as set of detector ids and the sort
            % order that has been imposed on the data by the constructor
            assertEqual(det.dia, dia_);
            assertEqual(det.height, hght);
            assertEqual(det.ndet,9);

            save('tfc.mat','det');
            clob1 = onCleanup(@()delete('tfc.mat'));
            loaded_data_1 = load('tfc.mat');
            assertEqual(loaded_data_1.det, det);

            det = IX_det_TobyfitClassic();
            assertEqual(det.dia, 0);
            assertEqual(det.height, 0);
            assertEqual(det.ndet,1);

            save('tfc2.mat','det');
            clob2 = onCleanup(@()delete('tfc2.mat'));
            loaded_data_2 = load('tfc2.mat');
            assertEqual(loaded_data_2.det, det);

        end

        %--------------------------------------------------------------------------
        function test_IX_de_He3tube (~)

            hght = (0.0001:0.001:0.0099)';
            wall = (1.8:18:179.999)';
            atms_ = (1.8:18:179.999)';
            dia_ = wall.*2.2; % dia must be >2*wall, see IX_det_he3tube code
            tube = IX_det_He3tube(dia_, hght, wall, atms_);
            assertEqual(tube.dia, dia_);
            assertEqual(tube.wall, wall);
            assertEqual(tube.height, hght);
            assertEqual(tube.atms, atms_);
            assertEqual(tube.ndet,10);
            inrad = tube.inner_rad;

            save('tube.mat','tube');
            clob = onCleanup(@()(delete('tube.mat')));
            data = load('tube.mat');
            assertEqual(data.tube, tube);

            tube = IX_det_He3tube();
            assertEqual(tube.dia, 0);
            assertEqual(tube.wall, 0);
            assertEqual(tube.height, 0);
            assertEqual(tube.inner_rad, 0);
            assertEqual(tube.inner_rad, 0);
            assertEqual(tube.ndet,1);

            save('tube2.mat','tube');
            clob = onCleanup(@()(delete('tube2.mat')));
            data2 = load('tube2.mat');
            assertEqual(data2.tube, tube);
        end
        %--------------------------------------------------------------------------
    end
end
