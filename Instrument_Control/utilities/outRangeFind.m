function output_range = outRangeFind( Vd )

    outoptions = [0.01, 0.1, 1, 10];
    index = find(Vd < outoptions,1);
    output_range = outoptions(index);

end

