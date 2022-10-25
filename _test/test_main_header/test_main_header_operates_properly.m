classdef test_main_header_operates_properly< TestCase

    properties
        sample_dir;
        working_dir;
    end

    methods

        function obj=test_main_header_operates_properly(varargin)
            if nargin > 0
                name = varargin{1};
            else
                name= mfilename('class');
            end

            obj=obj@TestCase(name);

            pths = horace_paths;
            obj.sample_dir = pths.test_common;
            obj.working_dir = tmp_dir();
        end

        function test_load_save_old_sqw_file(obj)
            source_file = fullfile(obj.sample_dir,'sqw_1d_2.sqw');

            w1 = read_sqw(source_file);
            assertFalse(w1.main_header.creation_date_defined)
            % Creation date is undefined so check that creation date here
            % is the date of the test file
            cr_date = w1.main_header.creation_date;
            file_info = dir(source_file);

            file_date = main_header_cl.convert_datetime_to_str(datetime(file_info.date));
            assertEqual(cr_date,file_date);

            assertTrue(isa(w1.main_header,'main_header_cl'));
            % the old pixels were recalclulated but the creation date
            % remains undefined
            assertFalse(w1.main_header.creation_date_defined);

            test_file = fullfile(obj.working_dir,'sample_test_load_save_sqw.sqw');
            clOb = onCleanup(@()delete(test_file));

            % remember current date
            write_date = datetime('now');
            % new file with undefined write date should be written with
            % current date (couple of seconds difference on IO)
            % This makes the write date defined.
            write_sqw(w1,test_file);
            w1_rec = read_sqw(test_file);

            assertTrue(w1_rec.main_header.creation_date_defined);
            assertTrue(isa(w1_rec.main_header,'main_header_cl'));

            near_date = obj.get_closest_date(w1_rec.main_header.creation_date,write_date,6);
            assertEqual(near_date,w1_rec.main_header.creation_date)
        end

        function test_load_save_old_sqw_file_main_header(obj)
            source_file = fullfile(obj.sample_dir,'sqw_1d_2.sqw');

            ldr = sqw_formats_factory.instance().get_loader(source_file);
            hdr = ldr.get_main_header();

            assertTrue(isa(hdr,'main_header_cl'));
            assertFalse(hdr.creation_date_defined);

            % check that creation date here will be sqw file creation date:
            cr_date = hdr.creation_date;
            file_info = dir(source_file);
            file_date = datetime(file_info.date);
            file_date = main_header_cl.convert_datetime_to_str(file_date);
            assertEqual(cr_date,file_date);

        end

        function test_load_save_old_sqw_mat_file(obj)
            % old source file, stored without the creation date
            source_file = fullfile(obj.sample_dir,'sqwfile_readwrite_testdata_base_objects.mat');

            ld = load(source_file,'f1_1');
            sq_old = ld.f1_1;

            cr_date = sq_old.main_header.creation_date;
            near_date = obj.get_closest_date(cr_date);

            assertTrue(isa(sq_old.main_header,'main_header_cl'));

            % file is old, so creation date is poorly defined
            assertFalse(sq_old.main_header.creation_date_defined);
            assertEqual(cr_date,near_date);

            test_file = fullfile(obj.working_dir,'sample_test_load_save_old_sqw.mat');
            clOb = onCleanup(@()delete(test_file));
            % here the creation date should be set
            save(test_file,'sq_old');

            ld = load(test_file);
            sq_rec = ld.sq_old;
            near_date = obj.get_closest_date(sq_rec.main_header.creation_date);

            assertEqual(sq_rec.main_header.creation_date,near_date );
            assertTrue(sq_rec.main_header.creation_date_defined);
        end

        function test_date_wraps(obj)

            % datetime handles wrapping here, test anyway
            dt = datetime(2022,1,1,15,15,60); % 3:16pm 1st Jan 2022
            assertEqual(main_header_cl.convert_datetime_to_str(dt),'2022-01-01T15:16:00')

            dt_str = '2022-01-01T15:15:60';
            assertEqual(main_header_cl.convert_datetime_from_str(dt_str), dt)

        end
    end

    methods(Static)
        function equal_date = get_closest_date(date_tested,date_now,time_spawn)
            % helper routine to get current date and time, close to one,
            % to be obtained from main_header_cl method, with purpose of
            % testing the date to have expected value accounting for the
            % dealays the program run
            %
            % Use after main_header_cl.creation_date function is called.
            % Inputs:
            % date_tested -- the date, obtained from main_header_cl.creation_date
            %                function,
            % date_now    -- reference date, the tested date checked on the
            %                difference from. If omitted, equal to the date
            %                now.
            % time_spawn  -- number of second, the close date may differ
            %                from the date_now date.
            if ~exist('date_now','var')
                date_now = datetime("now");
            end
            if ~exist('time_spawn','var')
                time_spawn = 1;
            end

            dates = dateshift(date_now, 'start', 'second', [-time_spawn:time_spawn]);

            % convert to properly formatted strings
            dates = arrayfun(@main_header_cl.convert_datetime_to_str, dates,...
                            'UniformOutput',false);

            is_eq = ismember(dates,date_tested);
            if any(is_eq)
                equal_date = dates{is_eq};
            else
                equal_date  = dates{1};
            end
        end
    end

end
