void accumulate_cut(double *s, double *e, double *npix,
					double const* pixel_data,mwSize data_size,
                    mxLogical *ok,mxArray *&ix_final_pixIndex,double *actual_pix_range,
					double const* rot_ustep,double const* trans_bott_left,double ebin,double trans_elo, // transformation matrix
					double const* cut_range,
					mwSize grid_size[4],	int const *iAxis,int nAxis, 
					double const* pProg_settings);

