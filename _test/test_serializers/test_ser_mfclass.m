classdef test_ser_mfclass < TestCase

    properties
        test_sqw;
        test_dataset;
    end

    methods
        function obj=test_ser_mfclass(varargin)
            if nargin>0
                name = varargin{1};
            else
                name  = 'test_ser_mfclass';
            end
            obj = obj@TestCase(name);

            hp = horace_paths;
            obj.test_dataset = IX_dataset_1d(1:100);
            obj.test_sqw = read_sqw(fullfile(hp.test_common,'sqw_4d.sqw'));
            addpath(fullfile(hp.test, 'test_TF_components'));
        end


        function test_ser_multifit(obj)

            kk = multifit(obj.test_dataset);
            kk = kk.set_local_foreground;
            kk = kk.set_fun(@gauss, {[1000 60  10]});
            kk = kk.set_bfun(@linear_bg, {[10 0]});

            ser = serialise(kk);
            res = deserialise(ser);

            assertEqual(kk, res);

        end

%         function test_ser_multifit_dnd(obj)
%
%             kk = multifit(dnd(obj.test_sqw));
%             kk = kk.set_fun(@sqw_bcc_hfm,  [5,5,0,10,0]);  % set foreground function(s)
%             kk = kk.set_free([1,1,0,0,0]); % set which parameters are floating
%             kk = kk.set_bfun(@sqw_bcc_hfm, {[5,5,1.2,10,0]}); % set background function(s)
%             kk = kk.set_bfree([1,1,1,1,1]);    % set which parameters are floating
%             kk = kk.set_bbind({1,[1,-1],1},{2,[2,-1],1});
%
%             ser = serialise(kk);
%             res = deserialise(ser);
%
%             assertEqual(kk, res);
%
%         end


        function test_ser_multifit_sqw(obj)

            skipTest('Deserialisation of instrument seems to fail')

            kk = multifit(obj.test_sqw);
            kk = kk.set_fun(@sqw_bcc_hfm,  [5,5,0,10,0]);  % set foreground function(s)
            kk = kk.set_free([1,1,0,0,0]); % set which parameters are floating
            kk = kk.set_bfun(@sqw_bcc_hfm, {[5,5,1.2,10,0]}); % set background function(s)
            kk = kk.set_bfree([1,1,1,1,1]);    % set which parameters are floating
            kk = kk.set_bbind({1,[1,-1],1},{2,[2,-1],1});

            ser = serialise(kk);
            res = deserialise(ser);


            assertEqual(kk, res);

        end

        function test_ser_tobyfit(obj)
            sample = IX_sample(true,[1,1,0],[0,0,1],'cuboid',[0.012,0.012,0.04]);
            sample.alatt = [3.3000 3.3000 3.3000];
            sample.angdeg = [90 90 90];

            test_tbf=set_sample_and_inst(obj.test_sqw,sample,@maps_instrument_obj_for_tests,'-efix',600,'S');

            amp=6000;
            fwhh=0.2;

            kk = tobyfit(test_tbf);
            kk = kk.set_local_foreground;
            kk = kk.set_fun(@testfunc_nb_sqw,[amp,fwhh]);
            kk = kk.set_bind({2,[2,1]});
            kk = kk.set_bfun(@testfunc_bkgd,[0,0]);
            kk = kk.set_mc_points(2);
            kk = kk.set_options('listing',0);

            ser = serialise(kk);
            res = deserialise(ser);

            assertEqual(kk, res);

        end


    end

end