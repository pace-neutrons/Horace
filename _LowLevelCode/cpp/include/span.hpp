#pragma once


template<typename T>
class span{
public:
    using element_type = T;
    using value_type   = std::remove_cv_t<T>;
    using pointer      = T*;
    using reference    = T&;
    using size_type    = std::size_t;

    constexpr span() noexcept
        : ptr_(nullptr), size_(0) {}

    constexpr span(pointer ptr, size_type count) noexcept
        : ptr_(ptr), size_(count) {}

    constexpr pointer data() const noexcept { return ptr_; }
    constexpr size_type size() const noexcept { return size_; }
    constexpr bool empty() const noexcept { return size_ == 0; }

    constexpr reference operator[](size_type i) const noexcept {
        return ptr_[i];
    }

    constexpr pointer begin() const noexcept { return ptr_; }
    constexpr pointer end() const noexcept { return ptr_ + size_; }

private:
    pointer   ptr_;
    size_type size_;
};
