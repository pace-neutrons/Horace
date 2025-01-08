classdef (InferiorClasses = {?DnDBase,?IX_dataset,?sigvar}) PixelDataHDF < PixelDataFileBacked

    properties
        filename
    end
    properties (Constant)
        is_filebacked = true;
    end

    methods
        function obj = PixelDataHDF(filename, init, experiment)
            have_exp = exist(experiment, 'var')
            if ~exist(init, 'var')
                init = [];
            end
            if ~have_exp
                experiment = [];
            end

            if isa(init, 'PixelDataBase')
                obj = PixelDataHDF.from_pixdata(filename, init, experiment);

            elseif isscalar(init) && isnumeric(init) && floor(init) == init
                % input is an integer
                obj = PixelDataHDF.create_empty(filename, init, experiment);

            elseif isnumeric(init)
                data = PixelDataMemory(init);
                obj = PixelDataHDF.from_pixdata(filename, data, experiment);

            elseif istext(init) && is_file(init)
                obj.filename = filename
                if have_exp
                    obj.experiment = experiment;
                else
                    obj.experiment = deserialize(h5read(filenamem, '/exp'));
                end
                obj.num_pixels_ = h5readatt(filename, '/sqw/pix', 'num_pixels');
                obj.alignment_matr = h5readatt(filename, '/sqw/pix/id', 'alignment');
            end
        end

        function pix_copy = copy(obj)
            pix_copy = PixelDataHDF(obj.filename)
        end

        function sz = get_pix_byte_size(obj,keep_precision)
        % Return the size of single pixel expressed in bytes.
        %
        % If keep_percision is true, return this size as defined in
        % pixel data file
            sz = obj.DEFAULT_NUM_PIX_FIELDS*8;
        end

        function ro = get_read_only(obj)
        % report if the file allows to be modified.
        % Main overloadable part of read_only property
            ro = true
        end

        function pix_data = get_raw_pix_data(obj, row_pix_idx, col_pix_idx)
            [start_idx, end_idx] = obj.get_page_idx_();
            npix = end_idx - start_idx + 1;
            pix_data = PixelDataMemory(npix);
            raw_idx = h5read(obj.filename, '/sqw/pix/id', start_idx, npix);

            sz = h5readatt(obj.filename, '/sqw/pix/id', 'id_max')
            [run_idx, detector_idx, energy_idx] = ind2sub(sz, raw_idx);

            pix_data.data_(:, obj.field_index('run_idx')) = run_idx
            pix_data.data_(:, obj.field_index('detector_idx')) = detector_idx
            pix_data.data_(:, obj.field_index('energy_idx')) = energy_idx
            pix_data.data_(:, obj.field_index('coordinates')) = obj.experiment.calc_qspec();
            pix_data.data_(:, obj.field_index('signal')) = h5read(obj.filename, '/sqw/pix/signal', start_idx, npix);
            pix_data.data_(:, obj.field_index('variance')) = h5read(obj.filename, '/sqw/pix/error', start_idx, npix);

            pix_data.data_(:, obj.field_index('q_coordinates')) = mtimesx_horace(obj.alignment_matr, pix_data.data(:, obj.field_index('q_coordinates'));
        end
    end

    methods(Static)

        function to_hdf(obj, filename, experiment)
            if ~exist(experiment, 'var') && isprop(obj, 'experiment')
                experiment = obj.experiment;
            else
                experiment = [];
            end

            PixelDataHDF.create_empty(filename, obj.num_pixels, experiment)

            r_id_idx = obj.field_index('run_idx');
            e_id_idx = obj.field_index('energy_idx');
            d_id_idx = obj.field_index('detector_idx');
            sig_idx = obj.field_index('signal');
            err_idx = obj.field_index('variance');

            sz = [obj.data_range(2, r_id_idx),
                  obj.data_range(2, e_id_idx),
                  obj.data_range(2, d_id_idx)];

            start = 1;
            for i = 1:obj.num_pages
                obj.page_num = i;
                data = obj.data;


                global_idx = sub2ind(sz, data(r_id_idx, :), data(e_id_idx, :), data(d_id_idx, :));
                num_pix = size(global_idx, 2);

                h5write(filename, "/sqw/pix/id", global_idx, start, num_pix);
                h5write(filename, "/sqw/pix/signal", data(sig_idx, :), start, num_pix);
                h5write(filename, "/sqw/pix/error", data(err_idx, :), start, num_pix);

                start = start + num_pix;
            end
            h5writeatt(filename, "/sqw/pix/id", 'alignment', obj.alignment_matr)
            h5writeatt(filename, "/sqw/pix/id", 'id_max', sz)
            h5writeatt(filename, "/sqw/pix", 'num_pixels', obj.num_pixels)
        end

    end

    methods(Static, Hidden)
        function obj = from_pixdata(filename, pix_data, experiment)
            PixelDataHDF.to_hdf(pix_data, filename, experiment)
            obj = PixelDataHDF(filename, experiment)
        end

        function create_empty(filename, sz, experiment)
            chunk_size = min(config_store.instance().get_value('hor_config', 'mem_chunk_size'), sz);

            exp = serialize(experiment);
            h5write(filename, "/exp", exp, 'Datatype', 'uint8');

            h5create(filename, "/sqw/pix/id", sz, 'Datatype', 'uint64', 'ChunkSize', chunk_size);
            h5create(filename, "/sqw/pix/signal", sz, 'Datatype', 'double', 'ChunkSize', chunk_size);
            h5create(filename, "/sqw/pix/error", sz, 'Datatype', 'double', 'ChunkSize', chunk_size);

        end
    end

    % Ignored methods
    methods
        function obj = deactivate(obj)
        end
        function [obj, is_tmp] = activate(obj, filename, varargin)
        end
        function wh = get_write_handle(obj, varargin)
        end
        function obj = set_as_tmp_obj(obj, filename)
        end
        function obj = finish_dump(obj, page_op)
        end
        function format = get_memmap_format(obj, tail, new)
        end
        function obj=set_data_wrap(obj,val)
        end
        function obj = set_raw_data(obj, pix)
        end
        function obj = store_page_data(obj,data,wh)
        end
    end

end
