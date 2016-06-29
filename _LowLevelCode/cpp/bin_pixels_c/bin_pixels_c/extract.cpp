void pix_reader::run_read_job() {


  while (n_pix_processed < n_pix_total && !this->interrupted) {
      
    this->read_and_process_input(this->read_buf, n_pix_processed);
    
    std::lock_guard<std::mutex> lock(this->write_lock);    
    
    write_buf.swap(this->read_buf);
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

  while (n_bins_processed < this->num_bins_to_process && !this->interrupted) {
    size_t n_pix_to_write;
    // this locks until read completed unless read have not been started
    //const char *buf = Buff.get_write_buffer(n_pix_to_write, n_bins_processed);
    this->data_ready.wait(lock, [this]() {return (this->write_allowed); });
    std::lock_guard<std::mutex> lock(this->write_lock);


    this->write_pixels(this->write_buf, n_pix_to_write);
    last_pix_written += n_pix_to_write;

    this->check_logging();
    
    this->n_pix_to_write = 0;
    this->write_allowed = false;     

  }
  this->write_job_completed = true;    
  if (!this->do_logging){
    this->do_logging = true;
    // release possible logging
    this->logging_ready.notify_one();
  }


}
