classdef test_warnonce < TestCase

    methods
        function obj = test_warnonce(~)
            obj@TestCase('test_warnonce');
        end

        function setUp(~)
            evalc("warnonce('clear', 'HORACE:panic:panic')");
            evalc("warnonce('clear', 'HORACE:panic:arr')");
        end

        function tearDown(~)
            evalc("warnonce('clear', 'HORACE:panic:panic')");
            evalc("warnonce('clear', 'HORACE:panic:arr')");
        end

        function test_warnonce_warns_once_defaults(~)
            out = evalc("warnonce('HORACE:panic:panic', 'Panic at the disco')");
            msg = lastwarn;

            assertEqual(msg, 'Panic at the disco');
            assertTrue(contains(out, 'Panic at the disco'))

            % Reset warning
            lastwarn('');

            out = evalc("warnonce('HORACE:panic:panic', 'Panic at the disco')");
            msg = lastwarn;

            assertEqual(msg, 'Panic at the disco');
            assertFalse(contains(out, 'Panic at the disco'))
        end

        function test_warnonce_clear(~)
            out = evalc("warnonce('HORACE:panic:arr', 'Panic elsewhere too')");
            assertTrue(contains(out, 'Panic elsewhere too'));
            out = evalc("warnonce('HORACE:panic:panic', 'Panic at the disco')");
            assertTrue(contains(out, 'Panic at the disco'));

            out = evalc("warnonce('HORACE:panic:panic', 'Panic at the disco')");
            assertFalse(contains(out, 'Panic at the disco'));

            out = evalc("warnonce('HORACE:panic:arr', 'Panic elsewhere too')");
            assertFalse(contains(out, 'Panic elsewhere too'));

            % Test clear
            out = evalc("warnonce('clear', 'HORACE:panic:panic')");
            assertTrue(isempty(out));
            out = evalc("warnonce('HORACE:panic:panic', 'Panic at the disco')");
            assertTrue(contains(out, 'Panic at the disco'))
            out = evalc("warnonce('HORACE:panic:arr', 'Panic elsewhere too')");
            assertFalse(contains(out, 'Panic elsewhere too'))

            out = evalc("warnonce('HORACE:panic:panic', 'Panic at the disco')");
            assertFalse(contains(out, 'Panic at the disco'))

            % Test global clear
            out = evalc("warnonce('clear')");
            assertTrue(isempty(out));
            out = evalc("warnonce('HORACE:panic:panic', 'Panic at the disco')");
            assertTrue(contains(out, 'Panic at the disco'))
            out = evalc("warnonce('HORACE:panic:arr', 'Panic elsewhere too')");
            assertTrue(contains(out, 'Panic elsewhere too'))
        end


    end

end
