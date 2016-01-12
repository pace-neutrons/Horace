#pragma once
#include <cxxtest/TestSuite.h>
#include "../combine_sqw.h"



class TestCombineSQW : public CxxTest::TestSuite {
public:
    // This pair of boilerplate methods prevent the suite being created statically
    // This means the constructor isn't called when running other tests
    static TestCombineSQW *createSuite() {
        return new TestCombineSQW();
    }
    static void destroySuite(TestCombineSQW*suite) { delete suite; }

    TestCombineSQW() {}

    void test_sqw_reader_propagate_pix() {
        sqw_reader reader(128);
        fileParameters file_par;
        file_par.fileName = "d:/Data/svn/Horace/_test/test_symmetrisation/w3d_sqw.sqw";
        file_par.file_id = 0;
        file_par.nbin_start_pos = 5194471;
        file_par.pix_start_pos = 8973651;
        file_par.total_NfileBins = 472392;
        bool initialized(false);
        try {
            reader.init(file_par, false, false, 128);
            initialized = true;
        }
        catch (...) {}

        TS_ASSERT(initialized);

        size_t pix_start_num, num_bin_pix,start_bin(0);
        std::vector<float> pix_buffer(9*1000);
        float *pPix_info = &pix_buffer[0];

        reader.get_pix_for_bin(0,pPix_info, start_bin,pix_start_num,num_bin_pix,false);
        TS_ASSERT_EQUALS(pix_start_num,0);
        TS_ASSERT_EQUALS(num_bin_pix, 3);
        // pix buffer have not changed at all
        reader.get_pix_for_bin(127, pPix_info, start_bin, pix_start_num, num_bin_pix, false);
        TS_ASSERT_EQUALS(pix_start_num, 338);
        TS_ASSERT_EQUALS(num_bin_pix, 0);

        reader.get_pix_for_bin(126, pPix_info, start_bin, pix_start_num, num_bin_pix, false);
        TS_ASSERT_EQUALS(pix_start_num, 334);
        TS_ASSERT_EQUALS(num_bin_pix, 4);

        reader.get_npix_for_bin(256,pix_start_num,num_bin_pix);
        TS_ASSERT_EQUALS(pix_start_num,678);
        TS_ASSERT_EQUALS(num_bin_pix, 0);
    }

    void test_sqw_reader_propagate_pix_multi() {
        sqw_reader reader(128);
        fileParameters file_par;
        file_par.fileName = "d:/Data/svn/Horace/_test/test_symmetrisation/w3d_sqw.sqw";
        file_par.file_id = 0;
        file_par.nbin_start_pos = 5194471;
        file_par.pix_start_pos = 8973651;
        file_par.total_NfileBins = 472392;
        bool initialized(false);
        try {
            reader.init(file_par, false, false, 128,1);
            initialized = true;
        }
        catch (...) {}

        TS_ASSERT(initialized);

        size_t pix_start_num, num_bin_pix, start_bin(0);
        std::vector<float> pix_buffer(9 * 1000);
        float *pPix_info = &pix_buffer[0];

        reader.get_pix_for_bin(0, pPix_info, start_bin, pix_start_num, num_bin_pix, false);
        TS_ASSERT_EQUALS(pix_start_num, 0);
        TS_ASSERT_EQUALS(num_bin_pix, 3);
        // pix buffer have not changed at all
        reader.get_pix_for_bin(127, pPix_info, start_bin, pix_start_num, num_bin_pix, false);
        TS_ASSERT_EQUALS(pix_start_num, 338);
        TS_ASSERT_EQUALS(num_bin_pix, 0);

        reader.get_pix_for_bin(126, pPix_info, start_bin, pix_start_num, num_bin_pix, false);
        TS_ASSERT_EQUALS(pix_start_num, 334);
        TS_ASSERT_EQUALS(num_bin_pix, 4);

        reader.get_npix_for_bin(256, pix_start_num, num_bin_pix);
        TS_ASSERT_EQUALS(pix_start_num, 678);
        TS_ASSERT_EQUALS(num_bin_pix, 0);

    }

