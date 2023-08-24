classdef test_cut_inputs < TestCase

    properties
        sample_d2d_obj
        sample_proj
    end

    methods

        function obj = test_cut_inputs(~)
            obj = obj@TestCase('test_cut_inputs');
            obj.sample_proj = line_proj('u',[1,1,0],'v',[1,-1,0],'alatt',3,'angdeg',90);
            ab = line_axes('nbins_all_dims',[1,10,1,10],'img_range',[-2,-3,-4,0;1,2,3,20]);
            obj.sample_d2d_obj= d2d(ab,obj.sample_proj);
        end
        function test_invalid_binning_throws(obj)
            function out= checker()
                th = sqw_tester();
                out = th.process_and_validate_cut_inputs_public(...
                    obj.sample_d2d_obj,true, [-1,0.1,1],[0,1,10],[0,1]);
            end

            ex = assertExceptionThrown(@checker,...
                'HORACE:cut:invalid_argument');
            assertTrue(strncmp(ex.message,'Unrecognised additional input(s): ',34));
        end

        function test_extra_arg_throws(obj)
            function out= checker()
                th = sqw_tester();
                out = th.process_and_validate_cut_inputs_public(...
                    obj.sample_d2d_obj,true, [-1,0.1,1],[0,1,10],'-extra');
            end

            ex = assertExceptionThrown(@checker,...
                'HORACE:cut:invalid_argument');
            assertTrue(strncmp(ex.message,'Unrecognised additional input(s): ',34));
        end


        function test_d2d_binning(obj)
            th = sqw_tester();

            [targ_proj, pbin, opt] = th.process_and_validate_cut_inputs_public(...
                obj.sample_d2d_obj,true, [-1,0.1,1],[0,1,10]);

            assertEqual(targ_proj,obj.sample_proj);
            bins = pbin{1};
            assertEqual(numel(bins),4);
            assertTrue(opt.keep_pix)
            assertEqual(bins{1},obj.sample_d2d_obj.axes.img_range(:,1)')
            assertEqual(bins{3},obj.sample_d2d_obj.axes.img_range(:,3)')
            assertEqual(bins{2},[-1,0.1,1])
            assertEqual(bins{4},[0,1,10])

            assertTrue(isstruct(opt));
            assertEqual(numel(fieldnames(opt)),4);
            assertTrue(opt.keep_pix);
            assertFalse(opt.parallel);
            assertTrue(isempty(opt.outfile));
            assertFalse(opt.proj_given);
        end
    end
end
