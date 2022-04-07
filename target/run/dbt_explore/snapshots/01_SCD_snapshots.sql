
      

  create  table "taylor"."public"."employee_snapshot"
  as (
    

    select *,
        md5(coalesce(cast(employee_id as varchar ), '')
         || '|' || coalesce(cast('2022-04-07 05:04:03.077205'::timestamp without time zone as varchar ), '')
        ) as dbt_scd_id,
        '2022-04-07 05:04:03.077205'::timestamp without time zone as dbt_updated_at,
        '2022-04-07 05:04:03.077205'::timestamp without time zone as dbt_valid_from,
        nullif('2022-04-07 05:04:03.077205'::timestamp without time zone, '2022-04-07 05:04:03.077205'::timestamp without time zone) as dbt_valid_to
    from (
        

    

    select * from "taylor"."public"."employee"

    ) sbq


  );
  