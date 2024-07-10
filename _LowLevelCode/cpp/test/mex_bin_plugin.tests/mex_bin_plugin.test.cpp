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
};


TEST(TestMexBinPlugin, write_bin_data) {
    const std::string horace_root{
        Environment::get_env_variable(Environment::HORACE_ROOT, ".") };

    std::string binary_file{ horace_root + "/_test/binary_write.bin" };
    std::vector<char> test_data(10, 'a');
    { // scope tested class to close file on variable deletion.
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

TEST(TestMexBinPlugin,write_read_metadata) {
	const std::string horace_root{
		Environment::get_env_variable(Environment::HORACE_ROOT, ".") };

	std::string binary_file = { horace_root + "/_test/file_for_metadata.bin" };
	/*
	std::fstream h_inout_sqw;
	h_inout_sqw.open(horace_root + "/_test/file_for_metadata.bin");
	fileParameters file_info;
	std::vector<char> test_data(10, 'a'); {
		
		//file_info.fileName = binary_file;
		file_info.nbin_start_pos = 0;
		file_info.pix_start_pos = 0;
		file_info.run_id = 0;
		file_info.total_NfileBins = 0;
		file_info.pixel_width = 32;
	}
	

    bin_io_handler my_writer;
    //my_writer.init(file_info);
    size_t n_pixels(100);
    uint32_t pix_width(32);
    my_writer.write_pix_info(n_pixels,pix_width);

	size_t n_pixels_out;
    uint32_t pix_width_out;
    my_writer.read_pix_info(n_pixels_out, pix_width_out);
    ASSERT_EQ(n_pixels, n_pixels_out);
    ASSERT_EQ(pix_width, pix_width_out);

	//ASSERT_TRUE(file_exists(binary_file));

	//std::ifstream file_data(binary_file);
	std::vector<char> data_buf(10, 'a');
	//file_data.read(&data_buf[0], 10);
	//start comparison with initial data
	ASSERT_EQ(test_data,data_buf);
	h_inout_sqw.close();
	//file_data.close();
    //del_file(binary_file);
	*/



	//std::fstream h_inout_sqw(binary_file, std::ios::binary);
	std::fstream binaryfile;
	binaryfile.open(horace_root + "/_test/file_for_metadata.bin");
	EXPECT_TRUE(binaryfile.is_open());

	size_t pix_array_position = 128;  // Example initialization
	//bin_io_handler my_writer(h_inout_sqw, pix_array_position);
	bin_io_handler my_writer;
	size_t n_pixels = 100;
	uint32_t pix_width = 32;
	my_writer.write_pix_info(n_pixels, pix_width);

	size_t n_pixels_out;
	uint32_t pix_width_out;
	my_writer.read_pix_info(n_pixels_out, pix_width_out);

	ASSERT_EQ(n_pixels, n_pixels_out);
	ASSERT_EQ(pix_width, pix_width_out);

	binaryfile.close();
	


}