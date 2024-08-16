#include "mex_bin_plugin/bin_io_handler.h"
#include "utility/environment.h"
#include <gtest/gtest.h>

using namespace Horace::Utility;

bool file_exists(const  std::string& filename) {
    std::ifstream f(filename.c_str());
    return f.good();
};

void del_file(const std::string& filename) {
    std::remove(filename.c_str());
};


TEST(TestMexBinPlugin, write_bin_data_no_file) {
    const std::string horace_root{
        Environment::get_env_variable(Environment::HORACE_ROOT, ".") };

    std::string binary_file{ horace_root + "/_test/binary_write.bin" };
    del_file(binary_file);

    std::vector<char> test_data(10 * 36, 'a');

    std::unique_ptr<bin_io_handler> my_writer(new bin_io_handler);
    fileParameters file_info;
    file_info.fileName = binary_file;
    file_info.nbin_start_pos = 0;
    file_info.pix_start_pos = 60;
    file_info.run_id = 0;
    file_info.total_NfileBins = 0;
    file_info.pixel_width = 32;

    my_writer->init(file_info); // initialize writer class to write data
    my_writer->write_pixels(&test_data[0], 10);
    my_writer.reset();


    ASSERT_TRUE(file_exists(binary_file));

    std::ifstream data_check_stream(binary_file);
    data_check_stream.seekg(60);
    std::vector<char> data_buf(20);
    data_check_stream.read(&data_buf[0], 20);

    //compare with initial pixel data
    test_data.resize(20);
    ASSERT_EQ(test_data, data_buf);
    // check correct pixel info written by reading result directly
    data_check_stream.seekg(60 - 12);
    data_check_stream.read(&data_buf[0], 12);
    data_check_stream.close();

    ASSERT_EQ(*(reinterpret_cast<uint32_t*>(&data_buf[0])), file_info.pixel_width);
    ASSERT_EQ(*(reinterpret_cast<uint64_t*>(&data_buf[4])), 10);

    del_file(binary_file);

}

TEST(TestMexBinPlugin, write_read_metadata_no_file) {
    const std::string horace_root{
        Environment::get_env_variable(Environment::HORACE_ROOT, ".") };

    std::string binary_file = { horace_root + "/_test/file_for_metadata.bin" };
    del_file(binary_file);

    //bin_stream.open(binary_file,std::ios::in|std::ios::out|std::ios::binary|std::ios::app);
    //ASSERT_TRUE(bin_stream.is_open());
    //bin_stream.close();

    //variables for testing ::

    size_t pix_array_position = 128;
    fileParameters file_info;
    file_info.fileName = binary_file;
    file_info.nbin_start_pos = 0;
    file_info.pix_start_pos = 60;
    file_info.run_id = 0;
    file_info.total_NfileBins = 0;
    file_info.pixel_width = 36;
    size_t n_bins2proces(0);

    std::unique_ptr<bin_io_handler> my_writer(new bin_io_handler());

    my_writer->init(file_info);

    size_t n_pixels = 100;

    my_writer->write_pix_info(n_pixels);

    size_t   n_pixels_out;
    uint32_t pix_width_out;
    my_writer->read_pix_info(n_pixels_out, pix_width_out);
    //checks if same size
    ASSERT_EQ(n_pixels, n_pixels_out);
    ASSERT_EQ(file_info.pixel_width, pix_width_out);

    my_writer.reset();

    // direct result validation 
    std::ifstream data_check_stream(binary_file);
    data_check_stream.seekg(60);
    std::vector<char> data_buf(20);
    data_check_stream.read(&data_buf[0], 20);

    del_file(binary_file);

}

TEST(TestMexBinPlugin, write_read_metadata_file_exist) {
    const std::string horace_root{
        Environment::get_env_variable(Environment::HORACE_ROOT, ".") };

    // prepare file with some binary information
    std::string binary_file = { horace_root + "/_test/file_for_metadata.bin" };
    del_file(binary_file);

    std::fstream bin_stream;
    std::vector<char> test_data(100);
    for (int i = 0; i < 100; i++) {
        test_data[i] = char(i);
    }
    bin_stream.open(binary_file, std::ios::in | std::ios::out | std::ios::binary | std::ios::trunc);
    ASSERT_TRUE(bin_stream.is_open());
    bin_stream.write(&test_data[0], test_data.size());
    bin_stream.close();

    // prepare pixel information
    fileParameters file_info;
    file_info.fileName = binary_file;
    file_info.nbin_start_pos = 0;
    file_info.pix_start_pos = 60;
    file_info.run_id = 0;
    file_info.total_NfileBins = 0;

    std::unique_ptr<bin_io_handler> my_writer(new bin_io_handler());

    my_writer->init(file_info);

    size_t n_pixels = 100;

    // write pixel metadata
    my_writer->write_pix_info(n_pixels);

    size_t   n_pixels_out;
    uint32_t pix_width_out;
    my_writer->read_pix_info(n_pixels_out, pix_width_out);
    //checks if pixel metadata were sucessfully written
    ASSERT_EQ(n_pixels, n_pixels_out);
    ASSERT_EQ(file_info.pixel_width, pix_width_out);
    my_writer.reset();

    std::vector<char> data_buf(100);
    bin_stream.open(binary_file, std::ios::in | std::ios::binary);
    bin_stream.read(data_buf.data(), 60);
    // check directly that data before specified positions left unchanged
    std::vector<double> ref_data(&test_data[0], &test_data[47]);
    std::vector<double> tst_data(&data_buf[0], &data_buf[47]);
    ASSERT_EQ(tst_data, ref_data);
    // and in specified position there is pixel information written lies correct pixel metadata info
    ASSERT_EQ(*(reinterpret_cast<uint32_t*>(&data_buf[48])), file_info.pixel_width);
    ASSERT_EQ(*(reinterpret_cast<uint64_t*>(&data_buf[52])), 100);

    del_file(binary_file);

}