SELECT *
FROM
  (SELECT *
  FROM
    (
    SELECT    wfri.instance_id,
              tokn1.instance_id prnt_instance_id,
              workflow_nme
    FROM      FT_WF_WFRI wfri
    LEFT JOIN FT_WF_TOKN tokn1
    ON        wfri.prnt_token_id = tokn1.token_id
    JOIN      FT_WF_WFDF wfdf 
    USING     workflow_id
    ) iview
    CONNECT BY PRIOR INSTANCE_ID = PRNT_INSTANCE_ID
    START WITH prnt_instance_id  = '046PILgWgZjzq03+'
  ) runtime_instance,
  ft_t_jblg jblg
WHERE JBLG.INSTANCE_ID = RUNTIME_INSTANCE.INSTANCE_ID;


SELECT iview.*
FROM   (SELECT    wfri.instance_id,
                  tokn1.instance_id prnt_instance_id,
                  wfdf.workflow_nme
        FROM      FT_WF_WFRI wfri
        LEFT JOIN FT_WF_TOKN tokn1
        ON        (wfri.prnt_token_id = tokn1.token_id)
        JOIN      FT_WF_WFDF wfdf 
        USING     (workflow_id)
        ) iview
CONNECT BY PRIOR iview.instance_id = iview.prnt_instance_id
START WITH       iview.prnt_instance_id  = '046PILgWgZjzq03+'