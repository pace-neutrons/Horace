classdef test_lin_log_scale < TestCase
    % Unit tests to check linx,liny,linz,logx,logy,logz

    properties
        fh % image handle
        genie_config_back
    end

    methods
        function ps = test_lin_log_scale(varargin)
            if nargin>0
                name = varargin{1};
            else
                name = 'test_lin_log_scale';
            end
            ps = ps@TestCase(name);
        end
        function setUp(obj)
            obj.genie_config_back = genieplot.get();
            obj.fh = figure();
            surf(ones(10,10));
        end
        function tearDown(obj)
            delete(obj.fh);
            genieplot.set(obj.genie_config_back);
        end

        function test_linz(~)
            gi = genieplot.instance();
            linz;
            gh  = gca;
            assertEqual(gh.ZScale,'linear');
            assertEqual(gi.ZScale,'linear')
            logz;
            gh  = gca;
            assertEqual(gh.ZScale,'log');
            assertEqual(gi.ZScale,'log')
        end

        function test_liny(~)
            gi = genieplot.instance();
            liny;
            gh  = gca;
            assertEqual(gh.YScale,'linear');
            assertEqual(gi.YScale,'linear')
            logy;
            gh  = gca;
            assertEqual(gh.YScale,'log');
            assertEqual(gi.YScale,'log')
        end
        function test_linx(~)
            gi = genieplot.instance();
            linx;
            gh  = gca;
            assertEqual(gh.XScale,'linear');
            assertEqual(gi.XScale,'linear')
            logx;
            gh  = gca;
            assertEqual(gh.XScale,'log');
            assertEqual(gi.XScale,'log')
        end
    end
end

