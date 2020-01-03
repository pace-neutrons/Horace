#pragma once

//#include <Windows.h>

#include <cxxtest/TestSuite.h>
#include "../combine_sqw.h"
#include "nsqw_pix_reader.h"
#include "sqw_pix_writer.h"
#include "pix_mem_map.h"
class pix_map_tester :public pix_mem_map
{
public:
    void read_bins(size_t num_bin, std::vector<pix_mem_map::bin_info> &buffer,
        size_t &bin_end, size_t &buf_end) {
        pix_mem_map::_read_bins(num_bin, buffer, bin_end, buf_end);
    }
    void read_bins_job() {
        pix_mem_map::read_bins_job();
    }

    size_t get_first_thread_bin()const{return n_first_rbuf_bin;}
    size_t get_last_thread_bin()const{return  rbuf_nbin_end;}
    size_t get_n_buf_pix()const{return  rbuf_end;}
    void wait_for_read_completed() {
        std::unique_lock<std::mutex> data_ready(this->exchange_lock);
        this->bins_ready.wait(data_ready, [this]() {return this->nbins_read; });
        //std::lock_guard<std::mutex> lock(bin_read_lock);
    }
    bool thread_get_data(size_t &num_bin, std::vector<bin_info> &inbuf, size_t &bin_end, size_t &buf_end) {
        return pix_mem_map::_thread_get_data(num_bin, inbuf, bin_end, buf_end);

    }
    void thread_query_data(size_t &num_first_bin, size_t &num_last_bin, size_t &buf_end) {
        pix_mem_map::_thread_query_data(num_first_bin, num_last_bin,buf_end);
    }
    void thread_request_to_read(size_t start_bin) {
        pix_mem_map::_thread_request_to_read(start_bin);

    }


};



class TestCombineSQW : public CxxTest::TestSuite {
    std::vector<uint64_t> sample_npix;
    std::vector<uint64_t> sample_pix_pos;
    std::vector<float> pixels;
    std::string test_file_name;
    size_t num_bin_in_file, bin_pos_in_file, pix_pos_in_file;
public:
    // This pair of boilerplate methods prevent the suite being created statically
    // This means the constructor isn't called when running other tests
    static TestCombineSQW *createSuite() {
        return new TestCombineSQW();
    }
    static void destroySuite(TestCombineSQW*suite) { delete suite; }

    TestCombineSQW() {
/*
#ifdef _WIN32
        std::vector<wchar_t> Buffer(10000);
        GetModuleFileName(NULL, &Buffer[0], Buffer.size());
        auto tmpws = std::wstring(&Buffer[0]);
        std::string tmps(tmpws.begin(),tmpws.end());
        std::string::size_type pos = tmps.find_last_of("\\/");
        test_file_name  = tmps.substr(0, pos);
#else
        test_file_name = "d:/Data/svn/Horace/_test/test_symmetrisation/w3d_sqw.sqw";
#endif
*/
        test_file_name = "d:/Data/svn/Horace/_test/test_symmetrisation/w3d_sqw.sqw";
        //test_file_name = "d:/Users/abuts/Data/ExcitDev/ISIS_svn/Hor#160/_test/test_symmetrisation/w3d_sqw.sqw";
        
        num_bin_in_file = 472392;
        bin_pos_in_file = 5194471;
        pix_pos_in_file = 8973651;
        sample_npix.resize(num_bin_in_file);
        sample_pix_pos.resize(num_bin_in_file, 0);
        pixels.resize(1164180*9,0);
        std::ifstream   data_file_bin;
        data_file_bin.open(test_file_name, std::ios::in | std::ios::binary);
        if (!data_file_bin.is_open()) {
            throw "Can not open test data file";
        }
        char *buf = reinterpret_cast<char *>(&sample_npix[0]);
        data_file_bin.seekg(bin_pos_in_file);
        data_file_bin.read(buf, num_bin_in_file * 8);
        for (size_t i = 1; i < sample_npix.size(); i++) {
            sample_pix_pos[i] = sample_pix_pos[i - 1] + sample_npix[i - 1];
        }
        data_file_bin.seekg(pix_pos_in_file);
        buf = reinterpret_cast<char *>(&pixels[0]);
        data_file_bin.read(buf, 1164180 * 9 * 8);

        data_file_bin.close();
    }



        void xest_combine_sqw_pix_multi() {
            sqw_reader reader;
            fileParameters file_par;
            file_par.fileName = test_file_name;
            file_par.file_id = 0;
            file_par.nbin_start_pos = bin_pos_in_file;
            file_par.pix_start_pos = pix_pos_in_file;
            file_par.total_NfileBins = num_bin_in_file;
            std::vector<float> pix_buffer;
            pix_buffer.resize(1000);
            float *pPix_info = &pix_buffer[0];


            size_t start_buf_pos(0), pix_start_num(0), num_bin_pix;
            //--------------------------------------------------------------------------------------------
            reader.init(file_par, false, false, 1000, 1);
            //
            auto t_start = std::chrono::steady_clock::now();
            start_buf_pos = 0;
            reader.get_pix_for_bin(num_bin_in_file - 600, pPix_info, start_buf_pos, pix_start_num, num_bin_pix, false);

            reader.get_pix_for_bin(num_bin_in_file - 601, pPix_info, start_buf_pos, pix_start_num, num_bin_pix, false);

        }

};
