void pix_reader::run_read_job() {


  while (n_pix_processed < n_pix_total && !this->interrupted) {
      
    this->read_and_process_input(this->read_buf, n_pix_processed);
    
    std::lock_guard<std::mutex> lock(this->write_lock);    
    
    this->write_buf.swap(this->read_buf);
    this->write_allowed = true;
    this->data_ready.notify_one();
    
  }
  std::lock_guard<std::mutex> lock(this->write_lock);        
  this->write_allowed=true;
  this->data_ready.notify_one();
}


/* Operation which runs on separate thread and writes pixels */
void pix_writer::run_write_pix_job() {

  size_t n_bins_processed(0);

  while (n_bins_processed < this->num_bins_to_process && !Buff.is_interrupted()) {
    size_t n_pix_to_write;
    // this locks until read completed unless read have not been started
    const char *buf = Buff.get_write_buffer(n_pix_to_write, n_bins_processed);

    size_t length = n_pix_to_write*PIX_BLOCK_SIZE_BYTES;

    if (buf)
        this->write_pixels(buf, length);
    last_pix_written += n_pix_to_write;

    Buff.check_logging();
    Buff.unlock_write_buffer();
  }
  Buff.set_write_job_completed();
}