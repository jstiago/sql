Rem
Rem $Header: bsln_tables.sql 29-jul-2004.19:41:43 jberesni Exp $
Rem
Rem bsln_tables.sql
Rem
Rem Copyright (c) 2004, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      bsln_tables.sql - Baseline tables (creation).
Rem
Rem    DESCRIPTION
Rem      This script defines the tables to create for metric baseline support.
Rem      These tables are not the published API to stored data.  For the ex-
Rem      ternal interface, see bsln_views.sql.
Rem
Rem    NOTES
Rem      All objects delivering baseline support identify themselves as EM
Rem      objects with the 'mgmt_' prefix, and the baseline component with
Rem      the 'bsln_' prefix.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    jberesni    07/29/04 - threshold_parms.fail_action
Rem    jberesni    07/01/04 - pk/fk naming corrections
Rem    jberesni    06/21/04 - remove mgmt_bsln_subinterval_keycodes
Rem    jberesni    06/18/04 - remove key_value default
Rem    jberesni    06/16/04 - add mgmt_bsln_rawdata
Rem    jberesni    06/16/04 - formatting, not null, naming, remove DML
Rem    jsoule      05/24/04 - add extract registry table 
Rem    jsoule      05/21/04 - correct thresholds primary key 
Rem    jsoule      05/11/04 - jsoule_more_baseline_support
Rem    jsoule      05/10/04 - Created
Rem


Rem
Rem  Table:
Rem    mgmt_bsln_datasources
Rem
Rem  Description:
Rem    This table is the registry of metric instances that apply to the
Rem    baselining subsystem.  This is a subset of metric types that are
Rem    eligible, based on the inclusion in the mgmt_bsln_metric table.
Rem
Rem  Columns:
Rem    datasource_guid - globally unique id for <target,metric,key>
Rem    source_type     - type of data source format (EM vs. DB)
Rem    target_uid      - unification id for target
Rem    target_guid     - EM's target_guid
Rem    dbid            - DB's dbid
Rem    instance_number - DB's instance_number
Rem    instance_name   - DB's instance_name
Rem    metric_uid      - unification id for metric
Rem    metric_guid     - EM's metric_guid
Rem    metric_id       - DB's metric_id
Rem    key_value       - EM's key value
Rem

create table mgmt_bsln_datasources
   (datasource_guid raw(16)  NOT NULL
   ,source_type     char(2)  NOT NULL
   ,target_uid      raw(16)  NOT NULL
   ,metric_uid      raw(16)  NOT NULL
   ,target_guid     raw(16)
   ,metric_guid     raw(16)
   ,key_value       varchar2(256) NOT NULL
   ,dbid            number
   ,instance_num    number
   ,instance_name   varchar2(16)
   ,metric_id       number
   ,CONSTRAINT bsln_datasources_pk PRIMARY KEY (datasource_guid)
   ,CONSTRAINT bsln_datasources_uk1 UNIQUE (target_uid, metric_uid, key_value)
   )
/

Rem
Rem  Table:
Rem    mgmt_bsln_baselines
Rem
Rem  Description:
Rem    This table records the set of existing baselines.
Rem
Rem  Columns:
Rem    bsln_guid       - globally unique baseline identifier
Rem    target_uid      - unifying identifier of target
Rem    name            - user-supplied baseline name
Rem    type            - type of baseline interval context (static vs. rolling)
Rem    subinterval_key - key identifying the subintervalling scheme
Rem    status          - current status (active vs. inactive)
Rem

create table mgmt_bsln_baselines
   (bsln_guid       raw(16) NOT NULL
   ,target_uid      raw(16) NOT NULL
   ,name            varchar2(64) NOT NULL
   ,type            char(1)      NOT NULL
   ,subinterval_key varchar2(8)  NOT NULL
   ,status          varchar2(16) NOT NULL
   ,CONSTRAINT bsln_baselines_pk  PRIMARY KEY (bsln_guid)
   ,CONSTRAINT bsln_baselines_uk1 UNIQUE (target_uid, name)
   )
/


Rem
Rem  Table:
Rem    mgmt_bsln_intervals
Rem
Rem  Description:
Rem    This table lists the intervals defined on existing baselines.
Rem
Rem  Columns:
Rem    bsln_guid      - globally unique baseline identifier
Rem    interval_begin - begin time for a static baseline interval
Rem    interval_end   - end time for a static baseline interval
Rem    interval_days  - number of days in a rolling baseline interval
Rem

create table mgmt_bsln_intervals
   (bsln_guid      raw(16) NOT NULL
   ,interval_begin date
   ,interval_end   date
   ,interval_days  number
   ,CONSTRAINT bsln_intervals_fk1 FOREIGN KEY (bsln_guid)
              REFERENCES mgmt_bsln_baselines (bsln_guid)
              ON DELETE CASCADE
   )
/


Rem
Rem  Table:
Rem    mgmt_bsln_metrics
Rem
Rem  Description:
Rem    This table lists the set of 'eligible' metrics for baselining.  Metrics
Rem    absent from this list cannot contribute to baselines.  Default, or
Rem    suggested, parameter settings for eligible metrics are found here as
Rem    well.
Rem
Rem  Columns:
Rem    metric_uid              - unifying metric identifier for a baseline-able
Rem                              metric
Rem    threshold_method_default - default method for generating thresholds 
Rem                               (% of bound vs. significance level)
Rem    tail_estimator          - estimator to use when threshold method is
Rem                              significance level
Rem    warning_param_default   - default warning parameter
Rem    critical_param_default  - default critical parameter
Rem    num_occurrences_default - default number of occurrences
Rem
    
