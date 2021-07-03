CREATE EXTERNAL TABLE ec2_recs (
ServerId string,
ServerExternalId string,
host_name string,
ServerVMwareVMname string,
RecommendationEC2Remarks string,
ServerOSName string,
ServerOSVersion string,
ServerCPUNumberOfProcessors string,
ServerCPUNumberOfCores string,
ServerCPUNumberOfLogicalCores string,
RecommendationEC2RequestedCPUUsagePct string,
RecommendationEC2RequestedvCPU string,
ServerRAMTotalSizeInMB string,
RecommendationEC2RequestedRAMUsagePct string,
RecommendationEC2RequestedRAMinMB string,
RecommendationEC2InstanceModel string,
RecommendationEC2InstancevCPUCount string,
RecommendationEC2InstanceRAMTotalSizeinMB string,
RecommendationEC2InstancePriceUpfrontCost string,
RecommendationEC2InstancePriceHourlyRate string,
RecommendationEC2InstancePriceAmortizedHourlyRate string,
RecommendationEC2InstancePriceEffectiveDateUTC string,
RecommendationEC2InstanceOSType string,
UserPreferenceRecommendationCPUSizing string,
UserPreferenceRecommendationRAMSizing string,
UserPreferenceRegion string,
UserPreferenceEC2Tenancy string,
UserPreferenceEC2PricingModel string,
UserPreferenceEC2PricingModelContractTerm string,
UserPreferenceEC2PricingModelPayment string,
UserPreferenceEC2ExcludedInstances string,
Applications string,
Tags string,
ServerSMBiosId string,
ServerVMwareMoRefId string,
ServerVMwareVCenterId string,
ServerVMwarevCenterName string,
ServerVMwarevmFolderPath string,
ServerCPUUsagePctAvg string,
ServerCPUUsagePctMax string,
ServerRAMUsedSizeInMBAvg string,
ServerRAMUsedSizeInMBMax string,
ServerRAMUsagePctAvg string,
ServerRAMUsagePctMax string,
ServerNumberOfDisks string,
ServerDiskReadsPerSecondInKBAvg string,
ServerDiskWritesPerSecondInKBAvg string,
ServerDiskReadsPerSecondInKBMax string,
ServerDiskWritesPerSecondInKBMax string,
ServerDiskReadOpsPerSecondAvg string,
ServerDiskWriteOpsPerSecondAvg string,
ServerDiskReadOpsPerSecondMax string,
ServerDiskWriteOpsPerSecondMax string,
ServerNetworkReadsPerSecondInKBAvg string,
ServerNetworkWritesPerSecondInKBAvg string,
ServerNetworkReadsPerSecondInKBMax string,
ServerNetworkWritesPerSecondInKBMax string)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
   'separatorChar' = ',',
   'quoteChar' = '"',
   'skip.header.line.count' = '1',
   )
STORED AS TEXTFILE
LOCATION 's3://aws-application-discovery-service-bp1zfkykqmedzcxw58azc1pti/ec2-recommendations/';