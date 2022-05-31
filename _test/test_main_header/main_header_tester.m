classdef main_header_tester < main_header_cl
    % Class to test some protected methods of main header

    properties(Dependent)
        time_format
        creation_time_out_formater

    end

    methods
    end
    methods(Static)
        function dt = get_creation_time(in_str)
            val = num2cell(sscanf(in_str,main_header_cl.DT_format_));
            dt = datetime(val{:});
        end
        function fw = get_creation_time_out_formater()
            fw = main_header_cl.DT_out_transf_;
        end
        function val = get_time_format()
            val = main_header_cl.DT_format_;
        end
    end
end