classdef horace3_dnd_interface
    %HORACE3_DND_INTERFACE support conversion of Horace4 image (dnd) class
    % into the structures, used for saving/loading DnD data in Horace3
    properties(Dependent,Hidden)
        % legacy operations, necessary for saving dnd object in the old sqw
        % data format. May be removed if old sqw format saving is not used
        % any more.
        u_to_rlu % Matrix (4x4) of projection axes in hkle representation
        %     u(:,1) first vector - u(1:3,1) r.l.u., u(4,1) energy etc.
        ulen;
        u_to_rlu_legacy % old legacy u_to_rlu produced by Toby's code.
        % used in tests and loading old format files
        %
        uoffset % old interface to img_offset
    end

    methods
        function val = get.u_to_rlu(obj)
            val = get_u_to_rlu(obj);
        end
        function val = get.u_to_rlu_legacy(obj)
            val = get_u_to_rlu_legacy(obj);
        end
        function val = get.ulen(obj)
            val = get_ulen(obj);
        end
        function val = get.uoffset(obj)
            val = get_uoffset(obj);
        end
        %
        function obj = set.ulen(obj, ulen)
            obj = set_ulen(obj,ulen);
        end
    end
    %
    methods(Abstract,Access = protected)
        val = get_u_to_rlu(obj);
        val = get_u_to_rlu_legacy(obj);
        val = get_ulen(obj);
        val = get_uoffset(obj);

        obj = set_ulen(obj,ulen);
    end
end