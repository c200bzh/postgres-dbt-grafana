{{ config(materialized='table') }}

select 
    id,
    draft,
    state,
    number,
    node_id,
    comments,
    COALESCE(NULLIF(closed_at, ''), NULL)::date as closed_at,
    COALESCE(NULLIF(created_at, ''), NULL)::date as created_at,
    repository,
    substring(repository from '^waku-org/(.*)$') as repository_name,   -- extract repository name
    COALESCE(NULLIF(updated_at, ''), NULL)::date as updated_at,
    state_reason,
    -- Calculate issue resolution time in days for closed issues
    case 
        when state = 'closed' then COALESCE(NULLIF(closed_at, ''), NULL)::date - COALESCE(NULLIF(created_at, ''), NULL)::date
        else NULL
    end as resolution_time,
    -- extract the label of the issue
      label_data.name as label_name
from 
    {{ source("public", 'issue') }} as issue
    -- LATERAL JOIN to extract the name from the labels JSON array
    left join lateral (
        select label->>'name' as name
        from jsonb_array_elements(CAST(issue.labels AS jsonb)) as label
        limit 1
    ) as label_data on true