classdef main_header_tester < main_header
    % Class to test some protected methods of main header

    properties(Dependent)
        time_format
        creation_time_out_formater

    end

    methods
        function val = get.time_format(~)
            val = main_header.DT_format_;
        end
        function fw = get.creation_time_out_formater(~)
            fw = main_header.DT_out_transf_;
        end
        function dt = get_creation_time(obj,in_str)
            val = num2cell(sscanf(in_str,obj.DT_format_));
            dt = datetime(val{:});

        end
    end
end