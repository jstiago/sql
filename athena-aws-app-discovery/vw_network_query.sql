SELECT direction, 
       source_host_name, 
       source_ip, 
       source_application,
       destination_host_name, 
       destination_ip, 
       destination_application,
       sum(no_of_records) 
FROM   vw_network
GROUP BY direction, 
       source_host_name, 
       source_ip, 
       source_application,
       destination_host_name, 
       destination_ip, 
       destination_application