function overrange_flag = check_overrange(data,thresh)

overrange_mask = abs(data) >= thresh;

overrange_flag = sum(overrange_mask) > 0;

if overrange_flag
warning('check_overrange: absolute value of data exceeds threshold');
end


end