select   segment_name, segment_type, Sum(bytes)/1024/1024 "SIZE(MB)",
         decode(greatest(Sum(bytes)/1024, 128*100), 128*100, 'small', decode(greatest(sum(bytes)/1024/1024, 4*100), 4*100, 'medium', 'large')) 
from     user_segments
group by segment_name, segment_type