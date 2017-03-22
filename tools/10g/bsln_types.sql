Rem
Rem $Header: bsln_types.sql 11-may-2004.14:33:57 jsoule Exp $
Rem
Rem bsln_types.sql
Rem
Rem Copyright (c) 2004, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      bsln_types.sql - Baseline types (creation).
Rem
Rem    DESCRIPTION
Rem      This script defines the types to create for metric baseline support.
Rem      These are the most fundamental composite types, used in function and
Rem      procedure APIs.
Rem
Rem    NOTES
Rem      None.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    jberesni    07/01/04 - change ds prefix to bsln, add bsln_statistics_[t,set]
Rem    jsoule      05/11/04 - jsoule_more_baseline_support
Rem    jsoule      05/10/04 - Created
Rem

Rem
Rem  Type:
Rem    bsln_interval_t
Rem
Rem  Description:
Rem    This relation is an interval or subinterval of a baseline.
Rem
Rem  Fields:
Rem    bsln_guid      - Globally unique identifier for the baseline
Rem    interval_begin - begin time of interval or subinterval
Rem    interval_end   - end time of interval or subinterval
Rem

create type bsln_interval_t as object
   (bsln_guid      raw(16)
   ,interval_begin date
   ,interval_end   date
   );
/

Rem
Rem  Type:
Rem    bsln_interval_set
Rem
Rem  Description:
Rem    This is a set of intervals, or subintervals, of baselines.
Rem

create type bsln_interval_set as table of bsln_interval_t;
/

Rem
Rem  Type:
Rem    bsln_observation_t
Rem
Rem  Description:
Rem    This relation is an observation of a data source.
Rem
Rem  Fields:
Rem    datasource_guid - metric instance (<target,metric,key>) observed
Rem    bsln_guid       - unique baseline identifier
Rem    subinterval_code  - encoding of the subinterval of a baseline
Rem    obs_time        - time of observation
Rem    obs_value       - value observed

create type bsln_observation_t as object
   (datasource_guid   raw(16)
   ,bsln_guid         raw(16)
   ,subinterval_code  raw(21)
   ,obs_time          date
   ,obs_value         number
   );
/

Rem
Rem  Type:
Rem    bsln_observation_set
Rem
Rem  Description:
Rem    This is a set of observations of data sources.
Rem

create type bsln_observation_set as table of bsln_observation_t;
/


Rem
Rem  Type:
Rem    bsln_statistics_t
Rem
Rem  Description:
Rem    An object attribute-column matched to mgmt_bsln_statistics
Rem

create type bsln_statistics_t as object
   (bsln_guid         raw(16)
   ,datasource_guid   raw(16)
   ,compute_date      date   
   ,subinterval_code  raw(21)
   ,sample_count      number 
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
   );
/

Rem
Rem  Type:
Rem    bsln_statistics_set
Rem
Rem  Description:
Rem    A set of statistics objects
Rem

create type bsln_statistics_set as table of bsln_statistics_t;
/

