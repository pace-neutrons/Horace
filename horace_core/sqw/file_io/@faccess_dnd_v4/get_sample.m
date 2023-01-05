function  [samp,obj]  = get_sample(obj,varargin)
% return sample stored with sqw file or IX_samp containing lattice only if
% nothing is stored. Always empty for dnd objects.
mtd = obj.get_dnd_metadata(varargin{:});
samp = IX_samp(mtd.proj.alatt,mtd.proj.angdeg);

