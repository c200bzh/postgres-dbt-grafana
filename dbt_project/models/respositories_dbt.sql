{{ config(materialized='table') }}

select 
    id,
    fork,
    name,
    size,
    forks,
    node_id,
    private,
    archived,
    disabled,
    language,
    watchers,
    COALESCE(NULLIF(pushed_at, ''), NULL)::date as pushed_at,
    COALESCE(NULLIF(created_at, ''), NULL)::date as created_at,
    has_issues,
    COALESCE(NULLIF(updated_at, ''), NULL)::date as updated_at,
    open_issues,
    watchers_count
from 
    {{ source("public", 'repositories') }}