CREATE OR REPLACE VIEW vw_network
AS
SELECT 'inbound' direction, 
       src.host_name source_host_name, net.source_ip, src.application source_application,
       dst.host_name destination_host_name, net.destination_ip, net.destination_port, dst.application destination_application,
       net.ip_version, net.transport_protocol,
       net.agent_id, 
       count(1) no_of_records
FROM   "inbound_connection_agent" net
LEFT JOIN   "ip_to_hostname" src
ON     src.ip_address = net.source_ip
LEFT JOIN   "ip_to_hostname" dst
ON     dst.ip_address = net.destination_ip
WHERE  net.source_ip <> net.destination_ip
GROUP BY net.agent_id, src.host_name, net.source_ip, src.application,
       dst.host_name, net.destination_ip, net.destination_port, dst.application,
       net.ip_version, net.transport_protocol
UNION ALL
SELECT 'outbound' direction,
       src.host_name source_host_name, net.source_ip, src.application source_application,
       dst.host_name destination_host_name, net.destination_ip, net.destination_port, dst.application destination_application,
       net.ip_version, net.transport_protocol,
       net.agent_id, 
       count(1) no_of_records
FROM   "outbound_connection_agent" net
LEFT JOIN   "ip_to_hostname" src
ON     src.ip_address = net.source_ip
LEFT JOIN   "ip_to_hostname" dst
ON     dst.ip_address = net.destination_ip
WHERE  net.source_ip <> net.destination_ip
GROUP BY net.agent_id, src.host_name, net.source_ip, src.application,
       dst.host_name, net.destination_ip, net.destination_port, dst.application,
       net.ip_version, net.transport_protocol;