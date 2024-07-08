#include "mex_bin_plugin/bin_io_handler.hpp"
#include "utility/environment.h"
#include <gtest/gtest.h>

using namespace Horace::Utility;

bool file_exists(const  std::string &filename) {
    std::ifstream f(filename.c_str());
    return f.good();
};

void del_file(const std::string& filename) {
    std::remove(filename.c_str());
}


TEST(TestMexBinPlugin, write_bin_data) {
    const std::string horace_root{
        Environment::get_env_variable(Environment::HORACE_ROOT, ".") };

    std::string binary_file{ horace_root + "/_test/binary_write.bin" };
    std::vector<char> test_data(10, 'a');
    { // scope tested class to close file on variable deleteon.
        bin_io_handler my_writer;
        fileParameters file_info;
        file_info.fileName = binary_file;
        file_info.nbin_start_pos = 0;
        file_info.pix_start_pos = 0;
        file_info.run_id = 0;
        file_info.total_NfileBins = 0;
        file_info.pixel_width = 34;

        size_t n_bins2proces(0);

        my_writer.init(file_info); // initialize writer class to write data
        my_writer.write_pixels(&test_data[0], 10);
    }

    ASSERT_TRUE(file_exists(binary_file));

    std::ifstream file_data(binary_file);
    std::vector<char> data_buf(10);
    file_data.read(&data_buf[0], 10);
    //start comparison with initial data
    ASSERT_EQ(test_data, data_buf);

    file_data.close();

    del_file(binary_file);

}
