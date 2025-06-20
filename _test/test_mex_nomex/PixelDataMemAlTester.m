classdef PixelDataMemAlTester<PixelDataMemory
    %PixelDataMemAlTester Helper class to validate binning with alignment
    %matrix present

    methods(Access=protected)
        function obj = set_alignment_matrix(obj,val)
            % set new alignment matrix and recalculate new pixel ranges
            % if alignment changes
            %  returned them back. now pixels are aligned
            obj.alignment_matr_ = val;
            obj.is_corrected_  = true;

        end

    end
end