create table mgmt_bsln_metrics
   (metric_uid              raw(16)       NOT NULL
   ,tail_estimator          varchar2(16)  NOT NULL
   ,threshold_method_default varchar2(16)  NOT NULL
   ,num_occurrences_default number        NOT NULL
   ,warning_param_default   number        NOT NULL
   ,critical_param_default  number        NOT NULL
   ,CONSTRAINT bsln_metrics_pk PRIMARY KEY (metric_uid)
   )
/


Rem
Rem  Table:
Rem    mgmt_bsln_statistics
Rem
Rem  Description:
Rem    This table records daily statistical aggregates over subintervals of a
Rem    baselined datasource.
Rem
Rem  Columns:
Rem    bsln_guid         - globally unique identifier for the baseline
Rem    datasource_guid   - globally unique identifier for the data source
Rem    compute_date      - day for which statistics were computed
Rem    subinterval_code  - encoding of the subinterval of a baseline
Rem    sample_count      - number of data points in the baseline's subinterval
Rem    average           - average                  ||
Rem    minimum           - minimum                  ||
Rem    maximum           - maximum                  ||
Rem    sdev              - standard deviation       ||
Rem    pctile_25         - value at 25th percentile ||
Rem    pctile_50         - value at 50th percentile ||
Rem    pctile_75         - value at 75th percentile ||
Rem    pctile_90         - value at 90th percentile ||
Rem    pctile_95         - value at 95th percentile ||
Rem    est_sample_count  - number of data points in the tail of the baseline's
Rem                        subinterval (used by the estimator)
Rem    est_slope         - slope of the linear regression of the tail       ||
Rem    est_intercept     - y-intercept of the linear regression of the tail ||
Rem    est_fit_quality   - fit quality of the linear function to the tail   ||
Rem    est_pctile_99     - estimated value at 99th percentile
Rem    est_pctile_999    - estimated value at 99.9th percentile
Rem    est_pctile_9999   - estimated value at 99.99th percentile
Rem

create table mgmt_bsln_statistics
   (bsln_guid         raw(16) NOT NULL
   ,datasource_guid   raw(16) NOT NULL
   ,compute_date      date    NOT NULL
   ,subinterval_code  raw(21) NOT NULL
   ,sample_count      number  NOT NULL
   ,average           number
   ,minimum           number
   ,maximum           number
   ,sdev              number
   ,pctile_25         number
   ,pctile_50         number
   ,pctile_75         number
   ,pctile_90         number
   ,pctile_95         number
   ,est_sample_count  number
   ,est_slope         number
   ,est_intercept     number
   ,est_fit_quality   number
   ,est_pctile_99     number
   ,est_pctile_999    number
   ,est_pctile_9999   number
   ,CONSTRAINT bsln_statistics_pk PRIMARY KEY 
         (datasource_guid, compute_date, subinterval_code, bsln_guid)
   ,CONSTRAINT bsln_statistics_fk1 FOREIGN KEY (bsln_guid)
         REFERENCES mgmt_bsln_baselines (bsln_guid)
         ON DELETE CASCADE
   ,CONSTRAINT bsln_statistics_fk2 FOREIGN KEY (datasource_guid)
         REFERENCES mgmt_bsln_datasources (datasource_guid)
         ON DELETE CASCADE
   )
/

Rem
Rem  Table:
Rem    mgmt_bsln_threshold_parms
Rem
Rem  Description:
Rem    This table keeps the current threshold parameter settings for dynamic
Rem    thresholds.
Rem
Rem  Columns:
Rem    bsln_guid        - globally unique identifier for the baseline
Rem    datasource_guid  - globally unique identifier for the data source
Rem    threshold_method - method used to generate thresholds
Rem    num_occurrences  - number of occurrences
Rem    warning_param    - warning parameter
Rem    critical_param   - critical parameter
Rem    fail_action      - set threshold action for inadequate data or fit
Rem

create table mgmt_bsln_threshold_parms
   (bsln_guid        raw(16)  NOT NULL
   ,datasource_guid  raw(16)  NOT NULL
   ,threshold_method varchar2(16) NOT NULL
   ,num_occurrences  number   NOT NULL
   ,warning_param    number 
   ,critical_param   number
   ,fail_action      varchar2(16)
   ,CONSTRAINT bsln_thresholds_pk PRIMARY KEY (bsln_guid, datasource_guid)
   ,CONSTRAINT bsln_thresholds_fk1 FOREIGN KEY (bsln_guid)
         REFERENCES mgmt_bsln_baselines (bsln_guid)
         ON DELETE CASCADE
   ,CONSTRAINT bsln_thresholds_fk2 FOREIGN KEY (datasource_guid)
         REFERENCES mgmt_bsln_datasources (datasource_guid)
         ON DELETE CASCADE
   )
/


Rem
Rem  Table:
Rem    mgmt_bsln_rawdata
Rem
Rem  Description:
Rem    This table persists raw data from baseline datasources for rolling window
Rem    baseline statistics computation.
Rem
Rem  Columns:
Rem    datasource_guid  - globally unique identifier for the data source
Rem    obs_time         - time of observation
Rem    obs_value        - value observed
Rem

create table mgmt_bsln_rawdata
   (datasource_guid   raw(16)  NOT NULL
   ,obs_time          date     NOT NULL
   ,obs_value         number   NOT NULL
   ,CONSTRAINT bsln_rawdata_pk PRIMARY KEY (datasource_guid, obs_time)
   )
   ORGANIZATION INDEX
   COMPRESS
/