    void test_reader_propagate_pix_multi() {
        std::vector<sqw_reader> reader_noThread(1);

        fileParameters file_par;
        file_par.fileName = "d:/Data/svn/Horace/_test/test_symmetrisation/w3d_sqw.sqw";
        file_par.file_id = 0;
        file_par.nbin_start_pos = 5194471;
        file_par.pix_start_pos = 8973651;
        file_par.total_NfileBins = 472392;
        bool initialized(false);
        try {
            //(fileParam[i], change_fileno, fileno_provided, read_buf_size, read_files_multitreaded);
            reader_noThread[0].init(file_par, false, false, 64, 0);
            initialized = true;
        }
        catch (...) {
        }

        TS_ASSERT(initialized);

        ProgParameters ProgSettings;
        ProgSettings.log_level = 2;
        ProgSettings.nBin2read = 0;
        ProgSettings.num_log_ticks = 100;
        ProgSettings.pixBufferSize = 1164180;
        ProgSettings.totNumBins = 472392;

        exchange_buffer Buffer(ProgSettings.pixBufferSize, file_par.total_NfileBins, ProgSettings.num_log_ticks);
        pix_reader Reader(ProgSettings, reader_noThread, Buffer);

        std::vector<uint64_t> nbin_Buffer_noThreads(ProgSettings.totNumBins,-1);
        uint64_t *nbinBuf = &nbin_Buffer_noThreads[0];

        size_t n_buf_pixels, n_bins_processed(0);
        Reader.read_pix_info(n_buf_pixels, n_bins_processed, nbinBuf);

        TS_ASSERT_EQUALS(n_buf_pixels, ProgSettings.pixBufferSize);
        TS_ASSERT_EQUALS(n_bins_processed+1, ProgSettings.totNumBins);

        size_t nReadPixels, n_bin_max;
        const float * buf = reinterpret_cast<const float *>(Buffer.get_write_buffer(nReadPixels, n_bin_max));
        Buffer.unlock_write_buffer();
        TS_ASSERT_EQUALS(nReadPixels, ProgSettings.pixBufferSize);
        //---------------------------------------------------------------------
        std::vector<sqw_reader> reader_threads(1);
        initialized=false;
        try {
            //(fileParam[i], change_fileno, fileno_provided, read_buf_size, read_files_multitreaded);
            reader_threads[0].init(file_par, false, false, 64, 3);
            initialized = true;
        }
        catch (...) {
        }
        TS_ASSERT(initialized);

        pix_reader ReaderThr(ProgSettings, reader_threads, Buffer);

        std::vector<uint64_t> nbin_Buffer_Threads(ProgSettings.totNumBins, -1);
        uint64_t *nbinBufThr  = &nbin_Buffer_Threads[0];

        n_bins_processed = 0;
        ReaderThr.read_pix_info(n_buf_pixels, n_bins_processed, nbinBufThr);

        TS_ASSERT_EQUALS(n_buf_pixels, ProgSettings.pixBufferSize);
        TS_ASSERT_EQUALS(n_bins_processed + 1, ProgSettings.totNumBins);

        const float * buf1 = reinterpret_cast<const float *>(Buffer.get_write_buffer(nReadPixels, n_bin_max));
        Buffer.unlock_write_buffer();
        TS_ASSERT_EQUALS(nReadPixels, ProgSettings.pixBufferSize);

        for (size_t i = 0; i < n_bins_processed + 1; i+=10) {
            TSM_ASSERT_EQUALS("bin N"+std::to_string(i),nbin_Buffer_Threads[i], nbin_Buffer_noThreads[i]);
        }
        for (size_t i = 0; i < n_buf_pixels; i+=100) {
            size_t n_pix = i/9;
            TSM_ASSERT_EQUALS("pix N" + std::to_string(n_pix), buf[i], buf1[i]);
        }

    }

};
